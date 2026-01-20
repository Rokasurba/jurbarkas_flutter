import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blood_sugar/cubit/blood_sugar_cubit.dart';
import 'package:frontend/blood_sugar/data/models/blood_sugar_reading.dart';
import 'package:frontend/blood_sugar/data/repositories/blood_sugar_repository.dart';
import 'package:frontend/blood_sugar/widgets/blood_sugar_form.dart';
import 'package:frontend/blood_sugar/widgets/blood_sugar_history.dart';
import 'package:frontend/blood_sugar/widgets/edit_blood_sugar_sheet.dart';
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
        unawaited(cubit.loadHistory());
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

class _BloodSugarViewState extends State<_BloodSugarView> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<BloodSugarFormState>();

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
      unawaited(context.read<BloodSugarCubit>().loadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onEdit(BloodSugarReading reading) {
    EditBloodSugarSheet.show(
      context,
      reading: reading,
      onUpdate: (glucoseLevel) {
        unawaited(
          context.read<BloodSugarCubit>().updateReading(
                id: reading.id,
                glucoseLevel: glucoseLevel,
              ),
        );
      },
      isLoading: false,
    );
  }

  void _onDelete(BloodSugarReading reading) {
    DeleteConfirmationDialog.show(
      context,
      onConfirm: () {
        unawaited(
          context.read<BloodSugarCubit>().deleteReading(id: reading.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<BloodSugarCubit, BloodSugarState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: (_, __) {
            _formKey.currentState?.clearForm();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataSaved),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<BloodSugarCubit>().clearSavedState();
          },
          updated: (_, __) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataUpdated),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<BloodSugarCubit>().clearUpdatedState();
          },
          deleted: (_) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataDeleted),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<BloodSugarCubit>().clearDeletedState();
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
            title: Text(l10n.bloodSugarTitle),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BloodSugarHistory(
                    readings: state.readings,
                    isLoading: state.isLoading,
                    isLoadingMore: state.isLoadingMore,
                    onEdit: _onEdit,
                    onDelete: _onDelete,
                  ),
                  const SizedBox(height: 24),
                  BloodSugarForm(
                    key: _formKey,
                    onSubmit: (glucoseLevel) {
                      unawaited(
                        context.read<BloodSugarCubit>().saveReading(
                              glucoseLevel: glucoseLevel,
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
