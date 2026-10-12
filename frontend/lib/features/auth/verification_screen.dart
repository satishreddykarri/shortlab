import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import 'auth_experience_layout.dart';
import 'data/auth_api.dart';
import 'login_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    required this.authApi,
    required this.initialEmail,
    super.key,
  });

  final AuthApi authApi;
  final String initialEmail;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();

  bool _isSubmitting = false;
  bool _isVerified = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
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

  String? _validateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the verification code.';
    }
    if (value.trim().runes.length != 6) {
      return 'The verification code must be 6 characters.';
    }
    return null;
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

    try {
      await widget.authApi.verifyEmail(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
      );
      if (mounted) {
        setState(() => _isVerified = true);
      }
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

  void _openLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(authApi: widget.authApi),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Verify your email'),
      ),
      body: AuthExperienceLayout(
        child: Align(
          alignment: Alignment.centerRight,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFE4E7ED)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child:
                      _isVerified
                          ? _SuccessContent(onLogin: _openLogin)
                          : Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Check your inbox',
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter the 6-character verification code sent '
                                  'to your email address.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  key: const ValueKey('verification-email'),
                                  controller: _emailController,
                                  enabled: !_isSubmitting,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: const ValueKey('verification-code'),
                                  controller: _codeController,
                                  enabled: !_isSubmitting,
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  maxLength: 6,
                                  decoration: const InputDecoration(
                                    labelText: 'Verification code',
                                    border: OutlineInputBorder(),
                                    counterText: '',
                                  ),
                                  validator: _validateCode,
                                ),
                                if (_serverError != null) ...[
                                  const SizedBox(height: 16),
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      _serverError!,
                                      key: const ValueKey('verification-error'),
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                FilledButton(
                                  key: const ValueKey('verify-submit'),
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
                                          : const Text('Verify email'),
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

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          color: Color(0xFF168C73),
          size: 52,
        ),
        const SizedBox(height: 16),
        Text(
          'Email verified',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your email address has been verified. You can now log in.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const ValueKey('go-to-login'),
            onPressed: onLogin,
            child: const Text('Continue to login'),
          ),
        ),
      ],
    );
  }
}
