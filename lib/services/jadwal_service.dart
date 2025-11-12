import 'package:cloud_firestore/cloud_firestore.dart';

class JadwalService {
  final CollectionReference _jadwalCollection =
      FirebaseFirestore.instance.collection('jadwal');

  Future<void> tambahJadwal(Map<String, dynamic> data) async {
    await _jadwalCollection.add(data);
  }

  Stream<QuerySnapshot> getJadwalStream() {
    return _jadwalCollection.snapshots();
  }

  Future<void> updateJadwal(String id, Map<String, dynamic> data) async {
    await _jadwalCollection.doc(id).update(data);
  }

  Future<void> hapusJadwal(String id) async {
    await _jadwalCollection.doc(id).delete();
  }
}
