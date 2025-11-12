import 'package:cloud_firestore/cloud_firestore.dart';

class KunjunganService {
  final CollectionReference _kunjunganCollection =
      FirebaseFirestore.instance.collection('kunjungan');

  Future<void> tambahKunjungan(Map<String, dynamic> data) async {
    await _kunjunganCollection.add(data);
  }

  Stream<QuerySnapshot> getKunjunganStream() {
    return _kunjunganCollection.snapshots();
  }

  Future<void> updateKunjungan(String id, Map<String, dynamic> data) async {
    await _kunjunganCollection.doc(id).update(data);
  }

  Future<void> hapusKunjungan(String id) async {
    await _kunjunganCollection.doc(id).delete();
  }
}
