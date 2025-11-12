import 'package:cloud_firestore/cloud_firestore.dart';

class BahanService {
  final CollectionReference _bahanCollection =
      FirebaseFirestore.instance.collection('bahan');

  Future<void> tambahBahan(Map<String, dynamic> data) async {
    await _bahanCollection.add(data);
  }

  Stream<QuerySnapshot> getBahanStream() {
    return _bahanCollection.snapshots();
  }

  Future<void> updateBahan(String id, Map<String, dynamic> data) async {
    await _bahanCollection.doc(id).update(data);
  }

  Future<void> hapusBahan(String id) async {
    await _bahanCollection.doc(id).delete();
  }
}
