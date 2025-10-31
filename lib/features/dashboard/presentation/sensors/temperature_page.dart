import 'dart:math';
import 'package:flutter/material.dart';
import 'package:green_klok_ia/services/sensor_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class TemperaturePage extends StatefulWidget {
  final String? selectedGreenhouse;
  const TemperaturePage({super.key, required this.selectedGreenhouse});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  bool isLoading = true;
  double? currentTemperature;
  List<Map<String, dynamic>> history = [];
  String selectedRange = '1d';
  final List<String> ranges = ['1h', '12h', '1d', '3d', '7d'];

  @override
  void initState() {
    super.initState();
    _loadTemperature();
  }

  Future<void> _loadTemperature() async {
    final service = SensorService();
    try {
      final data = await service.getTemperature(widget.selectedGreenhouse!);
      final historyData = await service.getSensorHistory(
        widget.selectedGreenhouse!,
        type: 'temperature',
        range: selectedRange,
      );

      setState(() {
        currentTemperature = (data['value'] as num).toDouble();
        history = List<Map<String, dynamic>>.from(historyData['data']);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar temperatura: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<FlSpot> _buildSpots() {
    if (history.isEmpty) return [];
    final minTime = DateTime.parse(history.first['timestamp']).millisecondsSinceEpoch.toDouble();

    return history.map((point) {
      final timestamp = DateTime.parse(point['timestamp']).millisecondsSinceEpoch.toDouble();
      final x = (timestamp - minTime) / 3600000; // en horas
      final y = (point['value'] as num).toDouble();
      return FlSpot(x, y);
    }).toList();
  }

  String _formatTimestamp(double hours) {
    if (history.isEmpty) return '';
    final start = DateTime.parse(history.first['timestamp']);
    final date = start.add(Duration(hours: hours.toInt()));
    return DateFormat.Hm().format(date); // hora:minuto
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        title: const Text(
          "Temperatura 🌡️",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Valor actual
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: const Icon(Icons.thermostat, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${currentTemperature?.toStringAsFixed(1)} °C",
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Temperatura óptima ✅",
                    style: TextStyle(fontSize: 17, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  // Selector de rango
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: ranges.map((r) {
                      final selected = r == selectedRange;
                      return ChoiceChip(
                        label: Text(
                          r,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: width < 380 ? 12 : 13,
                          ),
                        ),
                        selected: selected,
                        selectedColor: Colors.deepOrange,
                        onSelected: (bool value) {
                          if (value) {
                            setState(() {
                              selectedRange = r;
                              isLoading = true;
                            });
                            _loadTemperature();
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Tarjeta de gráfica
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          "Historial de Temperatura",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 🔹 Gráfica responsive y sin overlap
                        SizedBox(
                          height: 230,
                          child: history.isEmpty
                              ? const Center(child: Text("No hay datos históricos"))
                              : Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 8, bottom: 8),
                                  child: LineChart(
                                    LineChartData(
                                      clipData: const FlClipData.all(),
                                      minY: history.map((e) => (e['value'] as num).toDouble()).reduce(min) - 1,
                                      maxY: history.map((e) => (e['value'] as num).toDouble()).reduce(max) + 1,
                                      gridData: FlGridData(
                                        show: true,
                                        horizontalInterval: 1,
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (value) => FlLine(
                                          color: Colors.black12,
                                          strokeWidth: 0.7,
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: width < 380 ? 25 : 30,
                                            interval: 1,
                                            getTitlesWidget: (value, _) => Padding(
                                              padding: const EdgeInsets.only(right: 2),
                                              child: Text(
                                                '${value.toStringAsFixed(0)}°',
                                                style: TextStyle(
                                                  fontSize: width < 400 ? 9 : 10,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 26,
                                            interval: max(1, history.length / 5),
                                            getTitlesWidget: (value, _) => Text(
                                              _formatTimestamp(value),
                                              style: TextStyle(
                                                fontSize: width < 400 ? 9 : 10,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _buildSpots(),
                                          isCurved: true,
                                          preventCurveOverShooting: true,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          barWidth: 3,
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFFFF7043).withOpacity(0.25),
                                                const Color(0xFFFF5722).withOpacity(0.05)
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          dotData: FlDotData(
                                            show: true,
                                            checkToShowDot: (spot, _) => spot.x % 2 == 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  Text(
                    "Invernadero: ${widget.selectedGreenhouse ?? 'N/A'}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  // Consejo
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFCC80), Color(0xFFFFE0B2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: const Column(
                      children: [
                        Text(
                          "Consejo 🌱",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Mantén la temperatura entre 25–30 °C para un crecimiento óptimo de tus cultivos.",
                          style: TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
