import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JadwalKunjunganPage extends StatefulWidget {
  @override
  _JadwalKunjunganPageState createState() => _JadwalKunjunganPageState();
}

class _JadwalKunjunganPageState extends State<JadwalKunjunganPage> {
  DateTime selectedDate = DateTime.now();

  // Contoh data kunjungan (bisa diganti dari API)
  List<Map<String, dynamic>> kunjungan = [
    {
      "tanggal": DateTime(2025, 9, 20),
      "jam": "11:00 - 12:30 WIB",
      "judul": "Kunjungan Pertama",
      "deskripsi": "Konsultasi | Kunjungan rumah",
    },
    {
      "tanggal": DateTime(2025, 9, 23),
      "jam": "10:00 - 20:00 WIB",
      "judul": "Kunjungan Kedua",
      "deskripsi": "Pembuatan gigi palsu | Kunjungan rumah",
    },
  ];

  void nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    });
  }

  void prevMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = "id_ID";

    String month = DateFormat('MMMM').format(selectedDate);
    String year = DateFormat('yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // HEADER
            // =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                  const Spacer(),
                  const Text(
                    "Jadwal Kunjungan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 26), // Biar simetris
                ],
              ),
            ),

            // =====================
            // KALENDER
            // =====================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Prev month
                      GestureDetector(
                        onTap: prevMonth,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chevron_left),
                        ),
                      ),

                      const SizedBox(width: 20),

                      Column(
                        children: [
                          Text(
                            month,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            year,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),

                      const SizedBox(width: 20),

                      // Next month
                      GestureDetector(
                        onTap: nextMonth,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.chevron_right),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // === Tanggal Kalender ===
                  buildCalendar(selectedDate),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================
            // LIST KUNJUNGAN
            // =====================
            Expanded(
              child: buildKunjunganList(),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // WIDGET KALENDER TANGGAL
  // ===========================
  Widget buildCalendar(DateTime date) {
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    int startWeekday = DateTime(date.year, date.month, 1).weekday;

    List<Widget> rows = [];
    List<Widget> cells = [];

    // Kosong sebelum tanggal 1
    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox(width: 40, height: 40));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      cells.add(Container(
        margin: EdgeInsets.all(4),
        alignment: Alignment.center,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text("$day"),
      ));

      if (cells.length == 7) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: cells,
        ));
        cells = [];
      }
    }

    if (cells.isNotEmpty) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: cells,
      ));
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
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: kunjungan.length,
      itemBuilder: (context, index) {
        final item = kunjungan[index];
        String tanggal = DateFormat("d MMMM yyyy", "id_ID").format(item["tanggal"]);

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    tanggal,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Icon(Icons.access_time, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    item["jam"],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                item["judul"],
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                item["deskripsi"],
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }
}
