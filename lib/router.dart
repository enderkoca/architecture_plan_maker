import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ui/pages/home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);