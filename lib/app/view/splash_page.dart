import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Check current state after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAuthState(context.read<AuthCubit>().state);
    });
  }

  void _handleAuthState(AuthState state) {
    unawaited(state.whenOrNull(
      authenticated: (_) async {
        final homeRoute = context.read<AuthCubit>().getHomeRouteForRole();
        await context.router.replaceAll([homeRoute]);
      },
      unauthenticated: () async {
        await context.router.replaceAll([const LoginRoute()]);
      },
      error: (_) async {
        await context.router.replaceAll([const LoginRoute()]);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) => _handleAuthState(state),
      child: Scaffold(
        backgroundColor: AppColors.secondary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Assets.logoBanner,
                width: 250,
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
