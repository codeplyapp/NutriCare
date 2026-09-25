import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:nutricare/presentation/screens/auth/auth_screen.dart';
import 'package:nutricare/presentation/screens/auth/email_verification_screen.dart';
import 'package:nutricare/presentation/screens/auth/reverify_screen.dart';
import 'package:nutricare/presentation/screens/onboarding_profile/onboarding_profile_screen.dart';
import 'package:nutricare/presentation/screens/home_dashboard/home_dashboard_screen.dart';
import 'package:nutricare/presentation/screens/nutri_mate/nutri_mate_screen.dart';
import 'package:nutricare/presentation/screens/dokter_gizi/doctor_list_screen.dart';
import 'package:nutricare/presentation/screens/dokter_gizi/booking_screen.dart';
import 'package:nutricare/presentation/screens/dokter_gizi/consultation_room_screen.dart';
import 'package:nutricare/presentation/screens/meal_planner/meal_planner_screen.dart';
import 'package:nutricare/presentation/screens/bmi_calculator/bmi_calculator_screen.dart';
import 'package:nutricare/presentation/screens/health_education/education_screen.dart';
import 'package:nutricare/presentation/screens/health_education/article_detail_screen.dart';
import 'package:nutricare/presentation/screens/health_education/module_detail_screen.dart';
import 'package:nutricare/presentation/screens/health_education/flashcard_viewer_screen.dart';
import 'package:nutricare/presentation/screens/health_education/quiz_screen.dart';
import 'package:nutricare/presentation/screens/health_education/exam_screen.dart';
import 'package:nutricare/presentation/screens/health_education/certificate_screen.dart';
import 'package:nutricare/presentation/screens/profile/profile_screen.dart';
import 'package:nutricare/presentation/screens/profile/my_profile_detail_screen.dart';
import 'package:nutricare/presentation/screens/notifications/notifications_screen.dart';
import 'package:nutricare/presentation/widgets/app_dock.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isVerified = authState.isEmailVerified;
      final hasProfile = authState.hasProfile;
      final loc = state.uri.path;

      // Onboarding intro selalu boleh diakses
      if (loc == '/onboarding') return null;

      final isAuthRoute = loc == '/auth' || loc == '/login' || loc == '/register' || loc == '/reverify' || loc == '/email-verification';

      // 1. Belum login sama sekali
      if (!isAuth) {
        return isAuthRoute ? null : '/auth';
      }

      // 2. Sudah login tetapi email belum terverifikasi (khusus email/password)
      if (!isVerified) {
        if (loc == '/email-verification' || loc == '/reverify') {
          return null;
        }
        return '/email-verification';
      }

      // 3. Sudah terverifikasi tetapi belum mengisi profil gizi (FR-1.1 Route Guard)
      if (!hasProfile) {
        return loc == '/onboarding-profile' ? null : '/onboarding-profile';
      }

      // 4. Sudah terverifikasi dan sudah memiliki profil gizi -> jangan biarkan kembali ke layar auth
      if (isAuth && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Onboarding Intro (pertama kali buka app)
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = tabStr == '1' || tabStr == 'register' ? 1 : 0;
          return AuthScreen(initialTabIndex: initialTab);
        },
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(initialTabIndex: 0),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(initialTabIndex: 1),
      ),
      GoRoute(
        path: '/email-verification',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reverify',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return ReverifyScreen(initialEmail: email);
        },
      ),
      GoRoute(
        path: '/onboarding-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingProfileScreen(),
      ),

      // StatefulShellRoute untuk 4 tab utama pasca-onboarding (Beranda, Nutri Meal, Nutri Doc, Profil)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 84),
                    child: navigationShell,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AppDock(
                    currentIndex: navigationShell.currentIndex,
                    onTap: (index) => navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    ),
                  ),
                ),
                // Floating AI Assistant Button (Nutri Mate)
                const Positioned(
                  right: 18,
                  bottom: 94,
                  child: FloatingNutriMateButton(),
                ),
              ],
            ),
          );
        },
        branches: [
          // Tab 1: Beranda / Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          // Tab 2: Nutri Meal & IoT
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/meal-planner',
                builder: (context, state) => const MealPlannerScreen(),
              ),
            ],
          ),
          // Tab 3: Nutri Doc (Dokter Gizi)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dokter-gizi',
                builder: (context, state) => const DoctorListScreen(),
              ),
            ],
          ),
          // Tab 4: Profil Pengguna
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Fitur Nutri Mate AI di-push ke root navigator (menutupi dock)
      GoRoute(
        path: '/nutri-mate',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NutriMateScreen(),
      ),

      // Fitur My Profile Detail & Notifications
      GoRoute(
        path: '/profile/detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyProfileDetailScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Halaman detail / sub-fitur di-push ke root navigator (menutupi dock)
      GoRoute(
        path: '/dokter-gizi/booking',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final doc = state.extra as DoctorEntity?;
          return BookingScreen(doctor: doc);
        },
      ),
      GoRoute(
        path: '/dokter-gizi/room',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final consultation = state.extra as ConsultationEntity?;
          return ConsultationRoomScreen(consultation: consultation);
        },
      ),
      GoRoute(
        path: '/bmi-calculator',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BMICalculatorScreen(),
      ),
      GoRoute(
        path: '/education',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EducationScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final art = state.extra as ArticleEntity?;
              return ArticleDetailScreen(article: art);
            },
          ),
          GoRoute(
            path: 'module',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final mod = state.extra as StudyModuleEntity;
              return ModuleDetailScreen(module: mod);
            },
          ),
          GoRoute(
            path: 'flashcards',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return FlashcardViewerScreen(
                moduleId: extra['id'] ?? 'mod-1',
                moduleTitle: extra['title'] ?? 'Flashcards Gizi',
              );
            },
          ),
          GoRoute(
            path: 'quiz',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return QuizScreen(
                moduleId: extra['id'] ?? 'mod-1',
                moduleTitle: extra['title'] ?? 'Kuis Gizi',
              );
            },
          ),
          GoRoute(
            path: 'exam',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const ExamScreen(),
          ),
          GoRoute(
            path: 'certificate',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const CertificateScreen(),
          ),
        ],
      ),
    ],
  );
});
