import 'package:flutter/material.dart';
import 'data/nutrition_store.dart';
import 'nutrition_capture_page.dart';

class IbiPage extends StatefulWidget {
  const IbiPage({super.key});

  @override
  State<IbiPage> createState() => _IbiPageState();
}

class _IbiPageState extends State<IbiPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _fmtDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  List<DailyNutritionRecord> _generateDummyData(DateTime forDate) {
    final records = <DailyNutritionRecord>[];
    for (int i = 6; i >= 0; i--) {
      final date = forDate.subtract(Duration(days: i));
      final dayFactor = date.day;

      final karbohidrat = 150.0 + (dayFactor % 7 * 5) - (i * 1.5);
      final protein = 50.0 + (dayFactor % 5 * 3) - (i * 2);
      final lemak = 40.0 - (dayFactor % 4 * 1.5) + i;
      final serat = 20.0 + (dayFactor % 10);
      records.add(
        DailyNutritionRecord(
          date: date,
          karbohidrat: karbohidrat > 0 ? karbohidrat : 0,
          protein: protein > 0 ? protein : 0,
          lemak: lemak > 0 ? lemak : 0,
          serat: serat > 0 ? serat : 0,
          kalori: (karbohidrat * 4) + (protein * 4) + (lemak * 9),
        ),
      );
    }
    return records;
  }

  List<DailyNutritionRecord> _generateDummyMonthlyData(DateTime forDate) {
    final records = <DailyNutritionRecord>[];
    // Generate data for the last 28 days
    for (int i = 27; i >= 0; i--) {
      final date = forDate.subtract(Duration(days: i));
      final dayFactor = date.day;
      final monthFactor = date.month;

      final karbohidrat = 120.0 + (dayFactor * 1.5) - (i * 0.5) + monthFactor;
      final protein =
          40.0 + (dayFactor * 0.5) + (monthFactor * 1.5) - ((i % 10) * 0.5);
      final lemak =
          30.0 + (dayFactor * 0.8) - (monthFactor * 0.5) - ((i % 5) * 1.2);
      final serat = 15.0 + (dayFactor % 15 * 0.5) + (monthFactor * 0.5);
      records.add(
        DailyNutritionRecord(
          date: date,
          karbohidrat: karbohidrat > 0 ? karbohidrat : 0,
          protein: protein > 0 ? protein : 0,
          lemak: lemak > 0 ? lemak : 0,
          serat: serat > 0 ? serat : 0,
          kalori: (karbohidrat * 4) + (protein * 4) + (lemak * 9),
        ),
      );
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perkembangan Gizi Anak'),
        backgroundColor: const Color(0xFF0B8CFF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ValueListenableBuilder<List<DailyNutritionRecord>>(
          valueListenable: NutritionStore.instance,
          builder: (context, list, _) {
            final recent = _generateDummyData(_selectedDate);
            final latest = list.isNotEmpty ? list.last : null;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (latest != null) _buildHeader(latest),
                  const SizedBox(height: 12),
                  _buildMetricCards(latest),
                  const SizedBox(height: 16),
                  const Text(
                    'Tren 7 hari',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionTrendChart(recent),
                  const SizedBox(height: 18),
                  _buildMonthlyTrendSection(_selectedDate),
                  const SizedBox(height: 18),
                  _buildHistoryList(list),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NutritionCapturePage()),
          );
        },
        backgroundColor: const Color(0xFF0B8CFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(DailyNutritionRecord latest) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Terbaru',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Kalori: ${latest.kalori.toStringAsFixed(0)} kcal',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Protein: ${latest.protein.toStringAsFixed(0)} g • Karbo: ${latest.karbohidrat.toStringAsFixed(0)} g',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards(DailyNutritionRecord? latest) {
    if (latest == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Belum ada data. Silakan input gizi harian terlebih dahulu.',
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _metricCard(
          'Protein',
          '${latest.protein.toStringAsFixed(0)} g',
          Colors.green,
        ),
        _metricCard(
          'Karbohidrat',
          '${latest.karbohidrat.toStringAsFixed(0)} g',
          Colors.orange,
        ),
        _metricCard(
          'Lemak',
          '${latest.lemak.toStringAsFixed(0)} g',
          Colors.redAccent,
        ),
        _metricCard(
          'Serat',
          '${latest.serat.toStringAsFixed(0)} g',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String title, String sub) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            Text(
              sub,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionTrendChart(List<DailyNutritionRecord> recent) {
    if (recent.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: const Text('Tidak ada data untuk ditampilkan'),
      );
    }

    final allValues = [
      ...recent.map((r) => r.karbohidrat),
      ...recent.map((r) => r.protein),
      ...recent.map((r) => r.lemak),
      ...recent.map((r) => r.serat),
    ];
    double maxVal = allValues.isEmpty
        ? 10
        : allValues.reduce((a, b) => a > b ? a : b);
    double chartMax = (maxVal * 1.2);
    if (chartMax < 10) chartMax = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _legendItem(
                      const Color(0xFF2F80ED),
                      'Karbo',
                      'Rata-rata: ${_avg(recent.map((r) => r.karbohidrat).toList()).toStringAsFixed(0)}g',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _legendItem(
                      const Color(0xFF2DC071),
                      'Protein',
                      'Rata-rata: ${_avg(recent.map((r) => r.protein).toList()).toStringAsFixed(0)}g',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _legendItem(
                      const Color(0xFFF2C94C),
                      'Serat',
                      'Rata-rata: ${_avg(recent.map((r) => r.serat).toList()).toStringAsFixed(0)}g',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _legendItem(
                      const Color(0xFFEB5757),
                      'Lemak',
                      'Rata-rata: ${_avg(recent.map((r) => r.lemak).toList()).toStringAsFixed(0)}g',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 260,
            child: SimpleTrendChart(recent: recent, chartMax: chartMax),
          ),
        ),
        const SizedBox(height: 12),
        _buildChartGuide(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMonthlyTrendSection(DateTime referenceDate) {
    final all = _generateDummyMonthlyData(referenceDate);
    final monthly =
        NutritionStore.instance.sevenDayAverages(records: all, groups: 4);

    if (monthly.isEmpty) {
      return const SizedBox();
    }

    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthName = monthNames[referenceDate.month - 1];
    final year = referenceDate.year;

    final allValues = [
      ...monthly.map((r) => r.avgKarbohidrat),
      ...monthly.map((r) => r.avgProtein),
      ...monthly.map((r) => r.avgLemak),
      ...monthly.map((r) => r.avgSerat),
    ];
    double maxVal = allValues.isEmpty
        ? 10
        : allValues.reduce((a, b) => a > b ? a : b);
    double chartMax = (maxVal * 1.2);
    if (chartMax < 10) chartMax = 10.0;

    // Logic to disable forward button for future months
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final selectedMonth = DateTime(referenceDate.year, referenceDate.month, 1);
    final isFutureMonth = selectedMonth.isAtSameMomentAs(currentMonth) ||
        selectedMonth.isAfter(currentMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              onPressed: () {
                setState(() {
                  _selectedDate =
                      DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                });
              },
            ),
            Expanded(
              child: Text(
                'Tren $monthName $year',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: isFutureMonth
                  ? null // Disable button if it's the current or a future month
                  : () {
                      setState(() {
                        _selectedDate = DateTime(
                            _selectedDate.year, _selectedDate.month + 1, 1);
                      });
                    },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _legendItem(
                      const Color(0xFF2F80ED),
                      'Karbo',
                      'Rata-rata: ${_avg(monthly.map((r) => r.avgKarbohidrat).toList()).toStringAsFixed(0)}g',
                    ),
                    _legendItem(
                      const Color(0xFF2DC071),
                      'Protein',
                      'Rata-rata: ${_avg(monthly.map((r) => r.avgProtein).toList()).toStringAsFixed(0)}g',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _legendItem(
                      const Color(0xFFF2C94C),
                      'Serat',
                      'Rata-rata: ${_avg(monthly.map((r) => r.avgSerat).toList()).toStringAsFixed(0)}g',
                    ),
                    _legendItem(
                      const Color(0xFFEB5757),
                      'Lemak',
                      'Rata-rata: ${_avg(monthly.map((r) => r.avgLemak).toList()).toStringAsFixed(0)}g',
                    ),
                  ],
                ),
              ],
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 260,
            child: MonthlyTrendChart(monthly: monthly, chartMax: chartMax),
          ),
        ),
        const SizedBox(height: 12),
        _buildMonthlyChartGuide(),
      ],
    );
  }

  double _avg(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Widget _buildChartGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info, color: Color(0xFF0B8CFF), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cara Membaca Grafik',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Bullet(
                text:
                    'Semakin tinggi garis, semakin banyak nutrisi yang dikonsumsi per hari.',
              ),
              SizedBox(height: 6),
              _Bullet(
                text: 'Ketuk titik pada garis untuk melihat detail per hari.',
              ),
              SizedBox(height: 6),
              _Bullet(
                text: 'Bandingkan pola konsumsi antar hari untuk melihat tren.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChartGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info, color: Color(0xFF0B8CFF), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cara Membaca Grafik Bulanan',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Bullet(
                text:
                    'Grafik ini menunjukkan rata-rata konsumsi nutrisi per minggu.',
              ),
              SizedBox(height: 6),
              _Bullet(
                text:
                    'Ketuk titik pada garis untuk melihat detail rata-rata mingguan.',
              ),
              SizedBox(height: 6),
              _Bullet(
                text:
                    'Label M1, M2, M3, M4 adalah singkatan untuk Minggu 1, Minggu 2, dst.',
              ),
              SizedBox(height: 6),
              _Bullet(
                text:
                    'Gunakan tombol panah di atas untuk melihat data bulan lain.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<DailyNutritionRecord> list) {
    if (list.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...list.reversed.map((r) => _historyTile(r)).toList(),
      ],
    );
  }

  Widget _historyTile(DailyNutritionRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fmtDate(r.date),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text('Kalori: ${r.kalori.toStringAsFixed(0)} kcal'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'P:${r.protein.toStringAsFixed(0)} g',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text('K:${r.karbohidrat.toStringAsFixed(0)} g'),
            ],
          ),
        ],
      ),
    );
  }
}

