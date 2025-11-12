import 'package:cloud_firestore/cloud_firestore.dart';

class LayananService {
  final CollectionReference _layananCollection =
      FirebaseFirestore.instance.collection('layanan');

  Future<void> tambahLayanan(Map<String, dynamic> data) async {
    await _layananCollection.add(data);
  }

  Stream<QuerySnapshot> getLayananStream() {
    return _layananCollection.snapshots();
  }

  Future<void> updateLayanan(String id, Map<String, dynamic> data) async {
    await _layananCollection.doc(id).update(data);
  }

  Future<void> hapusLayanan(String id) async {
    await _layananCollection.doc(id).delete();
  }
}
