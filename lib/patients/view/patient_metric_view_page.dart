import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_graph.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_history.dart';
import 'package:frontend/blood_sugar/widgets/blood_sugar_graph.dart';
import 'package:frontend/blood_sugar/widgets/blood_sugar_history.dart';
import 'package:frontend/bmi/widgets/bmi_graph.dart';
import 'package:frontend/bmi/widgets/bmi_history.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patient_metric_view_cubit.dart';
import 'package:frontend/patients/data/patients_repository.dart';

/// Doctor/admin view for a patient's health metric data.
/// Shows two tabs: Records (list) and Graph.
@RoutePage()
class PatientMetricViewPage extends StatelessWidget {
  const PatientMetricViewPage({
    @PathParam('id') required this.patientId,
    required this.metricType,
    this.patientName,
    super.key,
  });

  final int patientId;
  final HealthMetricType metricType;
  final String? patientName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = PatientMetricViewCubit(
          patientsRepository: context.read<PatientsRepository>(),
          patientId: patientId,
          metricType: metricType,
        );
        final defaultFromDate =
            DateTime.now().subtract(const Duration(days: 30));
        unawaited(cubit.loadData(fromDate: defaultFromDate));
        return cubit;
      },
      child: _Content(metricType: metricType, patientName: patientName),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({required this.metricType, this.patientName});

  final HealthMetricType metricType;
  final String? patientName;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTitle(AppLocalizations l10n) {
    return switch (widget.metricType) {
      HealthMetricType.bloodPressure => l10n.bloodPressureTitle,
      HealthMetricType.bloodSugar => l10n.bloodSugarTitle,
      HealthMetricType.bmi => l10n.bmiTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = widget.patientName ?? _getTitle(l10n);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: context.appBarTitle.copyWith(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: l10n.tabRecords),
            Tab(text: l10n.tabGraph),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _RecordsTab(metricType: widget.metricType),
            _GraphTab(metricType: widget.metricType),
          ],
        ),
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({required this.metricType});

  final HealthMetricType metricType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientMetricViewCubit, PatientMetricViewState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: switch (metricType) {
            HealthMetricType.bloodPressure => BloodPressureHistory(
                readings: state.bloodPressureReadings,
                isLoading: state.isLoading,
                showAddHint: false,
              ),
            HealthMetricType.bloodSugar => BloodSugarHistory(
                readings: state.bloodSugarReadings,
                isLoading: state.isLoading,
                showAddHint: false,
              ),
            HealthMetricType.bmi => BmiHistory(
                measurements: state.bmiMeasurements,
                isLoading: state.isLoading,
                showAddHint: false,
              ),
          },
        );
      },
    );
  }
}

class _GraphTab extends StatelessWidget {
  const _GraphTab({required this.metricType});

  final HealthMetricType metricType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientMetricViewCubit, PatientMetricViewState>(
      builder: (context, state) {
        return switch (metricType) {
          HealthMetricType.bloodPressure => BloodPressureGraph(
              readings: state.bloodPressureReadings,
              isLoading: state.isLoading,
              onPeriodChanged: (period) {
                unawaited(
                  context
                      .read<PatientMetricViewCubit>()
                      .loadData(fromDate: period.toFromDate()),
                );
              },
            ),
          HealthMetricType.bloodSugar => BloodSugarGraph(
              readings: state.bloodSugarReadings,
              isLoading: state.isLoading,
              onPeriodChanged: (period) {
                unawaited(
                  context
                      .read<PatientMetricViewCubit>()
                      .loadData(fromDate: period.toFromDate()),
                );
              },
            ),
          HealthMetricType.bmi => BmiGraph(
              measurements: state.bmiMeasurements,
              isLoading: state.isLoading,
              onPeriodChanged: (period) {
                unawaited(
                  context
                      .read<PatientMetricViewCubit>()
                      .loadData(fromDate: period.toFromDate()),
                );
              },
            ),
        };
      },
    );
  }
}
