import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreService {
  Future<void> setData({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  });

  Future<DocumentSnapshot> getData({
    required String collection,
    required String docId,
  });

  Future<void> updateData({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  });

  Future<String> query({required String collection, required String query});
}
