import 'package:go_router/go_router.dart';
import 'package:tp2_productos_thiago_ducau/screens/home_screen.dart';
import 'package:tp2_productos_thiago_ducau/screens/login_screen.dart';
import 'package:tp2_productos_thiago_ducau/screens/register_screen.dart';
import 'package:tp2_productos_thiago_ducau/screens/detail_screen.dart';
import 'package:tp2_productos_thiago_ducau/screens/results_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        final id = state.extra as String?;
        return DetailScreen(id: id ?? '');
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final results = state.extra as Map<String, dynamic>;
        return ResultsScreen(results: results);
      },
    ),
  ],
);