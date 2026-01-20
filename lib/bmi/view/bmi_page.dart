import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bmi/cubit/bmi_cubit.dart';
import 'package:frontend/bmi/data/models/bmi_measurement.dart';
import 'package:frontend/bmi/data/repositories/bmi_repository.dart';
import 'package:frontend/bmi/widgets/bmi_form.dart';
import 'package:frontend/bmi/widgets/bmi_history.dart';
import 'package:frontend/bmi/widgets/edit_bmi_sheet.dart';
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

class _BmiViewState extends State<_BmiView> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<BmiFormState>();

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
      unawaited(context.read<BmiCubit>().loadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onEdit(BmiMeasurement measurement) {
    EditBmiSheet.show(
      context,
      measurement: measurement,
      onUpdate: (heightCm, weightKg) {
        unawaited(
          context.read<BmiCubit>().updateMeasurement(
                id: measurement.id,
                heightCm: heightCm,
                weightKg: weightKg,
              ),
        );
      },
      isLoading: false,
    );
  }

  void _onDelete(BmiMeasurement measurement) {
    DeleteConfirmationDialog.show(
      context,
      onConfirm: () {
        unawaited(
          context.read<BmiCubit>().deleteMeasurement(id: measurement.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<BmiCubit, BmiState>(
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
            context.read<BmiCubit>().clearSavedState();
          },
          updated: (_, _) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataUpdated),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<BmiCubit>().clearUpdatedState();
          },
          deleted: (_) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataDeleted),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<BmiCubit>().clearDeletedState();
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
            title: Text(l10n.bmiTitle),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BmiHistory(
                    measurements: state.measurements,
                    isLoading: state.isLoading,
                    isLoadingMore: state.isLoadingMore,
                    onEdit: _onEdit,
                    onDelete: _onDelete,
                  ),
                  const SizedBox(height: 24),
                  BmiForm(
                    key: _formKey,
                    onSubmit: (heightCm, weightKg) {
                      unawaited(
                        context.read<BmiCubit>().saveMeasurement(
                              heightCm: heightCm,
                              weightKg: weightKg,
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
