import 'package:cloud_firestore/cloud_firestore.dart';

class CatatanKunjunganService {
  final CollectionReference _catatanCollection =
      FirebaseFirestore.instance.collection('catatan_kunjungan');

  Future<void> tambahCatatan(Map<String, dynamic> data) async {
    await _catatanCollection.add(data);
  }

  Stream<QuerySnapshot> getCatatanStream() {
    return _catatanCollection.snapshots();
  }

  Future<void> updateCatatan(String id, Map<String, dynamic> data) async {
    await _catatanCollection.doc(id).update(data);
  }

  Future<void> hapusCatatan(String id) async {
    await _catatanCollection.doc(id).delete();
  }
}
