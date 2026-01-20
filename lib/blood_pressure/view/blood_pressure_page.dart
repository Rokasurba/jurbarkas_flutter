import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_pressure/cubit/blood_pressure_cubit.dart';
import 'package:frontend/blood_pressure/data/models/blood_pressure_reading.dart';
import 'package:frontend/blood_pressure/data/repositories/blood_pressure_repository.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_form.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_graph.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_history.dart';
import 'package:frontend/blood_pressure/widgets/edit_blood_pressure_sheet.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class BloodPressurePage extends StatelessWidget {
  const BloodPressurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = BloodPressureCubit(
          bloodPressureRepository: BloodPressureRepository(
            apiClient: context.read<ApiClient>(),
          ),
        );
        unawaited(cubit.loadHistory());
        return cubit;
      },
      child: const _BloodPressureView(),
    );
  }
}

class _BloodPressureView extends StatefulWidget {
  const _BloodPressureView();

  @override
  State<_BloodPressureView> createState() => _BloodPressureViewState();
}

class _BloodPressureViewState extends State<_BloodPressureView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<BloodPressureFormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      unawaited(context.read<BloodPressureCubit>().loadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onEdit(BloodPressureReading reading) {
    EditBloodPressureSheet.show(
      context,
      reading: reading,
      onUpdate: (systolic, diastolic) {
        unawaited(
          context.read<BloodPressureCubit>().updateReading(
                id: reading.id,
                systolic: systolic,
                diastolic: diastolic,
              ),
        );
      },
      isLoading: false,
    );
  }

  void _onDelete(BloodPressureReading reading) {
    DeleteConfirmationDialog.show(
      context,
      onConfirm: () {
        Navigator.of(context).pop();
        unawaited(
          context.read<BloodPressureCubit>().deleteReading(id: reading.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<BloodPressureCubit, BloodPressureState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: (_, _) {
            _formKey.currentState?.clearForm();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataSaved),
                backgroundColor: AppColors.primary,
              ),
            );
            // No need to clear - cubit emits loaded immediately after saved
          },
          updated: (_, _) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataUpdated),
                backgroundColor: AppColors.primary,
              ),
            );
            // No need to clear - cubit emits loaded immediately after updated
          },
          deleted: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataDeleted),
                backgroundColor: AppColors.primary,
              ),
            );
            // No need to clear - cubit emits loaded immediately after deleted
          },
          failure: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: context.errorColor,
              ),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: Text(l10n.bloodPressureTitle),
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
                _RecordsTab(
                  scrollController: _scrollController,
                  formKey: _formKey,
                  state: state,
                  onEdit: _onEdit,
                  onDelete: _onDelete,
                ),
                BloodPressureGraph(
                  readings: state.readings,
                  isLoading: state.isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({
    required this.scrollController,
    required this.formKey,
    required this.state,
    required this.onEdit,
    required this.onDelete,
  });

  final ScrollController scrollController;
  final GlobalKey<BloodPressureFormState> formKey;
  final BloodPressureState state;
  final void Function(BloodPressureReading reading) onEdit;
  final void Function(BloodPressureReading reading) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: BloodPressureHistory(
              readings: state.readings,
              isLoading: state.isLoading,
              isLoadingMore: state.isLoadingMore,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BloodPressureForm(
              key: formKey,
              onSubmit: (systolic, diastolic) {
                unawaited(
                  context.read<BloodPressureCubit>().saveReading(
                        systolic: systolic,
                        diastolic: diastolic,
                      ),
                );
              },
              isLoading: state.isSaving,
            ),
          ),
        ),
      ],
    );
  }
}