class SimpleTrendChart extends StatelessWidget {
  final List<DailyNutritionRecord> recent;
  final double chartMax;

  const SimpleTrendChart({
    super.key,
    required this.recent,
    required this.chartMax,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;

            final localPos = box.globalToLocal(details.globalPosition);

            final paddingLeft = 40.0;
            final paddingRight = 12.0;
            final chartWidth =
                constraints.maxWidth - paddingLeft - paddingRight;

            if (recent.isEmpty || chartWidth <= 0) return;

            final dx = localPos.dx - paddingLeft;
            final pointIndex = (dx / chartWidth * (recent.length - 1)).round();

            if (pointIndex >= 0 && pointIndex < recent.length) {
              final tappedRecord = recent[pointIndex];
              final pointX =
                  paddingLeft +
                  (chartWidth * (pointIndex / (recent.length - 1)));

              // Check if tap is close enough to the point
              if ((localPos.dx - pointX).abs() < 20) {
                showDialog(
                  context: context,
                  builder: (ctx) => _ChartDetailDialog(record: tappedRecord),
                );
              }
            }
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _SimpleTrendChartPainter(recent, chartMax),
          ),
        );
      },
    );
  }
}

class _ChartDetailDialog extends StatelessWidget {
  final dynamic record;
  const _ChartDetailDialog({required this.record});

