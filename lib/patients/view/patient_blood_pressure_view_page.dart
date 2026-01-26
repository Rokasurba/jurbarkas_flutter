import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_graph.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_history.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patient_blood_pressure_view_cubit.dart';
import 'package:frontend/patients/data/patients_repository.dart';

/// Doctor/admin view for a patient's blood pressure data.
/// Shows two tabs: Records (list) and Graph.
@RoutePage()
class PatientBloodPressureViewPage extends StatelessWidget {
  const PatientBloodPressureViewPage({
    @PathParam('id') required this.patientId,
    this.patientName,
    super.key,
  });

  final int patientId;
  final String? patientName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = PatientBloodPressureViewCubit(
          patientsRepository: context.read<PatientsRepository>(),
          patientId: patientId,
        );
        // Load with default month filter (30 days)
        final defaultFromDate =
            DateTime.now().subtract(const Duration(days: 30));
        unawaited(cubit.loadData(fromDate: defaultFromDate));
        return cubit;
      },
      child: _PatientBloodPressureViewContent(patientName: patientName),
    );
  }
}

class _PatientBloodPressureViewContent extends StatefulWidget {
  const _PatientBloodPressureViewContent({this.patientName});

  final String? patientName;

  @override
  State<_PatientBloodPressureViewContent> createState() =>
      _PatientBloodPressureViewContentState();
}

class _PatientBloodPressureViewContentState
    extends State<_PatientBloodPressureViewContent>
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = widget.patientName ?? l10n.bloodPressureTitle;

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
          children: const [
            _RecordsTab(),
            _GraphTab(),
          ],
        ),
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientBloodPressureViewCubit,
        PatientBloodPressureViewState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BloodPressureHistory(
            readings: state.readings,
            isLoading: state.isLoading,
            // No delete callback for doctor view (read-only)
          ),
        );
      },
    );
  }
}

class _GraphTab extends StatelessWidget {
  const _GraphTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientBloodPressureViewCubit,
        PatientBloodPressureViewState>(
      builder: (context, state) {
        return BloodPressureGraph(
          readings: state.readings,
          isLoading: state.isLoading,
          onPeriodChanged: (period) {
            unawaited(
              context
                  .read<PatientBloodPressureViewCubit>()
                  .loadData(fromDate: period.toFromDate()),
            );
          },
        );
      },
    );
  }
}
