import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailGaransiPage extends StatefulWidget {
  final String idGaransi;
  final String? uid;

  const DetailGaransiPage({super.key, required this.idGaransi, this.uid});

  @override
  State<DetailGaransiPage> createState() => _DetailGaransiPageState();
}

class _DetailGaransiPageState extends State<DetailGaransiPage> {
  // Lokasi Lab
  static const LatLng lokasiLab = LatLng(-6.40558942648654, 106.73571728605837);

  Map<String, dynamic>? alamatRingkas;
  Map<String, dynamic>? garansiData;
  Map<String, dynamic>? infoKunjungan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getGaransiDetail();
  }

  Future<void> _getGaransiDetail() async {
    try {
      final garansiDoc = await FirebaseFirestore.instance
          .collection('garansi')
          .doc(widget.idGaransi)
          .get();

      if (!garansiDoc.exists) return;

      final dataGaransi = garansiDoc.data()!;
      final idOrder = dataGaransi['id_order'];

      final orderDoc = await FirebaseFirestore.instance
          .collection('order')
          .doc(idOrder)
          .get();

      if (!orderDoc.exists) return;

      // Ambil jadwal kunjungan
      final jadwalQuery = await FirebaseFirestore.instance
          .collection('jadwal')
          .where('id_order', isEqualTo: idOrder)
          .limit(1)
          .get();

      if (jadwalQuery.docs.isNotEmpty) {
        final jadwalData = jadwalQuery.docs.first.data();
        final idJadwal = jadwalData['id_jadwal'];

        final kunjunganQuery = await FirebaseFirestore.instance
            .collection('kunjungan')
            .where('id_jadwal', isEqualTo: idJadwal)
            .where('aktivitas', isEqualTo: 'Kunjungan Garansi')
            .limit(1)
            .get();

        if (kunjunganQuery.docs.isNotEmpty) {
          infoKunjungan = kunjunganQuery.docs.first.data();
        }
      }

      // Jenis pelayanan
      String namaPelayanan = "-";
      final idPelayanan = dataGaransi['id_pelayanan'];
      if (idPelayanan != null) {
        final q = await FirebaseFirestore.instance
            .collection('pelayanan')
            .where('id_pelayanan', isEqualTo: idPelayanan)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          namaPelayanan = q.docs.first['nama_pelayanan'] ?? "-";
        }
      }

      alamatRingkas = dataGaransi['alamat_konfirmasi'];
      garansiData = {
        "nama_garansi": dataGaransi['nama_garansi'] ?? "-",
        "jenis_pelayanan": namaPelayanan,
        "keluhan": dataGaransi['keluhan'] ?? "-",
        "status": dataGaransi['status'] ?? "menunggu",
      };
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatTanggal(dynamic tgl) {
    if (tgl == null) return "-";
    if (tgl is Timestamp) return DateFormat('dd MMMM yyyy', 'id_ID').format(tgl.toDate());
    if (tgl is String) {
      try {
        final date = DateFormat('dd/MM/yyyy').parse(tgl);
        return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
      } catch (_) {
        return "-";
      }
    }
    return "-";
  }

  String _formatJam(dynamic jam) {
    if (jam == null) return "-";
    if (jam is Timestamp) return DateFormat('HH:mm').format(jam.toDate());
    if (jam is String) return jam;
    return "-";
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Null-safe gmaps
    final Map<String, dynamic>? gmaps =
        (alamatRingkas != null && alamatRingkas!['gmaps'] != null)
            ? Map<String, dynamic>.from(alamatRingkas!['gmaps'])
            : null;

    // Kalau gmaps null, pakai lokasi lab
    final bool isKunjunganLab = gmaps == null;
    final LatLng lokasi =
        isKunjunganLab ? lokasiLab : LatLng(_toDouble(gmaps['latitude']), _toDouble(gmaps['longitude']));

    final String alamatText = isKunjunganLab
        ? "Lokasi Gianto Dental Lab"
        : "${alamatRingkas!['nama_jalan'] ?? '-'} (${alamatRingkas!['detail_jalan'] ?? '-'})\n"
          "${alamatRingkas!['kelurahan'] ?? '-'}, ${alamatRingkas!['kecamatan'] ?? '-'}, "
          "${alamatRingkas!['kota'] ?? '-'}, ${alamatRingkas!['provinsi'] ?? '-'}.";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0C3345),
                  strokeWidth: 3,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE7E7E7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back, color: Color(0xFF0C3345), size: 28),
                            )
                        ),
                        const Expanded(
                          child: Text(
                            "Detail Garansi",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Color(0xFF0C3345) ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Nama Garansi", garansiData?['nama_garansi']),
                          _infoRow("Jenis Pelayanan", garansiData?['jenis_pelayanan']),
                          _infoRow("Keluhan", garansiData?['keluhan']),
                          const SizedBox(height: 16),

                          // MAP
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alamatText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0C3345),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 180,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GoogleMap(
                                      liteModeEnabled: true,
                                      initialCameraPosition: CameraPosition(target: lokasi, zoom: 16),
                                      markers: {
                                        Marker(markerId: const MarkerId("lokasi"), position: lokasi),
                                      },
                                      zoomControlsEnabled: false,
                                      myLocationButtonEnabled: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // STATUS
                          _pesanStatusKunjungan(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }

  Widget _pesanStatusKunjungan() {
    final status = (garansiData?['status'] ?? 'menunggu').toString().toLowerCase();
    final jadwal = infoKunjungan?['jadwal_kunjungan'] as Map<String, dynamic>?;

    String title;
    String message;
    IconData icon;
    Color color;

    if (status == 'dijadwalkan') {
      title = "Kunjungan Dijadwalkan";
      message = "Kunjungan garansi dijadwalkan pada "
          "${_formatTanggal(jadwal?['tanggal'])} pukul "
          "${_formatJam(jadwal?['jam_mulai'])} – ${_formatJam(jadwal?['jam_selesai'])}.";
      icon = Icons.event_available;
      color = Colors.orange;
    } else if (status == 'selesai') {
      title = "Kunjungan Selesai";
      message = "Kunjungan garansi telah selesai dilakukan.";
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else {
      title = "Menunggu Konfirmasi";
      message = "Permintaan kunjungan garansi sedang diproses. Silakan menunggu konfirmasi jadwal.";
      icon = Icons.hourglass_bottom;
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