  String _fmtDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (record is DailyNutritionRecord) {
      final rec = record as DailyNutritionRecord;
      return AlertDialog(
        title: Text('Detail Gizi - ${_fmtDate(rec.date)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kalori: ${rec.kalori.toStringAsFixed(0)} kcal'),
            const SizedBox(height: 8),
            Text('Karbohidrat: ${rec.karbohidrat.toStringAsFixed(0)} g'),
            Text('Protein: ${rec.protein.toStringAsFixed(0)} g'),
            Text('Lemak: ${rec.lemak.toStringAsFixed(0)} g'),
            Text('Serat: ${rec.serat.toStringAsFixed(0)} g'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
    } else if (record is WeeklyAverage) {
      final rec = record as WeeklyAverage;
      final weekEnd = rec.weekStart.add(const Duration(days: 6));
      return AlertDialog(
        title: const Text('Detail Gizi Minggu Ini'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_fmtDate(rec.weekStart)} - ${_fmtDate(weekEnd)}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
                'Rata-rata Kalori: ${rec.avgCalories.toStringAsFixed(0)} kcal'),
            const SizedBox(height: 8),
            Text(
                'Rata-rata Karbohidrat: ${rec.avgKarbohidrat.toStringAsFixed(0)} g'),
            Text(
                'Rata-rata Protein: ${rec.avgProtein.toStringAsFixed(0)} g'),
            Text('Rata-rata Lemak: ${rec.avgLemak.toStringAsFixed(0)} g'),
            Text('Rata-rata Serat: ${rec.avgSerat.toStringAsFixed(0)} g'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
    }
    return const SizedBox();
  }
}

class _SimpleTrendChartPainter extends CustomPainter {
  final List<DailyNutritionRecord> recent;
  final double chartMax;

  _SimpleTrendChartPainter(this.recent, this.chartMax);

  @override
  void paint(Canvas canvas, Size size) {
    final paddingLeft = 40.0;
    final paddingBottom = 28.0;
    final paddingTop = 12.0;
    final chartWidth = size.width - paddingLeft - 12.0;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final stepY = chartHeight / 4;
    for (var i = 0; i <= 4; i++) {
      final y = paddingTop + stepY * i;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(paddingLeft + chartWidth, y),
        paintGrid,
      );
    }

    if (recent.isEmpty) return;

    List<Offset> mk = [];
    List<Offset> mp = [];
    List<Offset> ml = [];
    List<Offset> ms = [];

    for (var i = 0; i < recent.length; i++) {
      final x =
          paddingLeft +
          (chartWidth) * (i / (recent.length - 1 == 0 ? 1 : recent.length - 1));
      final r = recent[i];
      Offset toOffset(double val) {
        final yy = paddingTop + chartHeight - (val / chartMax) * chartHeight;
        return Offset(x, yy);
      }

      mk.add(toOffset(r.karbohidrat));
      mp.add(toOffset(r.protein));
      ml.add(toOffset(r.lemak));
      ms.add(toOffset(r.serat));
    }

    void drawAreaAndLine(List<Offset> points, Color color) {
      if (points.isEmpty) return;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var p in points) path.lineTo(p.dx, p.dy);
      path.lineTo(points.last.dx, paddingTop + chartHeight);
      path.lineTo(points.first.dx, paddingTop + chartHeight);
      path.close();

      final rect = Rect.fromLTWH(
        paddingLeft,
        paddingTop,
        chartWidth,
        chartHeight,
      );
      final grad = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.18), color.withOpacity(0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
      canvas.drawPath(path, grad);

      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      final pathLine = Path()..moveTo(points.first.dx, points.first.dy);
      for (var p in points) pathLine.lineTo(p.dx, p.dy);
      canvas.drawPath(pathLine, linePaint);

      for (var p in points) {
        final dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 3.0, dotPaint);
        final dotBorder = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(p, 3.0, dotBorder);
      }
    }

