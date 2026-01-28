import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

final authOutlineInputBorder = const OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFFD0D0D0)),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class KonfirmasiAlamat extends StatefulWidget {
  final String uid; // ID pelanggan
  final String orderId; // ID order
  final Map<String, dynamic>? existingAlamat; // alamat existing (opsional)
  const KonfirmasiAlamat({
    super.key,
    required this.uid,
    required this.orderId,
    this.existingAlamat,
  });

  @override
  State<KonfirmasiAlamat> createState() => _KonfirmasiAlamatState();
}

class _KonfirmasiAlamatState extends State<KonfirmasiAlamat> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jalanController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _alamatRingkasanController =
      TextEditingController();

  Map<String, dynamic> jabodetabek = {};
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  Marker? _marker;
  GoogleMapController? _mapController;
  bool _mapReady = false;
  bool _gettingLocation = false;
  bool _locationGranted = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  String? selectedProvinsi;
  String? selectedKota;
  String? selectedKecamatan;
  String? selectedKelurahan;

  bool get _controllerValid => mounted && _mapController != null && _mapReady;

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: const MarkerId('pos'),
      position: _currentPosition,
      draggable: true,
      onDragEnd: (p) => _currentPosition = p,
    );
    _initData();

    if (widget.existingAlamat != null) {
      _jalanController.text = widget.existingAlamat!['nama_jalan'] ?? '';
      _detailController.text = widget.existingAlamat!['detail_jalan'] ?? '';
      _alamatRingkasanController.text =
          "${widget.existingAlamat!['provinsi'] ?? ''}, ${widget.existingAlamat!['kota'] ?? ''}, ${widget.existingAlamat!['kecamatan'] ?? ''}, ${widget.existingAlamat!['kelurahan'] ?? ''}";
    }
  }

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

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await _loadJSON();
    await _checkLocationPermission();
    await _loadAlamatDariPelanggan();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _jalanController.dispose();
    _detailController.dispose();
    _alamatRingkasanController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadJSON() async {
    try {
      final data = await rootBundle.loadString('assets/jabodetabek.json');
      jabodetabek = json.decode(data);
    } catch (e) {
      jabodetabek = {};
      debugPrint('Gagal load JSON: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (mounted) {
        setState(() {
          _locationGranted =
              permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse;
        });
      }
    } catch (e) {
      debugPrint("Error check permission: $e");
    }
  }

  Future<void> _loadAlamatDariPelanggan() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('pelanggan')
          .doc(widget.uid)
          .get();

      if (!doc.exists) {
        print("Dokumen pelanggan tidak ditemukan");
        return;
      }

      final data = doc.data();
      if (data == null || data['alamat'] == null) {
        print("Data alamat kosong");
        return;
      }

      final alamat = Map<String, dynamic>.from(data['alamat']);
      final gmaps = alamat['gmaps'] != null
          ? Map<String, dynamic>.from(alamat['gmaps'])
          : {};

      // default jika gmaps kosong
      double lat = -6.200000;
      double lng = 106.816666;

      // parse string ke double
      if (gmaps['latitude'] != null) {
        lat = double.tryParse(gmaps['latitude'].toString()) ?? lat;
      }
      if (gmaps['longitude'] != null) {
        lng = double.tryParse(gmaps['longitude'].toString()) ?? lng;
      }

      setState(() {
        // isi form
        _jalanController.text = alamat['nama_jalan'] ?? '';
        _detailController.text = alamat['detail_jalan'] ?? '';
        selectedProvinsi = alamat['provinsi'] ?? '';
        selectedKota = alamat['kota'] ?? '';
        selectedKecamatan = alamat['kecamatan'] ?? '';
        selectedKelurahan = alamat['kelurahan'] ?? '';
        _updateAlamatRingkasan();

        // update posisi map & marker
        _currentPosition = LatLng(lat, lng);
        _marker = Marker(
          markerId: const MarkerId('pos'),
          position: _currentPosition,
          draggable: true,
          onDragEnd: (p) => _currentPosition = p,
        );
      });

      // pastikan kamera map menyesuaikan posisi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controllerValid) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_currentPosition, 16),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        showAwesomePopupAutoClose(
          title: "Gagal",
          message: "Gagal load alamat: $e",
          color: Colors.red,
          icon: Icons.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateAlamatRingkasan() {
    _alamatRingkasanController.text =
        "${selectedProvinsi ?? ''}\n"
        "${selectedKota ?? ''}\n"
        "${selectedKecamatan ?? ''}\n"
        "${selectedKelurahan ?? ''}";
  }

  String _gmapsLink() =>
      "https://www.google.com/maps?q=${_currentPosition.latitude},${_currentPosition.longitude}";

  Future<void> _ambilLokasiSaatIni() async {
    setState(() => _gettingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentPosition = newLatLng;
        _marker = Marker(
          markerId: const MarkerId("pos"),
          position: newLatLng,
          draggable: true,
          onDragEnd: (p) => _currentPosition = p,
        );
      });
      if (_controllerValid)
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(newLatLng, 16),
        );
    } catch (e) {
      showAwesomePopupAutoClose(
        title: "Gagal",
        message: "Gagal ambil lokasi: $e",
        color: Colors.red,
        icon: Icons.error,
      );
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  Future<void> _simpanAlamat() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedProvinsi == null ||
        selectedKota == null ||
        selectedKecamatan == null ||
        selectedKelurahan == null) {
      showAwesomePopupAutoClose(
        title: "Perhatian",
        message: "Lengkapi provinsi/kota/kecamatan/kelurahan",
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    // Ambil GPS
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
    });

    final alamatData = {
      'nama_jalan': _jalanController.text,
      'detail_jalan': _detailController.text,
      'provinsi': selectedProvinsi,
      'kota': selectedKota,
      'kecamatan': selectedKecamatan,
      'kelurahan': selectedKelurahan,
      'gmaps': {
        'latitude': pos.latitude.toString(),
        'longitude': pos.longitude.toString(),
        'link': "https://maps.google.com/?q=${pos.latitude},${pos.longitude}",
      },
    };

    Navigator.pop(context, alamatData);
  }

  Widget _field(
    String label, {
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Color(0xFF0C3345),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          color: Color(0xFF0C3345),
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
    );
  }

  Widget _alamatRingkasanWidget() {
    return TextFormField(
      controller: _alamatRingkasanController,
      readOnly: true,
      maxLines: 4,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0C3345),
        fontFamily: 'Poppins',
      ),
      onTap: () async {
        final result = await showModalBottomSheet<Map<String, String>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          builder: (context) => PilihAlamatSheet(
            jabodetabek: jabodetabek,
            selected: {
              'provinsi': selectedProvinsi ?? '',
              'kota': selectedKota ?? '',
              'kecamatan': selectedKecamatan ?? '',
              'kelurahan': selectedKelurahan ?? '',
            },
          ),
        );
        if (result != null) {
          setState(() {
            selectedProvinsi = result['provinsi'];
            selectedKota = result['kota'];
            selectedKecamatan = result['kecamatan'];
            selectedKelurahan = result['kelurahan'];
            _updateAlamatRingkasan();
          });
        }
      },
      decoration: InputDecoration(
        labelText: "Provinsi / Kota / Kecamatan / Kelurahan",
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          color: Color(0xFF0C3345),
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
        suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _openGmaps() async {
    final url = Uri.parse(_gmapsLink());
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Color(0xFF0C3345),
              strokeWidth: 3),
            ) // ⚡ Loading full screen
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // ================= HEADER =================
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE7E7E7),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF0C3345),
                                    size: 28
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Center(
                                  child: const Text(
                                    "Konfirmasi Alamat",
                                    style: TextStyle(
                                      color: Color(0xFF0C3345),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                      // ================= MAP =================
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 220,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition,
                              zoom: 15,
                            ),
                            markers: _marker != null ? {_marker!} : {},
                            onMapCreated: (ctrl) {
                              _mapController = ctrl;
                              _mapReady = true;
                              if (_controllerValid)
                                _mapController!.moveCamera(
                                  CameraUpdate.newLatLngZoom(
                                    _currentPosition,
                                    16,
                                  ),
                                );
                            },
                            onTap: (pos) {
                              setState(() {
                                _currentPosition = pos;
                                _marker = Marker(
                                  markerId: const MarkerId('pos'),
                                  position: pos,
                                  draggable: true,
                                  onDragEnd: (newPos) =>
                                      _currentPosition = newPos,
                                );
                              });
                            },
                            myLocationEnabled: _locationGranted,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _gettingLocation
                                  ? null
                                  : _ambilLokasiSaatIni,
                              icon: _gettingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0C3345),
                                        strokeWidth: 3,
                                    
                                      ),
                                    )
                                  : const Icon(Icons.my_location),
                              label: const Text('Lokasi Saat Ini'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0C3345),
                                side: const BorderSide(
                                  color: Color(0xFFD0D0D0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _openGmaps,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0C3345),
                              side: const BorderSide(color: Color(0xFFD0D0D0)),
                            ),
                            child: const Icon(Icons.open_in_new),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: _gmapsLink()),
                              );
                                showAwesomePopupAutoClose(
                                  title: "Berhasil",
                                  message: "Link disalin",
                                  color: Colors.green,
                                  icon: Icons.check_circle,
                                );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0C3345),
                              side: const BorderSide(color: Color(0xFFD0D0D0)),
                            ),
                            child: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _field(
                        'Nama Jalan / Gedung / No.Rumah',
                        controller: _jalanController,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        'Detail Lainnya (Blok / Patokan)',
                        controller: _detailController,
                      ),
                      const SizedBox(height: 14),
                      _alamatRingkasanWidget(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _simpanAlamat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C3345),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Simpan Alamat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ===================== PilihAlamatSheet =====================
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
    provinsi = widget.selected?['provinsi']?.isNotEmpty ?? false
        ? widget.selected!['provinsi']
        : null;
    kota = widget.selected?['kota']?.isNotEmpty ?? false
        ? widget.selected!['kota']
        : null;
    kecamatan = widget.selected?['kecamatan']?.isNotEmpty ?? false
        ? widget.selected!['kecamatan']
        : null;
    kelurahan = widget.selected?['kelurahan']?.isNotEmpty ?? false
        ? widget.selected!['kelurahan']
        : null;
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
        if (kecData is List) return List<String>.from(kecData);
      }
    }
    return [];
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0C3345),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
        suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Color(0xFF0C3345),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            // PROVINSI
            buildDropdown(
              label: "Provinsi",
              value: provinsi,
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
            // KOTA
            if (provinsi != null)
              buildDropdown(
                label: "Kota/Kabupaten",
                value: kota,
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
            // KECAMATAN
            if (provinsi != null && kota != null)
              buildDropdown(
                label: "Kecamatan",
                value: kecamatan,
                items: _getKecamatanList(provinsi!, kota!),
                onChanged: (val) {
                  setState(() {
                    kecamatan = val;
                    kelurahan = null;
                  });
                },
              ),
            const SizedBox(height: 14),
            // KELURAHAN
            if (provinsi != null && kota != null && kecamatan != null)
              buildDropdown(
                label: "Kelurahan",
                value: kelurahan,
                items: _getKelurahanList(provinsi!, kota!, kecamatan!),
                onChanged: (val) => setState(() => kelurahan = val),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    (provinsi != null &&
                        kota != null &&
                        kecamatan != null &&
                        kelurahan != null)
                    ? () {
                        Navigator.pop(context, {
                          "provinsi": provinsi!,
                          "kota": kota!,
                          "kecamatan": kecamatan!,
                          "kelurahan": kelurahan!,
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
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
