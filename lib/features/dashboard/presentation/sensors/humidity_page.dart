import 'dart:math';
import 'package:flutter/material.dart';
import 'package:green_klok_ia/services/sensor_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HumidityPage extends StatefulWidget {
  final String? selectedGreenhouse;
  const HumidityPage({super.key, required this.selectedGreenhouse});

  @override
  State<HumidityPage> createState() => _HumidityPageState();
}

class _HumidityPageState extends State<HumidityPage> {
  bool isLoading = true;
  double? currentHumidity;
  List<Map<String, dynamic>> history = [];
  String selectedRange = '1d';
  final List<String> ranges = ['1h', '12h', '1d', '3d', '7d'];

  @override
  void initState() {
    super.initState();
    _loadHumidity();
  }

  Future<void> _loadHumidity() async {
    final service = SensorService();
    try {
      final data = await service.getHumidityAir(widget.selectedGreenhouse!);
      final historyData = await service.getSensorHistory(
        widget.selectedGreenhouse!,
        type: 'humidity_air',
        range: selectedRange,
      );

      setState(() {
        currentHumidity = (data['value'] as num).toDouble();
        history = List<Map<String, dynamic>>.from(historyData['data']);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar humedad: $e');
      setState(() {
        isLoading = false;
        currentHumidity = null;
      });
    }
  }

  List<FlSpot> _buildSpots() {
    if (history.isEmpty) return [];
    final minTime = DateTime.parse(history.first['timestamp']).millisecondsSinceEpoch.toDouble();

    return history.map((point) {
      final timestamp = DateTime.parse(point['timestamp']).millisecondsSinceEpoch.toDouble();
      final x = (timestamp - minTime) / 3600000; // horas desde el inicio
      final y = (point['value'] as num).toDouble();
      return FlSpot(x, y);
    }).toList();
  }

  String _formatTimestamp(double hours) {
    if (history.isEmpty) return '';
    final start = DateTime.parse(history.first['timestamp']);
    final date = start.add(Duration(hours: hours.toInt()));
    return DateFormat.Hm().format(date);
  }

  // 🧠 Interpreta la humedad
  String _interpretarHumedad(double? humedad) {
    if (humedad == null) return "Dato no disponible";
    if (humedad < 40) return "Humedad baja ⚠️";
    if (humedad > 70) return "Humedad alta ⚠️";
    return "Nivel de humedad: Óptimo ✅";
  }

  // 🎨 Color dinámico
  Color _colorPorHumedad(double? humedad) {
    if (humedad == null) return Colors.grey;
    if (humedad < 40 || humedad > 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        title: const Text(
          "Humedad 💧",
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
                        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: const Icon(Icons.water_drop, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "${currentHumidity?.toStringAsFixed(1)} %",
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _interpretarHumedad(currentHumidity),
                    style: TextStyle(
                      fontSize: 17,
                      color: _colorPorHumedad(currentHumidity),
                      fontWeight: FontWeight.w600,
                    ),
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
                        selectedColor: Colors.blueAccent,
                        onSelected: (bool value) {
                          if (value) {
                            setState(() {
                              selectedRange = r;
                              isLoading = true;
                            });
                            _loadHumidity();
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
                        colors: [Color(0xFFBBDEFB), Color(0xFF90CAF9)],
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
                          "Historial de Humedad del Aire",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 230,
                          child: history.isEmpty
                              ? const Center(child: Text("No hay datos históricos"))
                              : Padding(
                                  padding: const EdgeInsets.only(left: 4, right: 8, bottom: 8),
                                  child: LineChart(
                                    LineChartData(
                                      clipData: const FlClipData.all(),
                                      minY: history.map((e) => (e['value'] as num).toDouble()).reduce(min) - 2,
                                      maxY: history.map((e) => (e['value'] as num).toDouble()).reduce(max) + 2,
                                      gridData: FlGridData(
                                        show: true,
                                        horizontalInterval: 2,
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
                                            interval: 5,
                                            getTitlesWidget: (value, _) => Padding(
                                              padding: const EdgeInsets.only(right: 2),
                                              child: Text(
                                                '${value.toStringAsFixed(0)}%',
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
                                            colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          barWidth: 3,
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF42A5F5).withOpacity(0.25),
                                                const Color(0xFF1E88E5).withOpacity(0.05)
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
                        colors: [Color(0xFFBBDEFB), Color(0xFFE3F2FD)],
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
                          "Consejo 💧",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Mantén la humedad del aire entre 50–70% para evitar estrés en las plantas y favorecer la fotosíntesis.",
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