    drawAreaAndLine(mk, const Color(0xFF2F80ED));
    drawAreaAndLine(mp, const Color(0xFF2DC071));
    drawAreaAndLine(ms, const Color(0xFFF2C94C));
    drawAreaAndLine(ml, const Color(0xFFEB5757));

    // y-axis labels
    final tpStyle = const TextStyle(color: Colors.black54, fontSize: 10);
    for (var i = 0; i <= 4; i++) {
      final val = (chartMax * (4 - i) / 4).round();
      final tp = TextPainter(
        text: TextSpan(text: '$val', style: tpStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final y = paddingTop + stepY * i - tp.height / 2;
      tp.paint(canvas, Offset(6, y));
    }

    // x-axis labels
    final tpStyleX = const TextStyle(color: Colors.black54, fontSize: 11);
    for (var i = 0; i < recent.length; i++) {
      final x =
          paddingLeft +
          (chartWidth) * (i / (recent.length - 1 == 0 ? 1 : recent.length - 1));
      final label = _dayShort(recent[i].date);
      final tp = TextPainter(
        text: TextSpan(text: label, style: tpStyleX),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, paddingTop + chartHeight + 6));
    }
  }

  String _dayShort(DateTime d) {
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return names[(d.weekday - 1) % 7];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class MonthlyTrendChart extends StatefulWidget {
  final List<WeeklyAverage> monthly;
  final double chartMax;
  const MonthlyTrendChart({
    super.key,
    required this.monthly,
    required this.chartMax,
  });

  @override
  State<MonthlyTrendChart> createState() => _MonthlyTrendChartState();
}

class _MonthlyTrendChartState extends State<MonthlyTrendChart> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;

            final localPos = box.globalToLocal(details.globalPosition);
            final paddingLeft = 36.0;
            final chartWidth = constraints.maxWidth - paddingLeft - 12.0;

            if (widget.monthly.isEmpty || chartWidth <= 0) return;

            final dx = localPos.dx - paddingLeft;
            final pointIndex =
                (dx / chartWidth * (widget.monthly.length - 1)).round();

            if (pointIndex >= 0 && pointIndex < widget.monthly.length) {
              final tappedRecord = widget.monthly[pointIndex];
              final pointX = paddingLeft +
                  (chartWidth * (pointIndex / (widget.monthly.length - 1)));

              if ((localPos.dx - pointX).abs() < 20) {
                showDialog(
                  context: context,
                  builder: (ctx) =>
                      _ChartDetailDialog(record: tappedRecord),
                );
              }
            }
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _MonthlyTrendPainter(widget.monthly, widget.chartMax),
          ),
        );
      },
    );
  }
}

