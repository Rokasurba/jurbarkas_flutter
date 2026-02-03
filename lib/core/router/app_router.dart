import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/admin/view/activity_log_list_page.dart';
import 'package:frontend/admin/view/admin_menu_page.dart';
import 'package:frontend/admin/view/admin_patient_edit_page.dart';
import 'package:frontend/admin/view/admin_shell_page.dart';
import 'package:frontend/admin/view/doctor_detail_page.dart';
import 'package:frontend/admin/view/doctor_form_page.dart';
import 'package:frontend/admin/view/doctor_list_page.dart';
import 'package:frontend/app/view/splash_page.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/auth/view/login_page.dart';
import 'package:frontend/auth/view/register_page.dart';
import 'package:frontend/blood_pressure/view/blood_pressure_page.dart';
import 'package:frontend/blood_sugar/view/blood_sugar_page.dart';
import 'package:frontend/bmi/view/bmi_page.dart';
import 'package:frontend/chat/data/models/user_brief.dart';
import 'package:frontend/chat/view/chat_page.dart';
import 'package:frontend/chat/view/conversations_page.dart';
import 'package:frontend/doctor/view/doctor_dashboard_page.dart';
import 'package:frontend/doctor/view/doctor_shell_page.dart';
import 'package:frontend/password_reset/cubit/password_reset_cubit.dart';
import 'package:frontend/password_reset/view/forgot_password_page.dart';
import 'package:frontend/password_reset/view/new_password_page.dart';
import 'package:frontend/password_reset/view/otp_verification_page.dart';
import 'package:frontend/patient/view/patient_dashboard_page.dart';
import 'package:frontend/patient/view/patient_shell_page.dart';
import 'package:frontend/patients/cubit/patient_metric_view_cubit.dart';
import 'package:frontend/patients/data/models/patient_profile.dart';
import 'package:frontend/patients/view/patient_metric_view_page.dart';
import 'package:frontend/patients/view/patient_profile_page.dart';
import 'package:frontend/patients/view/patients_page.dart';
import 'package:frontend/reminders/view/reminders_page.dart';
import 'package:frontend/reminders/view/send_reminder_page.dart';
import 'package:frontend/survey/view/aggregated_results_page.dart';
import 'package:frontend/survey/view/doctor_survey_results_page.dart';
import 'package:frontend/survey/view/my_surveys_page.dart';
import 'package:frontend/survey/view/patient_surveys_page.dart';
import 'package:frontend/survey/view/survey_assignment_page.dart';
import 'package:frontend/survey/view/survey_builder_page.dart';
import 'package:frontend/survey/view/survey_completion_page.dart';
import 'package:frontend/survey/view/survey_management_page.dart';
import 'package:frontend/survey/view/survey_results_overview_page.dart';
import 'package:frontend/profile/view/change_password_page.dart';
import 'package:frontend/profile/view/legal_document_page.dart';
import 'package:frontend/profile/view/profile_page.dart';

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

    // Patient shell with nested tab routes
    AutoRoute(
      path: '/patient',
      page: PatientShellRoute.page,
      guards: [AuthGuard(authCubit)],
      children: [
        AutoRoute(path: 'dashboard', page: PatientDashboardRoute.page),
        AutoRoute(path: 'messages', page: ConversationsRoute.page),
        AutoRoute(path: 'reminders', page: RemindersRoute.page),
        AutoRoute(path: 'surveys', page: MySurveysRoute.page),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
        RedirectRoute(path: '', redirectTo: 'dashboard'),
      ],
    ),

    // Doctor shell with nested tab routes
    AutoRoute(
      path: '/doctor',
      page: DoctorShellRoute.page,
      guards: [AuthGuard(authCubit)],
      children: [
        AutoRoute(path: 'dashboard', page: DoctorDashboardRoute.page),
        AutoRoute(path: 'messages', page: ConversationsRoute.page),
        AutoRoute(path: 'surveys', page: SurveyManagementRoute.page),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
        RedirectRoute(path: '', redirectTo: 'dashboard'),
      ],
    ),

    // Admin shell with menu page
    AutoRoute(
      path: '/admin',
      page: AdminShellRoute.page,
      guards: [AuthGuard(authCubit)],
      children: [
        AutoRoute(path: 'menu', page: AdminMenuRoute.page),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
        RedirectRoute(path: '', redirectTo: 'menu'),
      ],
    ),

    // Detail routes (outside shells - no bottom nav)
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
      path: '/admin/doctors',
      page: DoctorListRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/admin/doctors/new',
      page: DoctorFormRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/admin/doctors/:doctorId',
      page: DoctorDetailRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/admin/patients/:patientId/edit',
      page: AdminPatientEditRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/admin/activity-logs',
      page: ActivityLogListRoute.page,
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
      path: '/patients/:id/metric',
      page: PatientMetricViewRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/send-reminder',
      page: SendReminderRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/chat/:conversationId',
      page: ChatRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/doctor/surveys/new',
      page: SurveyBuilderRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/doctor/surveys/:surveyId/edit',
      page: SurveyBuilderRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/doctor/surveys/:surveyId/assign',
      page: SurveyAssignmentRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/surveys/:assignmentId',
      page: SurveyCompletionRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/surveys/:surveyId/results',
      page: SurveyResultsOverviewRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/surveys/:surveyId/results/aggregated',
      page: AggregatedResultsRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/surveys/:surveyId/results/:patientId',
      page: DoctorSurveyResultsRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/patients/:patientId/surveys',
      page: PatientSurveysRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/change-password',
      page: ChangePasswordRoute.page,
      guards: [AuthGuard(authCubit)],
    ),
    AutoRoute(
      path: '/legal/:documentType',
      page: LegalDocumentRoute.page,
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
    final state = authCubit.state;

    if (state.isAuthenticated) {
      resolver.next();
    } else if (state is AuthInitial || state.isLoading) {
      // Auth state not yet determined, redirect to splash to wait
      unawaited(resolver.redirect(const SplashRoute()));
    } else {
      // Unauthenticated or error
      unawaited(resolver.redirect(const LoginRoute()));
    }
  }
}

extension AppRouterExtension on AuthCubit {
  PageRouteInfo getHomeRouteForRole() {
    final role = state.user?.role;
    return switch (role) {
      'patient' => const PatientShellRoute(),
      'doctor' => const DoctorShellRoute(),
      'admin' => const AdminShellRoute(),
      _ => const LoginRoute(),
    };
  }
}
