import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_sugar/cubit/blood_sugar_cubit.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/blood_sugar/data/repositories/blood_sugar_repository.dart';
import 'package:frontend/blood_sugar/widgets/blood_sugar_form.dart';
import 'package:frontend/blood_sugar/widgets/blood_sugar_graph.dart';
import 'package:frontend/blood_sugar/widgets/blood_sugar_history.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class BloodSugarPage extends StatelessWidget {
  const BloodSugarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = BloodSugarCubit(
          bloodSugarRepository: BloodSugarRepository(
            apiClient: context.read<ApiClient>(),
          ),
        );
        // Load with default month filter (30 days)
        final defaultFromDate = DateTime.now().subtract(const Duration(days: 30));
        unawaited(cubit.loadHistory(fromDate: defaultFromDate));
        return cubit;
      },
      child: const _BloodSugarView(),
    );
  }
}

class _BloodSugarView extends StatefulWidget {
  const _BloodSugarView();

  @override
  State<_BloodSugarView> createState() => _BloodSugarViewState();
}

class _BloodSugarViewState extends State<_BloodSugarView>
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
      unawaited(context.read<BloodSugarCubit>().loadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onDelete(BloodSugarReading reading) {
    DeleteConfirmationDialog.show(
      context,
      onConfirm: () {
        Navigator.of(context).pop();
        unawaited(
          context.read<BloodSugarCubit>().deleteReading(id: reading.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<BloodSugarCubit, BloodSugarState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: (reading, readings) {
            context.showSuccessSnackbar(l10n.dataSaved);
            // Transition to loaded state after form has cleared
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BloodSugarCubit>().clearSavedState();
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
            l10n.bloodSugarTitle,
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
  final void Function(BloodSugarReading reading) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // History list with its own BlocBuilder
        Expanded(
          child: BlocBuilder<BloodSugarCubit, BloodSugarState>(
            builder: (context, state) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: BloodSugarHistory(
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
            child: BlocSelector<BloodSugarCubit, BloodSugarState, bool>(
              selector: (state) => state.isSaving,
              builder: (context, isSaving) {
                return BloodSugarForm(
                  onSubmit: (glucoseLevel, measuredAt) {
                    unawaited(
                      context.read<BloodSugarCubit>().saveReading(
                            glucoseLevel: glucoseLevel,
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
    return BlocBuilder<BloodSugarCubit, BloodSugarState>(
      builder: (context, state) {
        return BloodSugarGraph(
          readings: state.readings,
          isLoading: state.isLoading,
          onPeriodChanged: (period) {
            unawaited(
              context
                  .read<BloodSugarCubit>()
                  .loadHistory(fromDate: period.toFromDate()),
            );
          },
        );
      },
    );
  }
}
