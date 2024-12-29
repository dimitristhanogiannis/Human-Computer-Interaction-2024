import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUpdateScript {
  static Future<void> addFieldsToUsers() async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await usersCollection.get();

    for (var doc in querySnapshot.docs) {
      await usersCollection.doc(doc.id).update({
        'swipes': {
          'liked': [],
          'disliked': [],
        },
        'matches': [],
        'score': 0,
      });
    }
    print('Fields added successfully!');
  }
}
