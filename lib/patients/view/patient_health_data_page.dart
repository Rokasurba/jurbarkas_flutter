import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patient_health_data_cubit.dart';
import 'package:frontend/patients/data/models/patient_health_data_params.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/patients/widgets/patient_blood_pressure_view.dart';
import 'package:frontend/patients/widgets/patient_blood_sugar_view.dart';
import 'package:frontend/patients/widgets/patient_bmi_view.dart';

/// Patient health data page with tabs for blood pressure, BMI, and blood sugar.
/// Read-only view for doctors/admins to view patient health data.
@RoutePage()
class PatientHealthDataPage extends StatelessWidget {
  const PatientHealthDataPage({
    @PathParam('id') required this.patientId,
    this.patientName,
    this.initialTab = 0,
    super.key,
  });

  final int patientId;
  final String? patientName;
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = PatientHealthDataCubit(
          patientsRepository: context.read<PatientsRepository>(),
          patientId: patientId,
        );
        // Load with default 30 days of data
        final defaultFromDate = DateTime.now().subtract(const Duration(days: 30));
        final params = PatientHealthDataParams.fromDate(defaultFromDate);
        unawaited(cubit.loadHealthData(params: params));
        return cubit;
      },
      child: _PatientHealthDataView(
        patientName: patientName,
        initialTab: initialTab,
      ),
    );
  }
}

class _PatientHealthDataView extends StatefulWidget {
  const _PatientHealthDataView({
    this.patientName,
    this.initialTab = 0,
  });

  final String? patientName;
  final int initialTab;

  @override
  State<_PatientHealthDataView> createState() => _PatientHealthDataViewState();
}

class _PatientHealthDataViewState extends State<_PatientHealthDataView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = widget.patientName ?? l10n.patientHealthDataTitle;

    return BlocListener<PatientHealthDataCubit, PatientHealthDataState>(
      listener: (context, state) {
        state.maybeWhen(
          failure: (message) {
            context.showErrorSnackbar(message);
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          title: Text(
            title,
            style: context.appBarTitle,
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: l10n.tabBloodPressure),
              Tab(text: l10n.tabBmi),
              Tab(text: l10n.tabBloodSugar),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: const [
              PatientBloodPressureView(),
              PatientBmiView(),
              PatientBloodSugarView(),
            ],
          ),
        ),
      ),
    );
  }
}
