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
        // Load with default month filter (30 days)
        final defaultFromDate = DateTime.now().subtract(const Duration(days: 30));
        unawaited(cubit.loadHistory(fromDate: defaultFromDate));
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

  void _onDelete(BloodPressureReading reading) {
    unawaited(DeleteConfirmationDialog.show(
      context,
      onConfirm: () {
        Navigator.of(context).pop();
        unawaited(
          context.read<BloodPressureCubit>().deleteReading(id: reading.id),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<BloodPressureCubit, BloodPressureState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: (reading, readings) {
            context.showSuccessSnackbar(l10n.dataSaved);
            // Transition to loaded state after form has cleared
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BloodPressureCubit>().clearSavedState();
            });
          },
          deleted: (readings) {
            context.showSuccessSnackbar(l10n.dataDeleted);
          },
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
            l10n.bloodPressureTitle,
            style: context.appBarTitle,
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
              _RecordsTab(
                scrollController: _scrollController,
                onDelete: _onDelete,
              ),
              const _GraphTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({
    required this.scrollController,
    required this.onDelete,
  });

  final ScrollController scrollController;
  final void Function(BloodPressureReading reading) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // History list with its own BlocBuilder
        Expanded(
          child: BlocBuilder<BloodPressureCubit, BloodPressureState>(
            builder: (context, state) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: BloodPressureHistory(
                  readings: state.readings,
                  isLoading: state.isLoading,
                  isLoadingMore: state.isLoadingMore,
                  onDelete: onDelete,
                ),
              );
            },
          ),
        ),
        // Form container
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
            child: BlocSelector<BloodPressureCubit, BloodPressureState, bool>(
              selector: (state) => state.isSaving,
              builder: (context, isSaving) {
                return BloodPressureForm(
                  onSubmit: (systolic, diastolic, measuredAt) {
                    unawaited(
                      context.read<BloodPressureCubit>().saveReading(
                            systolic: systolic,
                            diastolic: diastolic,
                            measuredAt: measuredAt,
                          ),
                    );
                  },
                  isLoading: isSaving,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}


class _GraphTab extends StatelessWidget {
  const _GraphTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BloodPressureCubit, BloodPressureState>(
      builder: (context, state) {
        return BloodPressureGraph(
          readings: state.readings,
          isLoading: state.isLoading,
          onPeriodChanged: (period) {
            unawaited(
              context
                  .read<BloodPressureCubit>()
                  .loadHistory(fromDate: period.toFromDate()),
            );
          },
        );
      },
    );
  }
}
