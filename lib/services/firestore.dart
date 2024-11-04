

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  //Get a collection of verbs
  final CollectionReference verbs = FirebaseFirestore.instance.collection('verbs');

  //Create
  Future<void> addVerb(String verb, String infinitivo, String pasado, String participio) {
    return verbs.add({
      'verb': verb,
      'infinitivo': infinitivo,
      'pasado': pasado,
      'participio': participio
    });
  }

  //Read
  Stream<QuerySnapshot> getVerbsStream() {
    final verbsStream = verbs.orderBy('infinitivo', descending: false).snapshots();

    return verbsStream;
  }


  //Update
  Future<void> updateVerb(String docID, String newVerb, String newInfinitivo, String newPasado, String newParticipio) {
    return verbs.doc(docID).update({
      'verb': newVerb,
      'infinitivo': newInfinitivo,
      'pasado': newPasado,
      'participio': newParticipio
    });
  }

  //Delete
  Future<void> deleteVerb(String docID) {
    return verbs.doc(docID).delete();
  }
}