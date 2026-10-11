import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_api.dart';
import 'features/landing/landing_page.dart';

class ShortLabApp extends StatefulWidget {
  const ShortLabApp({super.key, this.authApi});

  final AuthApi? authApi;

  @override
  State<ShortLabApp> createState() => _ShortLabAppState();
}

class _ShortLabAppState extends State<ShortLabApp> {
  late final AuthApi _authApi;
  late final bool _ownsAuthApi;

  @override
  void initState() {
    super.initState();
    _ownsAuthApi = widget.authApi == null;
    _authApi = widget.authApi ?? AuthApi();
  }

  @override
  void dispose() {
    if (_ownsAuthApi) {
      _authApi.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShortLab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: LandingPage(authApi: _authApi),
    );
  }
}
