import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/network/api_client.dart';
import 'auth_experience_layout.dart';
import 'data/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.authApi, super.key});

  final AuthApi authApi;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _passwordVisible = false;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Enter your email address.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password.';
    }
    return null;
  }

  void _validateOnBlur() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.validate();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _serverError = null;
    });

    final email = _emailController.text.trim();
    try {
      await widget.authApi.login(
        email: email,
        password: _passwordController.text,
      );
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.dashboard, arguments: email);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _serverError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _openRegistration() {
    Navigator.of(context).pushNamed(AppRoutes.registration);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: AuthExperienceLayout(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 12,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(color: Color(0xFFF0F2F8)),
                ),
                shadowColor: const Color(0x1424345E),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log in to continue to ShortLab.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          key: const ValueKey('login-email'),
                          controller: _emailController,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          onTapOutside: (_) => _validateOnBlur(),
                          onFieldSubmitted: (_) => _validateOnBlur(),
                          onChanged: (_) {
                            if (_serverError != null) {
                              setState(() => _serverError = null);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('login-password'),
                          controller: _passwordController,
                          enabled: !_isSubmitting,
                          obscureText: !_passwordVisible,
                          autofillHints: const [AutofillHints.password],
                          onTapOutside: (_) => _validateOnBlur(),
                          onChanged: (_) {
                            if (_serverError != null) {
                              setState(() => _serverError = null);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              tooltip:
                                  _passwordVisible
                                      ? 'Hide password'
                                      : 'Show password',
                              onPressed:
                                  _isSubmitting
                                      ? null
                                      : () => setState(
                                        () =>
                                            _passwordVisible =
                                                !_passwordVisible,
                                      ),
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: _validatePassword,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        if (_serverError != null) ...[
                          const SizedBox(height: 16),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _serverError!,
                              key: const ValueKey('login-server-error'),
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          key: const ValueKey('login-submit'),
                          onPressed: _isSubmitting ? null : _submit,
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Log in'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isSubmitting ? null : _openRegistration,
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
