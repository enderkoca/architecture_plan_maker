import 'package:go_router/go_router.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/cost_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/cost',
      name: 'cost',
      builder: (context, state) => const CostPage(),
    ),
  ],
);