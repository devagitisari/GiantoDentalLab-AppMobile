import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:team_project/screens/home-page.dart';

final authOutlineInputBorder = const OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFD0D0D0)),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class IsiAlamatWithMap extends StatefulWidget {
  final String uid;
  final bool isNewAccount;
  const IsiAlamatWithMap({
    super.key,
    required this.uid,
    this.isNewAccount = false,
  });

  @override
  State<IsiAlamatWithMap> createState() => _IsiAlamatWithMapState();
}

class _IsiAlamatWithMapState extends State<IsiAlamatWithMap> {
  final _formKey = GlobalKey<FormState>();
  final _jalanController = TextEditingController();
  final _detailController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  Marker? _marker;

  void showAwesomePopupAutoClose({
    required String title,
    required String message,
    Color color = const Color(0xFF0C3345),
    IconData icon = Icons.check_circle,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        // Auto close dialog setelah 1.2 detik
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(icon, color: color, size: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> checkAndRequestGPS(BuildContext context) async {
    // Cek apakah layanan lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      bool? openSettings = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("GPS Tidak Aktif"),
            content: const Text(
              "Untuk mengambil lokasi, aktifkan GPS terlebih dahulu.",
            ),
            actions: [
              TextButton(
                child: const Text("Batal"),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text("Nyalakan GPS"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          );
        },
      );

      if (openSettings == true) {
        await Geolocator.openLocationSettings();
        bool serviceEnabledAfter = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabledAfter) {
          await _ambilLokasiSaatIni();
          return true;
        }
      }
    }

    // Cek permission GPS
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  bool _isLoading = false;
  bool _gettingLocation = false;

  Map<String, dynamic> jabodetabek = {};
  String? selectedProvinsi;
  String? selectedKota;
  String? selectedKecamatan;
  String? selectedKelurahan;

  @override
  void initState() {
    super.initState();
    _loadJSON();
    _marker = Marker(
      markerId: const MarkerId('pos'),
      position: _currentPosition,
      draggable: true,
      onDragEnd: (newPos) => setState(() => _currentPosition = newPos),
    );

    if (widget.isNewAccount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAwesomePopupAutoClose(
          title: "Berhasil!",
          message: "Akun berhasil dibuat",
          icon: Icons.check_circle,
          color: Colors.green,
        );
      });
    }
  }

