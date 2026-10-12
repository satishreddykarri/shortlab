import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/network/api_client.dart';
import 'auth_experience_layout.dart';
import 'data/auth_api.dart';

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
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => route.isFirst);
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

  void _validateOnBlur() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create your account'),
        actions: [
          TextButton(
            onPressed:
                _isSubmitting
                    ? null
                    : () {
                      Navigator.of(context).pushNamed(AppRoutes.login);
                    },
            child: const Text('Log in'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AuthExperienceLayout(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 700 && width < 1100;
            final isDesktop = width >= 1100;
            final formWidth =
                isDesktop
                    ? 440.0
                    : (isTablet ? 520.0 : width.clamp(280.0, 480.0));

            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: isDesktop ? 24 : 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child:
                      isDesktop
                          ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 28),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _desktopBrandChip(),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Long links in.\nSmart links out.',
                                        style: theme.textTheme.displaySmall
                                            ?.copyWith(
                                              fontSize: width > 1200 ? 60 : 52,
                                              height: 0.95,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1E2433),
                                            ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Create, manage, and understand every link you share.',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: const Color(0xFF4D5668),
                                              height: 1.5,
                                              fontSize: 18,
                                            ),
                                      ),
                                      const SizedBox(height: 26),
                                      const Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          _InfoPill(label: 'Fast redirects'),
                                          _InfoPill(label: 'Insights driven'),
                                          _InfoPill(label: 'No spam'),
                                        ],
                                      ),
                                      const SizedBox(height: 34),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(22),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF1D2D7A),
                                              Color(0xFF4337D7),
                                            ],
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x2B2A3D8F),
                                              blurRadius: 24,
                                              offset: Offset(0, 18),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _heroTag('Your destination'),
                                            const SizedBox(height: 18),
                                            _heroCard(
                                              'example.com/long/article',
                                              true,
                                            ),
                                            const SizedBox(height: 26),
                                            Row(
                                              children: [
                                                _heroTag('Your rules'),
                                                const Spacer(),
                                                const Text(
                                                  'FAST',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 18),
                                            _heroCard(
                                              'shortlab.io/aB29x',
                                              false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: formWidth,
                                child: Card(
                                  elevation: 18,
                                  color: Colors.white,
                                  shadowColor: const Color(0x1E2A4A7F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Form(
                                      key: _formKey,
                                      autovalidateMode:
                                          AutovalidateMode.disabled,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'Join ShortLab',
                                            style:
                                                theme.textTheme.headlineMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Create an account to start managing your links.',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildField(
                                            key: const ValueKey(
                                              'registration-name',
                                            ),
                                            controller: _nameController,
                                            label: 'Name',
                                            hintText: 'Enter your name',
                                            enabled: !_isSubmitting,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            autofillHints: const [
                                              AutofillHints.name,
                                            ],
                                            validator: _validateName,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildField(
                                            key: const ValueKey(
                                              'registration-email',
                                            ),
                                            controller: _emailController,
                                            label: 'Email',
                                            hintText: 'Enter your email',
                                            enabled: !_isSubmitting,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            autofillHints: const [
                                              AutofillHints.email,
                                            ],
                                            validator: _validateEmail,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildPasswordField(
                                            key: const ValueKey(
                                              'registration-password',
                                            ),
                                            controller: _passwordController,
                                            label: 'Password',
                                            hintText:
                                                'Create a secure password',
                                            enabled: !_isSubmitting,
                                            helperText:
                                                'At least 8 characters with upper/lowercase, a number and a symbol.',
                                            visible: _passwordVisible,
                                            onToggle:
                                                () => setState(
                                                  () =>
                                                      _passwordVisible =
                                                          !_passwordVisible,
                                                ),
                                            validator: _validatePassword,
                                          ),
                                          const SizedBox(height: 16),
                                          _buildPasswordField(
                                            key: const ValueKey(
                                              'registration-confirm-password',
                                            ),
                                            controller:
                                                _confirmPasswordController,
                                            label: 'Confirm password',
                                            hintText: 'Repeat your password',
                                            enabled: !_isSubmitting,
                                            visible: _confirmPasswordVisible,
                                            onToggle:
                                                () => setState(
                                                  () =>
                                                      _confirmPasswordVisible =
                                                          !_confirmPasswordVisible,
                                                ),
                                            validator: _validateConfirmation,
                                          ),
                                          if (_serverError != null) ...[
                                            const SizedBox(height: 16),
                                            Semantics(
                                              liveRegion: true,
                                              child: Text(
                                                _serverError!,
                                                key: const ValueKey(
                                                  'registration-server-error',
                                                ),
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.error,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 24),
                                          FilledButton(
                                            key: const ValueKey(
                                              'register-submit',
                                            ),
                                            onPressed:
                                                _isSubmitting ? null : _submit,
                                            style: FilledButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 18,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                            child:
                                                _isSubmitting
                                                    ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                    : const Text(
                                                      'Create account',
                                                    ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Card(
                            elevation: 12,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: AutovalidateMode.disabled,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                    _buildField(
                                      key: const ValueKey('registration-name'),
                                      controller: _nameController,
                                      label: 'Name',
                                      hintText: 'Enter your name',
                                      enabled: !_isSubmitting,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      autofillHints: const [AutofillHints.name],
                                      validator: _validateName,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildField(
                                      key: const ValueKey('registration-email'),
                                      controller: _emailController,
                                      label: 'Email',
                                      hintText: 'Enter your email',
                                      enabled: !_isSubmitting,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPasswordField(
                                      key: const ValueKey(
                                        'registration-password',
                                      ),
                                      controller: _passwordController,
                                      label: 'Password',
                                      hintText: 'Create a secure password',
                                      enabled: !_isSubmitting,
                                      helperText:
                                          'At least 8 characters with upper/lowercase, a number and a symbol.',
                                      visible: _passwordVisible,
                                      onToggle:
                                          () => setState(
                                            () =>
                                                _passwordVisible =
                                                    !_passwordVisible,
                                          ),
                                      validator: _validatePassword,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPasswordField(
                                      key: const ValueKey(
                                        'registration-confirm-password',
                                      ),
                                      controller: _confirmPasswordController,
                                      label: 'Confirm password',
                                      hintText: 'Repeat your password',
                                      enabled: !_isSubmitting,
                                      visible: _confirmPasswordVisible,
                                      onToggle:
                                          () => setState(
                                            () =>
                                                _confirmPasswordVisible =
                                                    !_confirmPasswordVisible,
                                          ),
                                      validator: _validateConfirmation,
                                    ),
                                    if (_serverError != null) ...[
                                      const SizedBox(height: 16),
                                      Semantics(
                                        liveRegion: true,
                                        child: Text(
                                          _serverError!,
                                          key: const ValueKey(
                                            'registration-server-error',
                                          ),
                                          style: TextStyle(
                                            color: theme.colorScheme.error,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    FilledButton(
                                      key: const ValueKey('register-submit'),
                                      onPressed: _isSubmitting ? null : _submit,
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child:
                                          _isSubmitting
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
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
            );
          },
        ),
      ),
    );
  }

  Widget _desktopBrandChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.link_rounded, color: Color(0xFF5B5CE6), size: 22),
          SizedBox(width: 8),
          Text(
            'ShortLab',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1E1F32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _heroCard(String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            isPrimary ? Icons.link_rounded : Icons.short_text_rounded,
            color: isPrimary ? const Color(0xFF5B5CE6) : Colors.white70,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isPrimary ? 23 : 18,
                fontWeight: FontWeight.w600,
                color: isPrimary ? const Color(0xFF1E2433) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool enabled,
    required String? Function(String?) validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType? keyboardType,
    List<String>? autofillHints,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      onTapOutside: (_) => _validateOnBlur(),
      onFieldSubmitted: (_) => _validateOnBlur(),
      onChanged: (_) {
        if (_serverError != null) {
          setState(() => _serverError = null);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        floatingLabelStyle: const TextStyle(color: Color(0xFF4B5ED6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E5F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E5F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5B5CE6), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool enabled,
    required String? Function(String?) validator,
    required bool visible,
    required VoidCallback onToggle,
    String? helperText,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      enabled: enabled,
      obscureText: !visible,
      autofillHints: const [AutofillHints.newPassword],
      onTapOutside: (_) => _validateOnBlur(),
      onFieldSubmitted: (_) => _validateOnBlur(),
      onChanged: (_) {
        if (_serverError != null) {
          setState(() => _serverError = null);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        floatingLabelStyle: const TextStyle(color: Color(0xFF4B5ED6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E5F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E5F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5B5CE6), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        suffixIcon: IconButton(
          tooltip: visible ? 'Hide password' : 'Show password',
          onPressed: enabled ? onToggle : null,
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
        ),
      ),
      validator: validator,
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E7FF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2C3550),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
