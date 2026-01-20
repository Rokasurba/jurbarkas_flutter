import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bmi/cubit/bmi_cubit.dart';
import 'package:frontend/bmi/data/repositories/bmi_repository.dart';
import 'package:frontend/bmi/widgets/bmi_form.dart';
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

class _BmiView extends StatelessWidget {
  const _BmiView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<BmiCubit, BmiState>(
      listener: (context, state) {
        state.maybeWhen(
          saved: (_, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.dataSaved),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<BmiCubit>().clearSavedState();
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BmiHistory(
                    measurements: state.measurements,
                    isLoading: state.isLoading,
                  ),
                  const SizedBox(height: 24),
                  BmiForm(
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
