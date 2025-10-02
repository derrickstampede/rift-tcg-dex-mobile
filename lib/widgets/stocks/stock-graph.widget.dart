import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:rift/models/stock.model.dart';

class CardStockGraph extends StatelessWidget {
  const CardStockGraph({super.key, required StockGraph graph}) : _graph = graph;

  final StockGraph _graph;

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [
      Colors.cyan,
      Colors.green,
    ];

    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      final index = value.toInt() - 1;
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: index >= 0 ? Text(_graph.bottomTitles[index]) : const Text(''),
      );
    }

    Widget leftTitleWidgets(double value, TitleMeta meta) {
      String amount = value.toStringAsFixed(0);
      double originalValue = value;
      if (originalValue < 10 && originalValue % 1 != 0) {
        amount = originalValue.toStringAsFixed(1);
      }
      if (value > 2000) {
        originalValue /= 1000;
        amount = '${originalValue.toStringAsFixed(0)}K';
      }
      if (value > 1000000) {
        originalValue /= 1000;
        amount = '${originalValue.toStringAsFixed(0)}M';
      }

      return Text(amount,
          style: const TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.left);
    }

    LineChartData graphData() {
      String symbol = _graph.currency;
      if (_graph.currency == 'JPY') {
        symbol = '¥';
      }
      if (_graph.currency == 'USD') {
        symbol = '\$';
      }

      return LineChartData(
        minX: _graph.xMin.toDouble(),
        maxX: _graph.xMax.toDouble(),
        minY: _graph.yMin.toDouble(),
        maxY: _graph.yMax.toDouble(),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            );
          },
        ),
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              final spot = barData.spots[spotIndex];
              if (spot.x == 0 || spot.x == 6) {
                return null;
              }
              return TouchedSpotIndicatorData(
                FlLine(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                ),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 2,
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.primary,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final price =
                    NumberFormat('#,###,##0.##').format(double.parse(_graph.tooltips[flSpot.spotIndex].price));
                return LineTooltipItem(
                  '${_graph.tooltips[flSpot.spotIndex].date}\n$symbol$price',
                  TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: double.parse(_graph.tooltips[flSpot.spotIndex].price) > 1000000 ? 12 : 14,
                      fontWeight: FontWeight.w700),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // interval: 1000,
              interval: _graph.yMax == 1 ? 0.2 : null,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 42,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _graph.spots.map((s) => FlSpot(s.x.toDouble(), s.y.toDouble())).toList(),
            isCurved: false,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 1,
            isStrokeCapRound: false,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 1,
                  strokeWidth: 1,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
              ),
            ),
          ),
        ],
      );
    }

    return LineChart(
      graphData(),
    );
  }
}
