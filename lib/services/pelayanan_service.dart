import 'package:cloud_firestore/cloud_firestore.dart';

class PelayananService {
  final CollectionReference _pelayananCollection =
      FirebaseFirestore.instance.collection('pelayanan');

  Future<void> tambahPelayanan(Map<String, dynamic> data) async {
    await _pelayananCollection.add(data);
  }

  Stream<QuerySnapshot> getPelayananStream() {
    return _pelayananCollection.snapshots();
  }

  Future<void> updatePelayanan(String id, Map<String, dynamic> data) async {
    await _pelayananCollection.doc(id).update(data);
  }

  Future<void> hapusPelayanan(String id) async {
    await _pelayananCollection.doc(id).delete();
  }
}
