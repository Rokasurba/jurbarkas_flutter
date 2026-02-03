import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/admin/cubit/admin_doctor_detail_cubit.dart';
import 'package:frontend/admin/data/admin_repository.dart';
import 'package:frontend/admin/view/widgets/doctor_detail/doctor_detail.dart';
import 'package:frontend/core/core.dart';

@RoutePage()
class DoctorDetailPage extends StatelessWidget {
  const DoctorDetailPage({
    @PathParam('doctorId') required this.doctorId,
    super.key,
  });

  final int doctorId;

  @override
  Widget build(BuildContext context) {
    debugPrint('[DoctorDetailPage] build() called for doctorId: $doctorId');
    return BlocProvider(
      create: (context) {
        debugPrint('[DoctorDetailPage] Creating AdminDoctorDetailCubit');
        final cubit = AdminDoctorDetailCubit(
          adminRepository:
              AdminRepository(apiClient: context.read<ApiClient>()),
          doctorId: doctorId,
        );
        unawaited(cubit.loadDoctor());
        return cubit;
      },
      child: const DoctorDetailView(),
    );
  }
}
