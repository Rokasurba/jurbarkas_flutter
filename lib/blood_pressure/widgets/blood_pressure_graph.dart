import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:intl/intl.dart';

enum GraphPeriod {
  week,
  month,
  threeMonths,
  allTime;

  /// Returns the from date for this period, or null for allTime.
  DateTime? toFromDate() {
    final now = DateTime.now();
    return switch (this) {
      GraphPeriod.week => now.subtract(const Duration(days: 7)),
      GraphPeriod.month => now.subtract(const Duration(days: 30)),
      GraphPeriod.threeMonths => now.subtract(const Duration(days: 90)),
      GraphPeriod.allTime => null,
    };
  }
}

class BloodPressureGraph extends StatefulWidget {
  const BloodPressureGraph({
    required this.readings,
    required this.isLoading,
    required this.onPeriodChanged,
    super.key,
  });

  final List<BloodPressureReading> readings;
  final bool isLoading;
  final void Function(GraphPeriod period) onPeriodChanged;

  @override
  State<BloodPressureGraph> createState() => _BloodPressureGraphState();
}

class _BloodPressureGraphState extends State<BloodPressureGraph> {
  GraphPeriod _selectedPeriod = GraphPeriod.month;

  /// Readings are already filtered by the cubit based on the selected period.
  /// We just need to sort them for the chart.
  List<BloodPressureReading> get _sortedReadings {
    if (widget.readings.isEmpty) return [];
    return widget.readings.toList()
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
              widget.onPeriodChanged(period);
            },
          ),
        ),
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _sortedReadings.length < 2
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 48,
                              color: AppColors.secondaryText
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _sortedReadings.isEmpty
                                  ? l10n.noDataYet
                                  : l10n.chartNeedsMoreData,
                              style: context.bodyLarge?.copyWith(
                                color: AppColors.secondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 24, 16),
                      child: _BloodPressureLineChart(
                        readings: _sortedReadings,
                        period: _selectedPeriod,
                      ),
                    ),
        ),
        const _Legend(),
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
      showSelectedIcon: false,
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
          value: GraphPeriod.threeMonths,
          label: Text(l10n.periodThreeMonths),
        ),
        ButtonSegment(
          value: GraphPeriod.allTime,
          label: Text(l10n.periodAllTime),
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

    final l10n = context.l10n;
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];

    final startDate = readings.first.measuredAt;

    for (var i = 0; i < readings.length; i++) {
      final reading = readings[i];
      // Use minutes for more precise positioning of multiple daily readings
      final minutesDiff =
          reading.measuredAt.difference(startDate).inMinutes / (24.0 * 60);
      systolicSpots.add(FlSpot(minutesDiff, reading.systolic.toDouble()));
      diastolicSpots.add(FlSpot(minutesDiff, reading.diastolic.toDouble()));
    }

    final allValues = readings.expand((r) => [r.systolic, r.diastolic]);
    final minY = (allValues.reduce((a, b) => a < b ? a : b) - 10)
        .toDouble()
        .clamp(30.0, 200.0);
    final maxY = (allValues.reduce((a, b) => a > b ? a : b) + 10)
        .toDouble()
        .clamp(50.0, 250.0);

    final maxX =
        readings.last.measuredAt.difference(startDate).inMinutes / (24.0 * 60);

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
                final date =
                    startDate.add(Duration(minutes: (value * 24 * 60).toInt()));
                final format = DateFormat('MM/dd');
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
              if (touchedSpots.isEmpty) return [];

              // Find the reading that matches this x position
              final xValue = touchedSpots.first.x;
              final readingIndex = _findReadingIndex(xValue, startDate);
              final reading =
                  readingIndex != null ? readings[readingIndex] : null;

              return touchedSpots.asMap().entries.map((entry) {
                final index = entry.key;
                final spot = entry.value;
                final isSystolic = spot.barIndex == 0;

                // Show date/time on first line only
                var dateTimeText = '';
                if (index == 0 && reading != null) {
                  final formatted =
                      DateFormat('MM/dd HH:mm').format(reading.measuredAt);
                  dateTimeText = '$formatted\n';
                }

                final label =
                    isSystolic ? l10n.systolicLabel : l10n.diastolicLabel;

                return LineTooltipItem(
                  '$dateTimeText$label: ${spot.y.toInt()} mmHg',
                  TextStyle(
                    color: isSystolic ? AppColors.error : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  int? _findReadingIndex(double xValue, DateTime startDate) {
    for (var i = 0; i < readings.length; i++) {
      final reading = readings[i];
      final minutesDiff =
          reading.measuredAt.difference(startDate).inMinutes / (24.0 * 60);
      // Allow small tolerance for floating point comparison
      if ((minutesDiff - xValue).abs() < 0.001) {
        return i;
      }
    }
    return null;
  }

  double _getVerticalInterval() {
    return switch (period) {
      GraphPeriod.week => 1,
      GraphPeriod.month => 7,
      GraphPeriod.threeMonths => 14,
      GraphPeriod.allTime => 30,
    };
  }

  double _getBottomInterval() {
    return switch (period) {
      GraphPeriod.week => 1,
      GraphPeriod.month => 7,
      GraphPeriod.threeMonths => 14,
      GraphPeriod.allTime => 60,
    };
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

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
