import 'package:cloud_firestore/cloud_firestore.dart';

class PelangganService {
  final CollectionReference _pelangganCollection =
      FirebaseFirestore.instance.collection('pelanggan');

  // Tambah data pelanggan
  Future<void> tambahPelanggan(Map<String, dynamic> data) async {
    await _pelangganCollection.add(data);
  }

  // Ambil semua pelanggan
  Stream<QuerySnapshot> getPelangganStream() {
    return _pelangganCollection.snapshots();
  }

  // Update data pelanggan
  Future<void> updatePelanggan(String id, Map<String, dynamic> data) async {
    await _pelangganCollection.doc(id).update(data);
  }

  // Hapus data pelanggan
  Future<void> hapusPelanggan(String id) async {
    await _pelangganCollection.doc(id).delete();
  }
}
