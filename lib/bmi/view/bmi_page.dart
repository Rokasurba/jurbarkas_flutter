import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bmi/cubit/bmi_cubit.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/bmi/data/repositories/bmi_repository.dart';
import 'package:frontend/bmi/widgets/bmi_form.dart';
import 'package:frontend/bmi/widgets/bmi_graph.dart';
import 'package:frontend/bmi/widgets/bmi_history.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';

@RoutePage()
class BmiPage extends StatelessWidget {
  const BmiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = BmiCubit(
          bmiRepository: BmiRepository(
            apiClient: context.read<ApiClient>(),
          ),
        );
        unawaited(cubit.loadHistory());
        return cubit;
      },
      child: const _BmiView(),
    );
  }
}

class _BmiView extends StatefulWidget {
  const _BmiView();

  @override
  State<_BmiView> createState() => _BmiViewState();
}

class _BmiViewState extends State<_BmiView>
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
      unawaited(context.read<BmiCubit>().loadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onDelete(BmiMeasurement measurement) {
    DeleteConfirmationDialog.show(
      context,
      onConfirm: () {
        Navigator.of(context).pop();
        unawaited(
          context.read<BmiCubit>().deleteMeasurement(id: measurement.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<BmiCubit, BmiState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: (measurement, measurements) {
            context.showSuccessSnackbar(l10n.dataSaved);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BmiCubit>().clearSavedState();
            });
          },
          deleted: (measurements) {
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
            l10n.bmiTitle,
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
  final void Function(BmiMeasurement measurement) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // History list with its own BlocBuilder
        Expanded(
          child: BlocBuilder<BmiCubit, BmiState>(
            builder: (context, state) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: BmiHistory(
                  measurements: state.measurements,
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
            child: BlocSelector<BmiCubit, BmiState, bool>(
              selector: (state) => state.isSaving,
              builder: (context, isSaving) {
                return BmiForm(
                  onSubmit: (heightCm, weightKg, measuredAt) {
                    unawaited(
                      context.read<BmiCubit>().saveMeasurement(
                            heightCm: heightCm,
                            weightKg: weightKg,
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
    return BlocBuilder<BmiCubit, BmiState>(
      builder: (context, state) {
        return BmiGraph(
          measurements: state.measurements,
          isLoading: state.isLoading,
        );
      },
    );
  }
}
