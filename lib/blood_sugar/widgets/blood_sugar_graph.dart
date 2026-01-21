import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
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

class BloodSugarGraph extends StatefulWidget {
  const BloodSugarGraph({
    required this.readings,
    required this.isLoading,
    required this.onPeriodChanged,
    super.key,
  });

  final List<BloodSugarReading> readings;
  final bool isLoading;
  final void Function(GraphPeriod period) onPeriodChanged;

  @override
  State<BloodSugarGraph> createState() => _BloodSugarGraphState();
}

class _BloodSugarGraphState extends State<BloodSugarGraph> {
  GraphPeriod _selectedPeriod = GraphPeriod.month;

  /// Readings are already filtered by the cubit based on the selected period.
  /// We just need to sort them for the chart.
  List<BloodSugarReading> get _sortedReadings {
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
                      child: _BloodSugarLineChart(
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

class _BloodSugarLineChart extends StatelessWidget {
  const _BloodSugarLineChart({
    required this.readings,
    required this.period,
  });

  final List<BloodSugarReading> readings;
  final GraphPeriod period;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final glucoseSpots = <FlSpot>[];

    final startDate = readings.first.measuredAt;

    for (var i = 0; i < readings.length; i++) {
      final reading = readings[i];
      // Use minutes for more precise positioning of multiple daily readings
      final minutesDiff =
          reading.measuredAt.difference(startDate).inMinutes / (24.0 * 60);
      glucoseSpots.add(FlSpot(minutesDiff, reading.glucoseLevel));
    }

    final allValues = readings.map((r) => r.glucoseLevel);
    final minY = (allValues.reduce((a, b) => a < b ? a : b) - 1)
        .clamp(0.0, 30.0);
    final maxY = (allValues.reduce((a, b) => a > b ? a : b) + 1)
        .clamp(2.0, 35.0);

    final maxX =
        readings.last.measuredAt.difference(startDate).inMinutes / (24.0 * 60);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: maxX > 0 ? maxX : 1,
        gridData: FlGridData(
          horizontalInterval: 2,
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
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
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
            spots: glucoseSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: readings.length <= 14,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
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

              return touchedSpots.map((spot) {
                // Show date/time
                var dateTimeText = '';
                if (reading != null) {
                  final formatted =
                      DateFormat('MM/dd HH:mm').format(reading.measuredAt);
                  dateTimeText = '$formatted\n';
                }

                return LineTooltipItem(
                  '$dateTimeText${spot.y.toStringAsFixed(1)} ${l10n.mmolLUnit}',
                  const TextStyle(
                    color: AppColors.primary,
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
          Container(
            width: 16,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.glucoseLevelLabel,
            style: context.bodySmall?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
