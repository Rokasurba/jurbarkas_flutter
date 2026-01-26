import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/admin/view/admin_dashboard_page.dart';
import 'package:frontend/app/view/splash_page.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/auth/view/login_page.dart';
import 'package:frontend/auth/view/register_page.dart';
import 'package:frontend/blood_pressure/view/blood_pressure_page.dart';
import 'package:frontend/blood_sugar/view/blood_sugar_page.dart';
import 'package:frontend/bmi/view/bmi_page.dart';
import 'package:frontend/doctor/view/doctor_dashboard_page.dart';
import 'package:frontend/password_reset/cubit/password_reset_cubit.dart';
import 'package:frontend/password_reset/view/forgot_password_page.dart';
import 'package:frontend/password_reset/view/new_password_page.dart';
import 'package:frontend/password_reset/view/otp_verification_page.dart';
import 'package:frontend/patient/view/patient_dashboard_page.dart';
import 'package:frontend/patients/view/patient_blood_pressure_view_page.dart';
import 'package:frontend/patients/view/patient_blood_sugar_view_page.dart';
import 'package:frontend/patients/view/patient_bmi_view_page.dart';
import 'package:frontend/patients/view/patient_health_data_page.dart';
import 'package:frontend/patients/view/patient_profile_page.dart';
import 'package:frontend/patients/view/patients_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({required this.authCubit});

  final AuthCubit authCubit;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/splash',
      page: SplashRoute.page,
    ),
    AutoRoute(
      path: '/login',
      page: LoginRoute.page,
    ),
    AutoRoute(
      path: '/register',
      page: RegisterRoute.page,
    ),
    AutoRoute(
      path: '/forgot-password',
      page: ForgotPasswordRoute.page,
    ),
    AutoRoute(
      path: '/verify-otp',
      page: OtpVerificationRoute.page,
    ),
    AutoRoute(
      path: '/new-password',
      page: NewPasswordRoute.page,
    ),
    AutoRoute(
      path: '/patient',
      page: PatientDashboardRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/blood-pressure',
      page: BloodPressureRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/bmi',
      page: BmiRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/blood-sugar',
      page: BloodSugarRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/doctor',
      page: DoctorDashboardRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/admin',
      page: AdminDashboardRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/patients',
      page: PatientsRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/patients/:id',
      page: PatientProfileRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/patients/:id/health-data',
      page: PatientHealthDataRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/patients/:id/blood-pressure',
      page: PatientBloodPressureViewRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/patients/:id/blood-sugar',
      page: PatientBloodSugarViewRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/patients/:id/bmi',
      page: PatientBmiViewRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    RedirectRoute(path: '/', redirectTo: '/splash'),
  ];

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRouteGuard> get guards => [];
}

class AuthGuard extends AutoRouteGuard {
  AuthGuard(this.authCubit);

  final AuthCubit authCubit;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (authCubit.state.isAuthenticated) {
      resolver.next();
    } else {
      unawaited(resolver.redirect(const LoginRoute()));
    }
  }
}

extension AppRouterExtension on AuthCubit {
  PageRouteInfo getHomeRouteForRole() {
    final role = state.user?.role;
    return switch (role) {
      'patient' => const PatientDashboardRoute(),
      'doctor' => const DoctorDashboardRoute(),
      'admin' => const AdminDashboardRoute(),
      _ => const LoginRoute(),
    };
  }
}
