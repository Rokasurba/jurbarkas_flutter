import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_pressure/cubit/blood_pressure_cubit.dart';
import 'package:frontend/blood_pressure/data/repositories/blood_pressure_repository.dart';
import 'package:frontend/blood_pressure/widgets/blood_pressure_form.dart';
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

class _BloodPressureViewState extends State<_BloodPressureView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<BloodPressureCubit, BloodPressureState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: (_, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataSaved),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<BloodPressureCubit>().clearSavedState();
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
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BloodPressureHistory(
                    readings: state.readings,
                    isLoading: state.isLoading,
                    isLoadingMore: state.isLoadingMore,
                  ),
                  const SizedBox(height: 24),
                  BloodPressureForm(
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
