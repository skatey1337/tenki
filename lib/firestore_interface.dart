import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String uid = FirebaseAuth.instance.currentUser!.uid;

class DatabaseInterface {

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> addExampleDataMap() async {
    uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference storageMaps =
        FirebaseFirestore.instance.collection('storageMaps');
    await storageMaps.doc(uid).set({
      'storageMap': {
        "items": [
          {
            "name": "Beispiel 1",
            "location": "Beispiellager 1",
            "unit": "Packung a 18 Stück",
            "targetQuantity": 2,
            "stockQuantity": 2,
            "buyQuantity": 0,
            "shoppingCategory": "Tiefkühl",
          },
          {
            "name": "Beispiel 2",
            "location": "Beispielort 2",
            "unit": "kg",
            "targetQuantity": 1,
            "stockQuantity": 0,
            "buyQuantity": 1,
            "shoppingCategory": "Obst und Gemüse",
          },
        ],
      },
    });
  }

  Future<void> addItemToStorageMap(Map<String, dynamic> itemMap) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final DocumentReference<Map<String, dynamic>> documentReference =
          FirebaseFirestore.instance.collection('storageMaps').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await documentReference.get();
      final Map<String, dynamic> storageMap = snapshot.data()!['storageMap'];
      List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from(storageMap['items']);
      items.add(itemMap);
      storageMap['items'] = items;
      await documentReference.set({'storageMap': storageMap});
    } catch (e) {
      print('Error adding item to storage map: $e');
    }
  }

  Future<void> updateItemByName(
      String itemName, Map<String, dynamic> updatedItemData) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final storageMapRef =
        FirebaseFirestore.instance.collection('storageMaps').doc(uid);
    final storageMapDoc = await storageMapRef.get();

    final storageMap = storageMapDoc.data()?['storageMap'] ?? {};
    final items = storageMap['items'] ?? [];

    final updatedItems = items.map((item) {
      if (item['name'] == itemName) {
        return {...item, ...updatedItemData};
      }
      return item;
    }).toList();

    final updatedStorageMapData = {
      'storageMap': {'items': updatedItems}
    };
    await storageMapRef.update(updatedStorageMapData);
  }








  Future<void> addExampleLocationMap() async {
    uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference locationMaps =
    FirebaseFirestore.instance.collection('locationMaps');
    await locationMaps.doc(uid).set({
      'locationMap': {
        "locations" :[
          { 'title': 'Neuer Lagerort',
            'iconId': 16,
          },
        ],
      },
    });
  }

  Future<void> addLocation(String title, int iconId) async {
    uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference locationMaps =
    FirebaseFirestore.instance.collection('locationMaps');
    DocumentReference docRef = locationMaps.doc(uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    List<dynamic> locations = data['locationMap']['locations'];
    locations.insert(locations.length - 1, {'title': title, 'iconId': iconId});
    await docRef.update({'locationMap.locations': locations});
  }





/*
* Delets a location and all items, that are stored in it
* */
  Future<void> deleteLocationAndItems(String locationTitle) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Get the locationMap document and remove the location with the given title
      final DocumentReference<Map<String, dynamic>> locationDocumentReference =
      FirebaseFirestore.instance.collection('locationMaps').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> locationSnapshot =
      await locationDocumentReference.get();
      final Map<String, dynamic> locationMap = locationSnapshot.data()!['locationMap'];
      List<Map<String, dynamic>> locations =
      List<Map<String, dynamic>>.from(locationMap['locations']);
      int locationIndex = -1;
      for (int i = 0; i < locations.length; i++) {
        if (locations[i]['title'] == locationTitle) {
          locationIndex = i;
          break;
        }
      }
      if (locationIndex == -1) {
        //print('Location not found.');
        return;
      }
      locations.removeAt(locationIndex);
      locationMap['locations'] = locations;
      await locationDocumentReference.set({'locationMap': locationMap});

      // Get the storageMap document and remove items that are associated with the deleted location
      final DocumentReference<Map<String, dynamic>> storageDocumentReference =
      FirebaseFirestore.instance.collection('storageMaps').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> storageSnapshot =
      await storageDocumentReference.get();
      final Map<String, dynamic> storageMap = storageSnapshot.data()!['storageMap'];
      List<Map<String, dynamic>> items =
      List<Map<String, dynamic>>.from(storageMap['items']);
      List<Map<String, dynamic>> updatedItems = [];
      for (int i = 0; i < items.length; i++) {
        if (items[i]['location'] != locationTitle) {
          updatedItems.add(items[i]);
        }
      }
      storageMap['items'] = updatedItems;
      await storageDocumentReference.set({'storageMap': storageMap});
    } catch (e) {
     // print('Error deleting location and items: $e');
    }
  }









}// Ending class







