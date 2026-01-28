import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JadwalKunjunganPage extends StatefulWidget {
  final String idPelanggan;
  final Map<String, dynamic>? selectedJadwal; // dari HomePage

  const JadwalKunjunganPage({
    super.key,
    required this.idPelanggan,
    this.selectedJadwal,
  });

  @override
  _JadwalKunjunganPageState createState() => _JadwalKunjunganPageState();
}

class _JadwalKunjunganPageState extends State<JadwalKunjunganPage> {
  List<Map<String, dynamic>> kunjungan = [];
  bool isLoading = true;
  DateTime selectedMonth = DateTime.now();
  DateTime? selectedDate;

  // Key untuk scroll presisi
  Map<int, GlobalKey> cardKeys = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.selectedJadwal != null) {
      try {
        selectedDate = DateFormat(
          "dd/MM/yyyy",
        ).parse(widget.selectedJadwal!['tanggal'].toString().trim());
        selectedMonth = DateTime(selectedDate!.year, selectedDate!.month, 1);
      } catch (_) {
        selectedDate = null;
      }
    }

    _fetchKunjungan();
  }

  List<Map<String, dynamic>> get filteredKunjungan {
    if (selectedDate != null) {
      return kunjungan.where((k) {
        final tanggal = k['tanggal'] as DateTime;
        return tanggal.year == selectedDate!.year &&
              tanggal.month == selectedDate!.month &&
              tanggal.day == selectedDate!.day;
      }).toList();
    } else {
      return kunjungan; // tampilkan semua
    }
  }

  Future<void> _fetchKunjungan() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Ambil semua order milik pelanggan
      final orderSnap = await firestore
          .collection('order')
          .where('id_pelanggan', isEqualTo: widget.idPelanggan)
          .get();

      if (orderSnap.docs.isEmpty) {
        setState(() {
          kunjungan = [];
          isLoading = false;
        });
        return;
      }

      // Ambil referensi layanan dan pelayanan
      final layananSnap = await firestore.collection('layanan').get();
      final pelayananSnap = await firestore.collection('pelayanan').get();

      final layananMap = {
        for (var doc in layananSnap.docs) doc['id_layanan']: doc['nama_layanan']
      };
      final pelayananMap = {
        for (var doc in pelayananSnap.docs) doc['id_pelayanan']: doc['nama_pelayanan']
      };

      List<Map<String, dynamic>> dataList = [];
      List<Future<void>> futures = [];

      for (var orderDoc in orderSnap.docs) {
        futures.add(() async {
          final orderData = orderDoc.data();
          final idOrder = orderDoc.id;
          
          final statusOrder = (orderData['status'] ?? '').toString().toLowerCase();
          if (statusOrder == 'dibatalkan') return;
          
          final idPelayanan = orderData['id_pelayanan'] ?? "";
          final idLayanan = orderData['id_layanan'] ?? "";

          final jadwalSnap = await firestore
              .collection('jadwal')
              .where('id_order', isEqualTo: idOrder)
              .get();

          for (var jadwalDoc in jadwalSnap.docs) {
            final idJadwal = jadwalDoc.id;

            final kunjunganSnap = await firestore
                .collection('kunjungan')
                .where('id_jadwal', isEqualTo: idJadwal)
                .get();

            for (var kunjunganDoc in kunjunganSnap.docs) {
              final kunjunganData = kunjunganDoc.data();
              final idKunjungan = kunjunganDoc.id;

              // Ambil tanggal & jam dari map 'jadwal_kunjungan'
              final Map<String, dynamic> jadwalKunjungan =
                  kunjunganData['jadwal_kunjungan'] ?? {};

              final rawTanggal = jadwalKunjungan['tanggal'] ?? '';
              final jamMulai = jadwalKunjungan['jam_mulai'] ?? '00:00';
              final jamSelesai = jadwalKunjungan['jam_selesai'] ?? '00:00';

              DateTime tanggal;
              try {
                tanggal = DateFormat("dd/MM/yyyy").parse(rawTanggal);
              } catch (_) {
                tanggal = DateTime.now();
              }

              dataList.add({
                "id_kunjungan": idKunjungan,
                "tanggal": tanggal,
                "jam": "$jamMulai - $jamSelesai WIB",
                "judul": kunjunganData['aktivitas'] ??
                    orderData['aktivitas'] ??
                    'Kunjungan',
                "deskripsi": kunjunganData['keterangan'] ?? '',
                "status": kunjunganData['status'] ?? orderData['status'] ?? '',
                "nama_pelayanan":
                    idPelayanan != "" ? (pelayananMap[idPelayanan] ?? "") : "",
                "nama_layanan":
                    idLayanan != "" ? (layananMap[idLayanan] ?? "") : "",
              });
            }
          }
        }());
      }

      // Tunggu semua futures selesai
      await Future.wait(futures);

      // Urutkan dari tanggal terbaru
      dataList.sort((a, b) => (b['tanggal'] as DateTime)
          .compareTo(a['tanggal'] as DateTime));

      setState(() {
        kunjungan = dataList;
        isLoading = false;
      });

      if (selectedDate != null) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedDate();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        kunjungan = [];
        isLoading = false;
      });
    }
  }


  // Tambahkan fungsi untuk pilih bulan
  Future<void> _pickMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      helpText: "Pilih Bulan",
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month, 1);
        selectedDate = null; // reset selected date
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "dijadwalkan":
        return Colors.orange.shade400;
      case "selesai":
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  List<int> _datesWithKunjungan() {
    return kunjungan
        .where((k) {
          final tanggal = k["tanggal"];
          return tanggal != null &&
              tanggal is DateTime &&
              tanggal.month == selectedMonth.month &&
              tanggal.year == selectedMonth.year;
        })
        .map((k) => (k["tanggal"] as DateTime).day)
        .toList();
  }

  void _prevMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
      selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      // maju 1 bulan dengan aman
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
      selectedDate = null;
    });
  }

  void _scrollToSelectedDate() {
    if (selectedDate == null) return;

    int index = kunjungan.indexWhere(
      (k) =>
          (k['tanggal'] as DateTime).day == selectedDate!.day &&
          (k['tanggal'] as DateTime).month == selectedDate!.month &&
          (k['tanggal'] as DateTime).year == selectedDate!.year,
    );

    final context = cardKeys[index]?.currentContext;
    if (index != -1 && context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = "id_ID";
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(
            color: Color(0xFF0C3345),
            strokeWidth: 3,))
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
                    child: SizedBox(
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Center(
                            child: Text(
                              "Jadwal Kunjungan",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0C3345),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 6,
                              ), // 👉 geser kanan dikit
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE7E7E7),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF0C3345),
                                    size: 28
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Kalender
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _prevMonth,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.chevron_left),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _pickMonth, // ini tambahan
                                  child: Text(
                                    DateFormat(
                                      'MMMM yyyy',
                                      'id_ID',
                                    ).format(selectedMonth),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF0C3345),
                                      // opsional biar keliatan clickable
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _nextMonth,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.chevron_right),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            _buildCalendarGrid(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                kunjungan.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "Tidak ada kunjungan",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = filteredKunjungan[index];
                          cardKeys[index] ??= GlobalKey();

                          // Cek apakah ini tanggal yang dipilih
                          bool isSelected =
                              selectedDate != null &&
                              item["tanggal"].day == selectedDate!.day &&
                              item["tanggal"].month == selectedDate!.month &&
                              item["tanggal"].year == selectedDate!.year;

                          return Container(
                            key: cardKeys[index],
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [Color(0xFF1D7EAB), Color(0xFF0C3345)]
                                    : [Color(0xFF0C3345), Color(0xFF1D7EAB)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tanggal & Jam
                                Container(
                                  height: 23,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            size: 17,
                                            color: Color(0xFF0C3345),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            DateFormat(
                                              "d MMMM yyyy",
                                              "id_ID",
                                            ).format(item["tanggal"]),
                                            style: const TextStyle(
                                              color: Color(0xFF0C3345),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 17,
                                            color: Color(0xFF0C3345),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            item["jam"] ?? "00:00 - 00:00 WIB",
                                            style: const TextStyle(
                                              color: Color(0xFF0C3345),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Judul & Deskripsi
                               Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        item["judul"] ?? "Kunjungan",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        item["deskripsi"] ?? "-",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false, // penting biar tidak wrap
                                      ),
                                    ),
                                  ],
                                ),


                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        item["nama_layanan"] ?? "-",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w200,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        "|",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Text(
                                        item["nama_pelayanan"] ?? "-",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w200,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: 80,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(item["status"] ?? ""),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item["status"] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: filteredKunjungan.length),
                      ),
              ],
            ),
    );
  }

  Widget _buildCalendarGrid() {
    int daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    ).day;
    int startWeekday = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    ).weekday;
    List<int> highlightDays = _datesWithKunjungan();
    DateTime today = DateTime.now();

    List<Widget> rows = [];

    // Header nama hari
    final List<String> weekdays = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];
    rows.add(
      Row(
        children: weekdays
            .map(
              (day) => Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );

    List<Widget> cells = [];

    // Cell kosong sebelum tanggal 1
    for (int i = 1; i < startWeekday; i++) {
      cells.add(Expanded(child: SizedBox.shrink()));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      bool hasKunjungan = highlightDays.contains(day);
      bool isSelected = selectedDate?.day == day;
      bool isToday =
          today.day == day &&
          today.month == selectedMonth.month &&
          today.year == selectedMonth.year;

      cells.add(
        Expanded(
          child: AspectRatio(
            aspectRatio: 1, // biar kotak
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = DateTime(
                    selectedMonth.year,
                    selectedMonth.month,
                    day,
                  );
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToSelectedDate();
                });
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFF1D7EAB)
                      : hasKunjungan
                      ? Color(0xFF0C3345)
                      : Colors.grey.shade200,
                  border: isToday
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$day",
                  style: TextStyle(
                    color: isSelected || hasKunjungan
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      if ((cells.length % 7 == 0) || day == daysInMonth) {
        while (cells.length < 7) {
          cells.add(Expanded(child: SizedBox.shrink())); // pad sisa cell
        }
        rows.add(Row(children: cells));
        cells = [];
      }
    }

    return Column(children: rows);
  }

  // ===========================
  // WIDGET LIST KUNJUNGAN
  // ===========================
  Widget buildKunjunganList() {
    if (kunjungan.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada Kunjungan",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: kunjungan.length,
      itemBuilder: (context, index) {
        final item = kunjungan[index];
        String tanggal = DateFormat(
          "d MMMM yyyy",
          "id_ID",
        ).format(item["tanggal"]);

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Color(0xFF0C3345), Color(0xFF1D7EAB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Tanggal & Jam ----------
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tanggal,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),

                    Spacer(),

                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item["jam"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ---------- Judul ----------
                Text(
                  item["judul"],
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                // ---------- Deskripsi ----------
                Text(
                  item["deskripsi"],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                // ---------- Status ----------
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item["status"]?.toUpperCase() ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
