import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/admin/view/admin_dashboard_page.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/auth/view/login_page.dart';
import 'package:frontend/auth/view/register_page.dart';
import 'package:frontend/doctor/view/doctor_dashboard_page.dart';
import 'package:frontend/password_reset/cubit/password_reset_cubit.dart';
import 'package:frontend/password_reset/view/forgot_password_page.dart';
import 'package:frontend/password_reset/view/new_password_page.dart';
import 'package:frontend/password_reset/view/otp_verification_page.dart';
import 'package:frontend/patient/view/patient_dashboard_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({required this.authCubit});

  final AuthCubit authCubit;

  @override
  List<AutoRoute> get routes => [
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
          path: '/doctor',
          page: DoctorDashboardRoute.page,
          guards: [AuthGuard(authCubit)],
        ),
        AutoRoute(
          path: '/admin',
          page: AdminDashboardRoute.page,
          guards: [AuthGuard(authCubit)],
        ),
        RedirectRoute(path: '/', redirectTo: '/login'),
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
      resolver.redirect(const LoginRoute());
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
