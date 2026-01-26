import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bmi/widgets/bmi_graph.dart';
import 'package:frontend/bmi/widgets/bmi_history.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patient_bmi_view_cubit.dart';
import 'package:frontend/patients/data/patients_repository.dart';

/// Doctor/admin view for a patient's BMI data.
/// Shows two tabs: Records (list) and Graph.
@RoutePage()
class PatientBmiViewPage extends StatelessWidget {
  const PatientBmiViewPage({
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
        final cubit = PatientBmiViewCubit(
          patientsRepository: context.read<PatientsRepository>(),
          patientId: patientId,
        );
        // Load with default month filter (30 days)
        final defaultFromDate =
            DateTime.now().subtract(const Duration(days: 30));
        unawaited(cubit.loadData(fromDate: defaultFromDate));
        return cubit;
      },
      child: _PatientBmiViewContent(patientName: patientName),
    );
  }
}

class _PatientBmiViewContent extends StatefulWidget {
  const _PatientBmiViewContent({this.patientName});

  final String? patientName;

  @override
  State<_PatientBmiViewContent> createState() => _PatientBmiViewContentState();
}

class _PatientBmiViewContentState extends State<_PatientBmiViewContent>
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
    final title = widget.patientName ?? l10n.bmiTitle;

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
    return BlocBuilder<PatientBmiViewCubit, PatientBmiViewState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BmiHistory(
            measurements: state.measurements,
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
    return BlocBuilder<PatientBmiViewCubit, PatientBmiViewState>(
      builder: (context, state) {
        return BmiGraph(
          measurements: state.measurements,
          isLoading: state.isLoading,
          onPeriodChanged: (period) {
            unawaited(
              context
                  .read<PatientBmiViewCubit>()
                  .loadData(fromDate: period.toFromDate()),
            );
          },
        );
      },
    );
  }
}
