import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/role_selection_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/donor_dashboard.dart';
import '../features/dashboard/presentation/screens/ngo_dashboard.dart';
import '../features/dashboard/presentation/screens/volunteer_dashboard.dart';
import '../features/donations/presentation/screens/create_donation_screen.dart';
import '../features/map/presentation/screens/live_map_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.roleSelection,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'donor';
        return RegisterScreen(role: role);
      },
    ),
    GoRoute(
      path: RouteNames.donorDashboard,
      builder: (context, state) => const DonorDashboard(),
    ),
    GoRoute(
      path: RouteNames.donorCreateDonation,
      builder: (context, state) => const CreateDonationScreen(),
    ),
    GoRoute(
      path: RouteNames.ngoDashboard,
      builder: (context, state) => const NgoDashboard(),
    ),
    GoRoute(
      path: RouteNames.volunteerDashboard,
      builder: (context, state) => const VolunteerDashboard(),
    ),
    GoRoute(
      path: '/live-map',
      builder: (context, state) => const LiveMapScreen(),
    ),
  ],
);
