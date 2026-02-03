import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/auth.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/password_reset/password_reset.dart';
import 'package:frontend/patients/data/patients_repository.dart';
import 'package:frontend/survey/data/survey_repository.dart';

/// Global key for showing snackbars from anywhere in the app.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Root application widget that sets up dependency injection and routing.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppProviders(
      child: _AppView(),
    );
  }
}

/// Provides all dependencies to the widget tree.
class _AppProviders extends StatefulWidget {
  const _AppProviders({required this.child});

  final Widget child;

  @override
  State<_AppProviders> createState() => _AppProvidersState();
}

class _AppProvidersState extends State<_AppProviders> {
  final _secureStorage = SecureStorage();
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final PasswordResetRepository _passwordResetRepository;
  late final PatientsRepository _patientsRepository;
  late final SurveyRepository _surveyRepository;
  late final AuthCubit _authCubit;
  StreamSubscription<AuthEvent>? _authEventSubscription;
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _pushNotificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(secureStorage: _secureStorage);
    _authRepository = AuthRepository(
      apiClient: _apiClient,
      secureStorage: _secureStorage,
    );
    _passwordResetRepository = PasswordResetRepository(
      apiClient: _apiClient,
      secureStorage: _secureStorage,
    );
    _patientsRepository = PatientsRepository(apiClient: _apiClient);
    _surveyRepository = SurveyRepository(apiClient: _apiClient);
    _authCubit = AuthCubit(authRepository: _authRepository);

    // Listen to auth events from the API layer
    _authEventSubscription =
        AuthEventController.instance.stream.listen(_onAuthEvent);

    // Listen to auth state to initialize push notifications after login
    _authStateSubscription = _authCubit.stream.listen(_onAuthStateChanged);

    unawaited(_authCubit.checkAuthStatus());
  }

  Future<void> _onAuthStateChanged(AuthState state) async {
    await state.whenOrNull(
      authenticated: (_) => _initializePushNotifications(),
      unauthenticated: () {
        _pushNotificationsInitialized = false;
        PushNotificationService.instance.dispose();
      },
    );
  }

  Future<void> _initializePushNotifications() async {
    if (_pushNotificationsInitialized || kIsWeb) return;
    _pushNotificationsInitialized = true;

    PushNotificationService.instance.onTokenRefresh = _onDeviceTokenReceived;
    PushNotificationService.instance.onForegroundMessage =
        _onForegroundNotification;
    await PushNotificationService.instance.initialize();
  }

  void _onForegroundNotification(RemoteMessage message) {
    final title = message.notification?.title;
    final body = message.notification?.body;

    if (title != null || body != null) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (body != null) Text(body),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onDeviceTokenReceived(String token) async {
    log('Registering device token with backend');
    final result = await _authRepository.registerDeviceToken(token);
    result.when(
      success: (data, message) => log('Device token registered successfully'),
      error: (message, errors) =>
          log('Failed to register device token: $message'),
    );
  }

  void _onAuthEvent(AuthEvent event) {
    switch (event) {
      case AuthEvent.authenticationFailed:
        _authCubit.onSessionExpired();
    }
  }

  @override
  void dispose() {
    unawaited(_authEventSubscription?.cancel());
    unawaited(_authStateSubscription?.cancel());
    PushNotificationService.instance.dispose();
    unawaited(_authCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: _apiClient),
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _passwordResetRepository),
        RepositoryProvider.value(value: _patientsRepository),
        RepositoryProvider.value(value: _surveyRepository),
      ],
      child: BlocProvider.value(
        value: _authCubit,
        child: widget.child,
      ),
    );
  }
}

/// Main app view with MaterialApp and routing.
class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final AppRouter _appRouter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appRouter = AppRouter(authCubit: context.read<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('lt'),
      routerConfig: _appRouter.config(),
    );
  }
}
