import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/admin.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';
import 'package:intl/intl.dart';

@RoutePage()
class AdminPatientEditPage extends StatelessWidget {
  const AdminPatientEditPage({
    @PathParam('patientId') required this.patientId,
    required this.patient,
    super.key,
  });

  final int patientId;
  final PatientProfile patient;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminPatientDetailCubit(
        adminRepository: AdminRepository(
          apiClient: context.read<ApiClient>(),
        ),
      ),
      child: AdminPatientEditView(
        patientId: patientId,
        patient: patient,
      ),
    );
  }
}

class AdminPatientEditView extends StatefulWidget {
  const AdminPatientEditView({
    required this.patientId,
    required this.patient,
    super.key,
  });

  final int patientId;
  final PatientProfile patient;

  @override
  State<AdminPatientEditView> createState() => _AdminPatientEditViewState();
}

class _AdminPatientEditViewState extends State<AdminPatientEditView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _patientCodeController;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient.name);
    _surnameController = TextEditingController(text: widget.patient.surname);
    _phoneController = TextEditingController(text: widget.patient.phone ?? '');
    _patientCodeController =
        TextEditingController(text: widget.patient.patientCode ?? '');
    _selectedDateOfBirth = widget.patient.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _patientCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdatePatientRequest(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      dateOfBirth: _selectedDateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!)
          : null,
      patientCode: _patientCodeController.text.trim().isNotEmpty
          ? _patientCodeController.text.trim()
          : null,
    );

    unawaited(
      context.read<AdminPatientDetailCubit>().updatePatient(
            widget.patientId,
            request,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: Text(
          l10n.redaguotiPacienta,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<AdminPatientDetailCubit, AdminPatientDetailState>(
        listener: (context, state) {
          state.whenOrNull(
            updateSuccess: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.pacientasAtnaujintas),
                  backgroundColor: Colors.green,
                ),
              );
              unawaited(context.router.maybePop(true));
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state is AdminPatientDetailUpdating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.nameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _surnameController,
                    decoration: InputDecoration(
                      labelText: l10n.surnameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.surnameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.phoneLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDateOfBirth,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.dateOfBirthLabel,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      ),
                      child: Text(
                        _selectedDateOfBirth != null
                            ? DateFormat('yyyy-MM-dd')
                                .format(_selectedDateOfBirth!)
                            : '-',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _patientCodeController,
                    decoration: InputDecoration(
                      labelText: l10n.patientCodeLabel,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.saveButton),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
