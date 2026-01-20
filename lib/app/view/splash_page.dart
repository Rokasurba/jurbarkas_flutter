import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/auth/cubit/auth_cubit.dart';
import 'package:frontend/core/core.dart';
import 'package:frontend/core/router/app_router.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        unawaited(state.whenOrNull(
          authenticated: (_) async {
            final homeRoute =
                context.read<AuthCubit>().getHomeRouteForRole();
            await context.router.replaceAll([homeRoute]);
          },
          unauthenticated: () async {
            await context.router.replaceAll([const LoginRoute()]);
          },
          error: (_) async {
            await context.router.replaceAll([const LoginRoute()]);
          },
        ));
      },
      child: const Scaffold(
        backgroundColor: AppColors.secondary,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
