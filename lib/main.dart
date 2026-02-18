import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp` before using every service.
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  configureDependencies();

  // Initialize Push Notifications
  try {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // Get the token
      String? token = await messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');

        // Update token if user is already logged in or when they log in
        final authRepository = getIt<AuthRepository>();

        // Check current user
        if (FirebaseAuth.instance.currentUser != null) {
          authRepository.updateFcmToken(token);
        }

        // Listen for auth changes to update token on login
        FirebaseAuth.instance.authStateChanges().listen((user) {
          if (user != null) {
            authRepository.updateFcmToken(token);
          }
        });

        // Listen for token refresh
        messaging.onTokenRefresh.listen((newToken) {
          if (FirebaseAuth.instance.currentUser != null) {
            authRepository.updateFcmToken(newToken);
          }
        });
      }
    } else {
      print('User declined or has not accepted permission');
    }
  } catch (e) {
    print('Error initializing Firebase Messaging: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil with a common design size (e.g., iPhone 13 Pro dimensions)
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final appRouter = getIt<AppRouter>();
        return BlocProvider(
          create: (context) => getIt<AuthBloc>(),
          child: MaterialApp.router(
            title: 'Planno',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: appRouter.config(),
          ),
        );
      },
    );
  }
}
