import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

enum GraphPeriod { week, month, year }

class BloodPressureGraph extends StatefulWidget {
  const BloodPressureGraph({
    required this.readings,
    required this.isLoading,
    super.key,
  });

  final List<BloodPressureReading> readings;
  final bool isLoading;

  @override
  State<BloodPressureGraph> createState() => _BloodPressureGraphState();
}

class _BloodPressureGraphState extends State<BloodPressureGraph> {
  GraphPeriod _selectedPeriod = GraphPeriod.week;

  List<BloodPressureReading> get _filteredReadings {
    if (widget.readings.isEmpty) return [];

    final now = DateTime.now();
    final cutoff = switch (_selectedPeriod) {
      GraphPeriod.week => now.subtract(const Duration(days: 7)),
      GraphPeriod.month => now.subtract(const Duration(days: 30)),
      GraphPeriod.year => now.subtract(const Duration(days: 365)),
    };

    return widget.readings
        .where((r) => r.measuredAt.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _PeriodSelector(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (period) {
              setState(() => _selectedPeriod = period);
            },
          ),
        ),
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredReadings.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noDataYet,
                        style: context.bodyLarge?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 24, 16),
                      child: _BloodPressureLineChart(
                        readings: _filteredReadings,
                        period: _selectedPeriod,
                      ),
                    ),
        ),
        _Legend(),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final GraphPeriod selectedPeriod;
  final void Function(GraphPeriod) onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SegmentedButton<GraphPeriod>(
      segments: [
        ButtonSegment(
          value: GraphPeriod.week,
          label: Text(l10n.periodWeek),
        ),
        ButtonSegment(
          value: GraphPeriod.month,
          label: Text(l10n.periodMonth),
        ),
        ButtonSegment(
          value: GraphPeriod.year,
          label: Text(l10n.periodYear),
        ),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (selected) {
        onPeriodChanged(selected.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.mainText;
        }),
      ),
    );
  }
}

class _BloodPressureLineChart extends StatelessWidget {
  const _BloodPressureLineChart({
    required this.readings,
    required this.period,
  });

  final List<BloodPressureReading> readings;
  final GraphPeriod period;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const SizedBox.shrink();

    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];

    final startDate = readings.first.measuredAt;

    for (var i = 0; i < readings.length; i++) {
      final reading = readings[i];
      final daysDiff =
          reading.measuredAt.difference(startDate).inHours / 24.0;
      systolicSpots.add(FlSpot(daysDiff, reading.systolic.toDouble()));
      diastolicSpots.add(FlSpot(daysDiff, reading.diastolic.toDouble()));
    }

    final allValues = readings.expand((r) => [r.systolic, r.diastolic]);
    final minY = (allValues.reduce((a, b) => a < b ? a : b) - 10)
        .toDouble()
        .clamp(30.0, 200.0);
    final maxY = (allValues.reduce((a, b) => a > b ? a : b) + 10)
        .toDouble()
        .clamp(50.0, 250.0);

    final maxX = readings.last.measuredAt.difference(startDate).inHours / 24.0;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: maxX > 0 ? maxX : 1,
        gridData: FlGridData(
          horizontalInterval: 20,
          verticalInterval: _getVerticalInterval(),
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: context.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: _getBottomInterval(),
              getTitlesWidget: (value, meta) {
                final date = startDate.add(Duration(hours: (value * 24).toInt()));
                final format = period == GraphPeriod.year
                    ? DateFormat('MM/dd')
                    : DateFormat('MM/dd');
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    format.format(date),
                    style: context.labelSmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.shade300),
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: systolicSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.error,
            barWidth: 3,
            dotData: FlDotData(
              show: readings.length <= 14,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.error,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.error.withValues(alpha: 0.1),
            ),
          ),
          LineChartBarData(
            spots: diastolicSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.secondary,
            barWidth: 3,
            dotData: FlDotData(
              show: readings.length <= 14,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.secondary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.secondary.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.white,
            tooltipBorder: BorderSide(color: Colors.grey.shade300),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isSystolic = spot.barIndex == 0;
                return LineTooltipItem(
                  '${spot.y.toInt()} mmHg',
                  TextStyle(
                    color: isSystolic ? AppColors.error : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _getVerticalInterval() {
    return switch (period) {
      GraphPeriod.week => 1,
      GraphPeriod.month => 7,
      GraphPeriod.year => 30,
    };
  }

  double _getBottomInterval() {
    return switch (period) {
      GraphPeriod.week => 1,
      GraphPeriod.month => 7,
      GraphPeriod.year => 60,
    };
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(
            color: AppColors.error,
            label: l10n.systolicLabel,
          ),
          const SizedBox(width: 24),
          _LegendItem(
            color: AppColors.secondary,
            label: l10n.diastolicLabel,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.bodySmall?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