  @override
  void dispose() {
    _jalanController.dispose();
    _detailController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadJSON() async {
    final data = await rootBundle.loadString('assets/jabodetabek.json');
    setState(() => jabodetabek = json.decode(data));
  }

  String _gmapsLink() =>
      "https://www.google.com/maps?q=${_currentPosition.latitude},${_currentPosition.longitude}";

  Future<void> _openGmaps() async {
    final url = Uri.parse(_gmapsLink());
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Tidak bisa membuka Google Maps",
        icon: Icons.error,
        color: Colors.red,
      );
    }
  }

  Future<void> _copyGmapsLink() async {
    await Clipboard.setData(ClipboardData(text: _gmapsLink()));
    showAwesomePopupAutoClose(
      title: "Disalin",
      message: "Link lokasi berhasil disalin",
      icon: Icons.copy,
      color: Colors.blue,
    );
  }

  Future<void> _ambilLokasiSaatIni() async {
    setState(() => _gettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showAwesomePopupAutoClose(
          title: "GPS Off",
          message: "GPS tidak aktif. Aktifkan terlebih dahulu.",
          icon: Icons.location_off,
          color: Colors.orange,
        );
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          showAwesomePopupAutoClose(
            title: "Izin Ditolak",
            message: "Izin lokasi ditolak oleh pengguna.",
            icon: Icons.warning,
            color: Colors.orange,
          );
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newLatLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _currentPosition = newLatLng;
        _marker = Marker(
          markerId: const MarkerId('pos'),
          position: newLatLng,
          draggable: true,
          onDragEnd: (newPos) => _currentPosition = newPos,
        );
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 16));
      showAwesomePopupAutoClose(
        title: "Berhasil",
        message: "Lokasi berhasil diperbarui",
        icon: Icons.check_circle,
        color: Colors.green,
      );
    } catch (e) {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Gagal mengambil lokasi: $e",
        icon: Icons.error,
        color: Colors.red,
      );
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedProvinsi == null ||
        selectedKota == null ||
        selectedKecamatan == null ||
        selectedKelurahan == null) {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Harap lengkapi alamat terlebih dahulu",
        icon: Icons.warning_rounded,
        color: Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection("pelanggan").doc(widget.uid);

      final docSnapshot = await docRef.get();

      final alamatData = {
        "detail_jalan": _detailController.text,
        "nama_jalan": _jalanController.text,
        "provinsi": selectedProvinsi,
        "kota": selectedKota,
        "kecamatan": selectedKecamatan,
        "kelurahan": selectedKelurahan,
        "gmaps": {
          "latitude": _currentPosition.latitude.toString(),
          "longitude": _currentPosition.longitude.toString(),
          "link": _gmapsLink(),
        },
      };

      if (docSnapshot.exists) {
        // Update data yang sudah ada
        await docRef.update({
          "alamat": alamatData,
          "updated_at": FieldValue.serverTimestamp(),
        });
      } else {
        // Buat dokumen baru kalau belum ada
        await docRef.set({
          "alamat": alamatData,
          "created_at": FieldValue.serverTimestamp(),
          "updated_at": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      // Popup sukses
      showAwesomePopupAutoClose(
        title: "Berhasil!",
        message: "Pilihan berhasil disimpan",
        icon: Icons.check_circle,
        color: Colors.green,
      );

      // Setelah popup hilang → ke HomePage
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage(uid: widget.uid)),
          (route) => false,
        );
      });
    } catch (e) {
      if (!mounted) return;
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Terjadi kesalahan: $e",
        icon: Icons.error,
        color: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Widget _field(
    String label, {
    TextEditingController? controller,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Color(0xFF0C3345),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color(0xFF0C3345),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder.copyWith(
          borderSide: const BorderSide(color: Color(0xFF0C3345)),
        ),
      ),
      validator: validator,
    );
  }

  Widget _alamatRingkasan() {
    String displayText() {
      List<String> parts = [];
      if (selectedProvinsi != null) parts.add(selectedProvinsi!);
      if (selectedKota != null) parts.add(selectedKota!);
      if (selectedKecamatan != null) parts.add(selectedKecamatan!);
      if (selectedKelurahan != null) parts.add(selectedKelurahan!);
      return parts.join(",\n");
    }

    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<Map<String, String>>(
          context: context,
          isScrollControlled: true,
          builder: (context) => PilihAlamatSheet(
            jabodetabek: jabodetabek,
            selected: {
              "provinsi": selectedProvinsi ?? "",
              "kota": selectedKota ?? "",
              "kecamatan": selectedKecamatan ?? "",
              "kelurahan": selectedKelurahan ?? "",
            },
          ),
        );

        if (result != null) {
          setState(() {
            selectedProvinsi = result['provinsi'];
            selectedKota = result['kota'];
            selectedKecamatan = result['kecamatan'];
            selectedKelurahan = result['kelurahan'];
          });

          // Simpan ke Firebase karena user sudah login
          await FirebaseFirestore.instance
              .collection("pelanggan")
              .doc(widget.uid)
              .set({
                "alamat": {
                  "detail_jalan": _detailController.text,
                  "nama_jalan": _jalanController.text,
                  "provinsi": selectedProvinsi,
                  "kota": selectedKota,
                  "kecamatan": selectedKecamatan,
                  "kelurahan": selectedKelurahan,
                  "gmaps": {
                    "latitude": _currentPosition.latitude.toString(),
                    "longitude": _currentPosition.longitude.toString(),
                    "link": _gmapsLink(),
                  },
                },
                "updated_at": FieldValue.serverTimestamp(), // <<< ini di root
              }, SetOptions(merge: true));


          showAwesomePopupAutoClose(
            title: "Berhasil",
            message: "Alamat berhasil ditambahkan",
            icon: Icons.check_circle,
            color: Colors.green,
          );
        }

        if (result != null) {
          setState(() {
            selectedProvinsi = result['provinsi'];
            selectedKota = result['kota'];
            selectedKecamatan = result['kecamatan'];
            selectedKelurahan = result['kelurahan'];
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD0D0D0)),
        ),
        child: Text(
          selectedProvinsi == null ? "Pilih Provinsi" : displayText(),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0C3345),
            fontFamily: 'Poppins',
          ),
          softWrap: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // AppBar
                // Ganti row AppBar jadi Column biar bisa atur jarak atas
                Column(
                  children: [
                    const SizedBox(height: 24), // ⚡ jarak dari atas layar
                    Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE7E7E7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Center(
                            // ⚡ center horizontal
                            child: Text(
                              "Isi Alamat",
                              style: const TextStyle(
                                color: Color(0xFF0C3345),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 48,
                        ), // ⚡ supaya icon back punya ruang kanan
                      ],
                    ),
                    const SizedBox(height: 16), // ⚡ jarak bawah judul ke form
                  ],
                ),

                const SizedBox(height: 12),

                // Google Map
                Container(
                  height: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD0D0D0)),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition,
                      zoom: 15,
                    ),
                    markers: _marker != null ? {_marker!} : {},
                    onMapCreated: (c) => _mapController = c,
                    onTap: (pos) {
                      setState(() {
                        _currentPosition = pos;
                        _marker = Marker(
                          markerId: const MarkerId('pos'),
                          position: pos,
                          draggable: true,
                          onDragEnd: (newPos) => _currentPosition = newPos,
                        );
                      });
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _gettingLocation
                            ? null
                            : () async {
                                if (await checkAndRequestGPS(context)) {
                                  _ambilLokasiSaatIni();
                                }
                              },
                        icon: _gettingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0C3345),
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: const Text("Ambil Lokasi Saat Ini"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0C3345),
                          side: const BorderSide(color: Color(0xFFD0D0D0)),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    OutlinedButton(
                      onPressed: _openGmaps,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0C3345),
                        side: const BorderSide(color: Color(0xFFD0D0D0)),
                        minimumSize: const Size(48, 48),
                      ),
                      child: const Icon(Icons.open_in_new),
                    ),

                    const SizedBox(width: 8),

                    OutlinedButton(
                      onPressed: _copyGmapsLink,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0C3345),
                        side: const BorderSide(color: Color(0xFFD0D0D0)),
                        minimumSize: const Size(48, 48),
                      ),
                      child: const Icon(Icons.copy),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                _field(
                  "Nama Jalan / Gedung / No Rumah",
                  controller: _jalanController,
                  validator: (v) => (v == null || v.isEmpty)
                      ? "Nama jalan wajib diisi"
                      : null,
                ),
                const SizedBox(height: 12),
                _field(
                  "Detail Lainnya (Blok / Patokan)",
                  controller: _detailController,
                ),
                const SizedBox(height: 12),
                _alamatRingkasan(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpanData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3345),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text("Simpan Alamat"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(uid: widget.uid),
                        ),
                        (route) => false, // hapus semua route sebelumnya
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0C3345)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Lewati",
                      style: TextStyle(
                        color: Color(0xFF0C3345),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// PilihAlamatSheet tetap sama, sudah aman
class PilihAlamatSheet extends StatefulWidget {
  final Map<String, dynamic> jabodetabek;
  final Map<String, String>? selected;
  const PilihAlamatSheet({super.key, required this.jabodetabek, this.selected});

  @override
  State<PilihAlamatSheet> createState() => _PilihAlamatSheetState();
}

class _PilihAlamatSheetState extends State<PilihAlamatSheet> {
  String? provinsi;
  String? kota;
  String? kecamatan;
  String? kelurahan;

  @override
  void initState() {
    super.initState();
    provinsi = widget.selected?['provinsi'];
    kota = widget.selected?['kota'];
    kecamatan = widget.selected?['kecamatan'];
    kelurahan = widget.selected?['kelurahan'];
  }

  List<String> _getKotaList(String prov) {
    final data = widget.jabodetabek[prov];
    if (data is Map<String, dynamic>) return data.keys.toList();
    return [];
  }

  List<String> _getKecamatanList(String prov, String kot) {
    final data = widget.jabodetabek[prov];
    if (data is Map<String, dynamic>) {
      final kotaData = data[kot];
      if (kotaData is Map<String, dynamic>) return kotaData.keys.toList();
    }
    return [];
  }

  List<String> _getKelurahanList(String prov, String kot, String kec) {
    final data = widget.jabodetabek[prov];
    if (data is Map<String, dynamic>) {
      final kotaData = data[kot];
      if (kotaData is Map<String, dynamic>) {
        final kecData = kotaData[kec];
        if (kecData is List) return kecData.map((e) => e.toString()).toList();
        if (kecData is Map<String, dynamic>) return kecData.keys.toList();
      }
    }
    return [];
  }

  String? _getValidValue(String? currentValue, List<String> validList) {
    if (currentValue != null && validList.contains(currentValue)) {
      return currentValue;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // --- Handle Modal Sheet Indicator ---
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 20),

          // ===============================
          //            PROVINSI
          // ===============================
          buildDropdown(
            label: "Provinsi",
            value: _getValidValue(provinsi, widget.jabodetabek.keys.toList()),
            items: widget.jabodetabek.keys.toList(),
            onChanged: (val) {
              setState(() {
                provinsi = val;
                kota = null;
                kecamatan = null;
                kelurahan = null;
              });
            },
          ),

          const SizedBox(height: 14),

          // ===============================
          //            KOTA
          // ===============================
          if (provinsi != null)
            buildDropdown(
              label: "Kota / Kabupaten",
              value: _getValidValue(kota, _getKotaList(provinsi!)),
              items: _getKotaList(provinsi!),
              onChanged: (val) {
                setState(() {
                  kota = val;
                  kecamatan = null;
                  kelurahan = null;
                });
              },
            ),

          const SizedBox(height: 14),

          // ===============================
          //           KECAMATAN
          // ===============================
          if (provinsi != null && kota != null)
            buildDropdown(
              label: "Kecamatan",
              value: _getValidValue(
                kecamatan,
                _getKecamatanList(provinsi!, kota!),
              ),
              items: _getKecamatanList(provinsi!, kota!),
              onChanged: (val) {
                setState(() {
                  kecamatan = val;
                  kelurahan = null;
                });
              },
            ),

          const SizedBox(height: 14),

          // ===============================
          //           KELURAHAN
          // ===============================
          if (provinsi != null && kota != null && kecamatan != null)
            buildDropdown(
              label: "Kelurahan",
              value: _getValidValue(
                kelurahan,
                _getKelurahanList(provinsi!, kota!, kecamatan!),
              ),
              items: _getKelurahanList(provinsi!, kota!, kecamatan!),
              onChanged: (val) {
                setState(() {
                  kelurahan = val;
                });
              },
            ),

          const SizedBox(height: 24),

          // ===============================
          //           BUTTON SIMPAN
          // ===============================
          SizedBox(
            width: double.infinity,
            height: 48, // tinggi sama kaya tombol lain
            child: ElevatedButton(
              onPressed: (provinsi != null &&
                      kota != null &&
                      kecamatan != null &&
                      kelurahan != null)
                  ? () {
                      Navigator.pop(context, {
                        "provinsi": provinsi ?? "",
                        "kota": kota ?? "",
                        "kecamatan": kecamatan ?? "",
                        "kelurahan": kelurahan ?? "",
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C3345),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Simpan Pilihan",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // =====================================================================
  //            HELPER: REUSABLE DROPDOWN
  // =====================================================================
  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color(0xFF0C3345),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder.copyWith(
          borderSide: const BorderSide(color: Color(0xFF0C3345)),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Color(0xFF0C3345),
      ),
    );
  }
}
