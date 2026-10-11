import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import 'data/auth_api.dart';
import 'login_placeholder.dart';
import 'verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({required this.authApi, super.key});

  final AuthApi authApi;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _serverError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _serverError = null;
    });

    final email = _emailController.text.trim();
    try {
      await widget.authApi.register(
        name: _nameController.text.trim(),
        email: email,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder:
              (_) => VerificationScreen(
                authApi: widget.authApi,
                initialEmail: email,
              ),
        ),
      );
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your name.';
    }
    return null;
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
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Enter a password.';
    }
    if (password.runes.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    // The backend uses Unicode categories; avoid rejecting valid non-ASCII
    // passwords with the ASCII-only class checks below.
    if (password.runes.any((rune) => rune > 0x7f)) {
      return null;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    }
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your account'),
        actions: [
          TextButton(
            onPressed:
                _isSubmitting
                    ? null
                    : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginPlaceholder(),
                        ),
                      );
                    },
            child: const Text('Log in'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFFE8EAF1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Join ShortLab',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create an account to start managing your links.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const ValueKey('registration-name'),
                        controller: _nameController,
                        enabled: !_isSubmitting,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const ValueKey('registration-email'),
                        controller: _emailController,
                        enabled: !_isSubmitting,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const ValueKey('registration-password'),
                        controller: _passwordController,
                        enabled: !_isSubmitting,
                        obscureText: !_passwordVisible,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          helperText:
                              'At least 8 characters with upper/lowercase, '
                              'a number and a symbol.',
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
                                          _passwordVisible = !_passwordVisible,
                                    ),
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const ValueKey('registration-confirm-password'),
                        controller: _confirmPasswordController,
                        enabled: !_isSubmitting,
                        obscureText: !_confirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip:
                                _confirmPasswordVisible
                                    ? 'Hide password'
                                    : 'Show password',
                            onPressed:
                                _isSubmitting
                                    ? null
                                    : () => setState(
                                      () =>
                                          _confirmPasswordVisible =
                                              !_confirmPasswordVisible,
                                    ),
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: _validateConfirmation,
                      ),
                      if (_serverError != null) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _serverError!,
                            key: const ValueKey('registration-server-error'),
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        key: const ValueKey('register-submit'),
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
                                : const Text('Create account'),
                      ),
                    ],
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