class _MonthlyTrendPainter extends CustomPainter {
  final List<WeeklyAverage> monthly;
  final double chartMax;
  _MonthlyTrendPainter(this.monthly, this.chartMax);

  @override
  void paint(Canvas canvas, Size size) {
    final paddingLeft = 40.0;
    final paddingBottom = 28.0;
    final paddingTop = 12.0;
    final chartWidth = size.width - paddingLeft - 12.0;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final stepY = chartHeight / 4;
    for (var i = 0; i <= 4; i++) {
      final y = paddingTop + stepY * i;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(paddingLeft + chartWidth, y),
        paintGrid,
      );
    }

    if (monthly.isEmpty) return;

    List<Offset> mk = [];
    List<Offset> mp = [];
    List<Offset> ml = [];
    List<Offset> ms = [];

    for (var i = 0; i < monthly.length; i++) {
      final x =
          paddingLeft +
          (chartWidth) * (i / (monthly.length - 1 == 0 ? 1 : monthly.length - 1));
      final r = monthly[i];
      Offset toOffset(double val) {
        final yy = paddingTop + chartHeight - (val / chartMax) * chartHeight;
        return Offset(x, yy);
      }

      mk.add(toOffset(r.avgKarbohidrat));
      mp.add(toOffset(r.avgProtein));
      ml.add(toOffset(r.avgLemak));
      ms.add(toOffset(r.avgSerat));
    }

    void drawAreaAndLine(List<Offset> points, Color color) {
      if (points.isEmpty) return;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var p in points) path.lineTo(p.dx, p.dy);
      path.lineTo(points.last.dx, paddingTop + chartHeight);
      path.lineTo(points.first.dx, paddingTop + chartHeight);
      path.close();

      final rect = Rect.fromLTWH(
        paddingLeft,
        paddingTop,
        chartWidth,
        chartHeight,
      );
      final grad = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.18), color.withOpacity(0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
      canvas.drawPath(path, grad);

      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      final pathLine = Path()..moveTo(points.first.dx, points.first.dy);
      for (var p in points) pathLine.lineTo(p.dx, p.dy);
      canvas.drawPath(pathLine, linePaint);

      for (var p in points) {
        final dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 3.0, dotPaint);
        final dotBorder = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(p, 3.0, dotBorder);
      }
    }

    drawAreaAndLine(mk, const Color(0xFF2F80ED));
    drawAreaAndLine(mp, const Color(0xFF2DC071));
    drawAreaAndLine(ms, const Color(0xFFF2C94C));
    drawAreaAndLine(ml, const Color(0xFFEB5757));

    // y labels
    final tpStyle = const TextStyle(color: Colors.black54, fontSize: 10);
    for (var i = 0; i <= 4; i++) {
      final val = (chartMax * (4 - i) / 4).round();
      final tp = TextPainter(
        text: TextSpan(text: '$val', style: tpStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final y = paddingTop + stepY * i - tp.height / 2;
      tp.paint(canvas, Offset(6, y));
    }

    // x labels (week number)
    final tpStyleX = const TextStyle(color: Colors.black54, fontSize: 11);
    for (var i = 0; i < monthly.length; i++) {
      final x =
          paddingLeft +
          (chartWidth) *
              (i / (monthly.length - 1 == 0 ? 1 : monthly.length - 1));
      final label = 'M${i + 1}'; // M for Minggu
      final tp = TextPainter(
        text: TextSpan(text: label, style: tpStyleX),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, paddingTop + chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}