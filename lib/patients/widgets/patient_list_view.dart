import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/cubit/patients_cubit.dart';
import 'package:frontend/patients/widgets/patient_card.dart';

/// A reusable widget that displays a list of patients with infinite scroll.
///
/// This widget handles:
/// - Loading state with spinner
/// - Error state with retry button
/// - Empty state with message (different for search vs initial)
/// - Infinite scroll pagination
/// - Patient card tap callbacks
class PatientListView extends StatefulWidget {
  const PatientListView({
    required this.onPatientTap,
    super.key,
  });

  /// Callback when a patient card is tapped.
  final void Function(int patientId) onPatientTap;

  @override
  State<PatientListView> createState() => _PatientListViewState();
}

class _PatientListViewState extends State<PatientListView> {
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
    if (_isNearBottom) {
      unawaited(context.read<PatientsCubit>().loadMore());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more when within 200 pixels of the bottom
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<PatientsCubit, PatientsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: (_) => const Center(child: CircularProgressIndicator()),
          loaded: (patients, total, hasMore, isLoadingMore, searchParams) {
            final isSearchActive = searchParams.hasActiveFilters;
            if (patients.isEmpty) {
              return _EmptyState(
                message: isSearchActive ? l10n.noPatientsFound : l10n.noPatients,
                isSearchResult: isSearchActive,
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: patients.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == patients.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final patient = patients[index];
                return Column(
                  children: [
                    PatientCard(
                      patient: patient,
                      onTap: () => widget.onPatientTap(patient.id),
                    ),
                    if (index < patients.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                );
              },
            );
          },
          error: (message, _) => _ErrorState(
            message: message,
            onRetry: () {
              unawaited(context.read<PatientsCubit>().loadPatients());
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    this.isSearchResult = false,
  });

  final String message;
  final bool isSearchResult;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: AppColors.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: context.bodyLarge?.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
