import 'package:flutter/material.dart';

import 'core/auth/auth_session.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/animated_link_backdrop.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/registration_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/landing/landing_page.dart';

class ShortLabApp extends StatefulWidget {
  const ShortLabApp({super.key, this.authApi, this.authSession});

  final AuthApi? authApi;
  final AuthSession? authSession;

  @override
  State<ShortLabApp> createState() => _ShortLabAppState();
}

class _ShortLabAppState extends State<ShortLabApp> {
  late final AuthApi _authApi;
  late final AuthSession _authSession;
  late final bool _ownsAuthApi;
  late final bool _ownsAuthSession;

  @override
  void initState() {
    super.initState();
    _ownsAuthApi = widget.authApi == null;
    _ownsAuthSession = widget.authSession == null && widget.authApi == null;
    _authSession =
        widget.authApi?.session ?? widget.authSession ?? AuthSession();
    _authApi = widget.authApi ?? AuthApi(session: _authSession);
  }

  @override
  void dispose() {
    if (_ownsAuthApi) {
      _authApi.close();
    }
    if (_ownsAuthSession) {
      _authSession.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShortLab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder:
          (context, child) => Stack(
            fit: StackFit.expand,
            children: [
              const IgnorePointer(child: AnimatedLinkBackdrop()),
              if (child != null) child,
            ],
          ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => LandingPage(authApi: _authApi),
            );
          case AppRoutes.login:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => LoginScreen(authApi: _authApi),
            );
          case AppRoutes.registration:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => RegistrationScreen(authApi: _authApi),
            );
          case AppRoutes.dashboard:
            final email = settings.arguments;
            if (email is! String) return null;
            return MaterialPageRoute<void>(
              settings: settings,
              builder:
                  (_) => DashboardScreen(
                    authApi: _authApi,
                    authSession: _authSession,
                    email: email,
                  ),
            );
          default:
            return null;
        }
      },
    );
  }
}
