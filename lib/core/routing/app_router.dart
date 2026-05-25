import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/complete_profile_screen.dart';
import '../../features/dashboard/home_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/complaints/complaints_screen.dart';
import '../../features/complaints/new_complaint_screen.dart';
import '../../features/complaints/complaint_detail_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/announcements/announcements_screen.dart';
import '../../features/announcements/announcement_detail_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/directory/directory_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/staff/staff_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/elearning/elearning_screen.dart';
import '../../features/services/services_screen.dart';
import '../../features/workspace/workspace_screen.dart';
import '../../features/workspace/course_detail_screen.dart';
import '../../features/workspace/submissions_screen.dart';
import '../../features/lecturer/lecturer_home_screen.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/data_provider.dart';
import '../widgets/campus_nav_bar.dart';
import 'app_routes.dart';

export 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final userProfile = ref.read(currentUserProvider).valueOrNull;
      
      final loc = state.matchedLocation;
      const authRoutes = [
        AppRoutes.login, AppRoutes.register, AppRoutes.forgotPw,
        AppRoutes.onboarding, AppRoutes.splash,
      ];
      
      if (!isLoggedIn && !authRoutes.contains(loc)) return AppRoutes.login;
      
      if (isLoggedIn) {
        // Enforce cohort selection for students
        if (userProfile != null && userProfile.role == UserRole.student) {
          final missingCohort = userProfile.cohort == null || userProfile.cohort!.trim().isEmpty;
          final hasSkipped = ref.read(profileSetupSkippedProvider);
          if (missingCohort && !hasSkipped && loc != AppRoutes.completeProfile) {
            return AppRoutes.completeProfile;
          } else if ((!missingCohort || hasSkipped) && loc == AppRoutes.completeProfile) {
            return AppRoutes.home;
          }
        }

        if (authRoutes.contains(loc) && loc != AppRoutes.splash) {
          if (userProfile != null && userProfile.role == UserRole.admin) {
            return AppRoutes.admin;
          }
          if (userProfile != null && userProfile.role == UserRole.lecturer) {
            return AppRoutes.lecturer;
          }
          if (userProfile != null && userProfile.role == UserRole.staff) {
            return AppRoutes.staff;
          }
          if (userProfile != null && userProfile.role == UserRole.student) {
            final missingCohort = userProfile.cohort == null || userProfile.cohort!.trim().isEmpty;
            final hasSkipped = ref.read(profileSetupSkippedProvider);
            if (missingCohort && !hasSkipped) {
              return AppRoutes.completeProfile;
            }
          }
          return AppRoutes.home;
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash,     builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login,      builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register,   builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPw,   builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.completeProfile, builder: (_, __) => const CompleteProfileScreen()),

      // ── Main shell with bottom nav ──────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: AppRoutes.home,      builder: (_, __) => const HomeScreen()),
          GoRoute(path: AppRoutes.schedule,  builder: (_, __) => const ScheduleScreen()),
          GoRoute(
            path: AppRoutes.announcements,
            builder: (_, state) => AnnouncementsScreen(
              initialCategory: state.uri.queryParameters['category'],
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, s) => AnnouncementDetailScreen(id: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
          GoRoute(path: AppRoutes.complaints, builder: (_, __) => const ComplaintsScreen()),
          GoRoute(
            path: AppRoutes.workspace,
            builder: (_, __) => const WorkspaceScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final course = state.extra as CourseModel?;
                  return CourseDetailScreen(courseId: state.pathParameters['id']!, course: course);
                },
                routes: [
                  GoRoute(
                    path: 'submissions/:assignmentId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final title = state.uri.queryParameters['title'] ?? 'Assignment';
                      return SubmissionsScreen(
                        assignmentId: state.pathParameters['assignmentId']!,
                        assignmentTitle: title,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen routes (outside shell) ─────────────
      GoRoute(
        path: '/complaints/new',
        builder: (_, __) => const NewComplaintScreen(),
      ),
      GoRoute(
        path: '/complaints/:id',
        builder: (_, s) =>
            ComplaintDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.assistant,     builder: (_, __) => const AssistantScreen()),
      //GoRoute(path: AppRoutes.directory,     builder: (_, __) => const DirectoryScreen()),
      GoRoute(path: AppRoutes.admin,         builder: (_, __) => const AdminScreen()),
      GoRoute(path: AppRoutes.staff,         builder: (_, __) => const StaffScreen()),
      GoRoute(path: AppRoutes.lecturer,      builder: (_, __) => const LecturerHomeScreen()),
      GoRoute(path: AppRoutes.library,       builder: (_, __) => const LibraryScreen()),
      GoRoute(path: AppRoutes.map,           builder: (_, __) => const MapScreen()),
      //GoRoute(path: AppRoutes.services,      builder: (_, __) => const ServicesScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});

// ─── Bottom nav shell (glass dock + integrated AI) ─────────
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const _studentTabs = [
    AppRoutes.home,
    AppRoutes.schedule,
    AppRoutes.announcements,
    AppRoutes.profile,
  ];

  static const _staffTabs = [
    AppRoutes.home,
    AppRoutes.announcements,
    AppRoutes.complaints,
    AppRoutes.profile,
  ];

  static const _lecturerTabs = [
    AppRoutes.home,
    AppRoutes.announcements,
    AppRoutes.workspace,
    AppRoutes.profile,
  ];

  int _selectedIndex(List<String> tabs) {
    for (var i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i]) && tabs[i] != AppRoutes.home) return i;
      if (location == AppRoutes.home && tabs[i] == AppRoutes.home) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isStaff = user?.role == UserRole.staff;
    final isLecturer = user?.role == UserRole.lecturer;
    final tabs = isLecturer ? _lecturerTabs : (isStaff ? _staffTabs : _studentTabs);
    final idx = _selectedIndex(tabs);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: child,
      bottomNavigationBar: CampusNavBar(
        selectedIndex: idx,
        isStaff: isStaff || isLecturer,
        userRole: user?.role ?? UserRole.student,
        onTabSelected: (i) => context.go(tabs[i]),
      ),
    );
  }
}

// ─── Refresh stream (Updated to fix deprecation) ───────────
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    _subscription1 = ref.listen(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
    _subscription2 = ref.listen(
      currentUserProvider,
      (_, __) => notifyListeners(),
    );
    _subscription3 = ref.listen(
      profileSetupSkippedProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription _subscription1;
  late final ProviderSubscription _subscription2;
  late final ProviderSubscription _subscription3;

  @override
  void dispose() {
    _subscription1.close();
    _subscription2.close();
    _subscription3.close();
    super.dispose();
  }
}

