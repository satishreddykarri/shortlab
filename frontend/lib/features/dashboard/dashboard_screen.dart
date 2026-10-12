import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/auth/auth_session.dart';
import '../../core/config/api_config.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/async_state_view.dart';
import '../auth/data/auth_api.dart';
import 'url_analytics_dialog.dart';
import '../urls/data/short_url.dart';
import '../urls/data/url_api.dart';

const _urlAlgorithms = <String, String>{
  'base62': 'Base62',
  'hash': 'Hash',
  'random': 'Random',
  'uuid': 'UUID',
  'custom': 'Custom alias',
};

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.authApi,
    required this.authSession,
    required this.email,
    super.key,
  });

  final AuthApi authApi;
  final AuthSession authSession;
  final String email;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final UrlApi _urlApi;
  final _formKey = GlobalKey<FormState>();
  final _originalUrlController = TextEditingController();
  final _customAliasController = TextEditingController();

  List<ShortUrl>? _urls;
  bool _isLoading = true;
  bool _isCreating = false;
  final Set<int> _deletingUrlIds = {};
  String? _listError;
  String? _createError;
  ShortUrl? _createdUrl;
  String _algorithm = 'base62';
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _urlApi = widget.authApi.urls;
    _loadUrls();
  }

  @override
  void dispose() {
    _originalUrlController.dispose();
    _customAliasController.dispose();
    super.dispose();
  }

  Future<void> _loadUrls() async {
    setState(() {
      _isLoading = true;
      _listError = null;
    });
    try {
      final urls = await _urlApi.list();
      if (mounted) {
        setState(() {
          _urls = urls;
          _isLoading = false;
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _listError = error.message;
          _isLoading = false;
        });
      }
    }
  }

  String? _validateOriginalUrl(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Enter the URL you want to shorten.';
    }
    if (input.contains(RegExp(r'[\r\n]'))) {
      return 'Enter a valid absolute HTTP or HTTPS URL.';
    }
    final uri = Uri.tryParse(input);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        !const {'http', 'https'}.contains(uri.scheme.toLowerCase())) {
      return 'Enter a valid absolute HTTP or HTTPS URL.';
    }
    return null;
  }

  String? _validateAlgorithm(String? value) {
    if (value == null || !_urlAlgorithms.containsKey(value)) {
      return 'Select a shortening method.';
    }
    return null;
  }

  String? _validateCustomAlias(String? value) {
    if (_algorithm != 'custom') return null;
    final alias = value ?? '';
    final aliasLength = utf8.encode(alias).length;
    if (alias.isEmpty) {
      return 'Enter a custom alias.';
    }
    if (aliasLength < 3) {
      return 'Custom alias must be at least 3 characters.';
    }
    if (aliasLength > 30) {
      return 'Custom alias must not exceed 30 characters.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(alias)) {
      return 'Use only letters, numbers, hyphens, and underscores.';
    }
    return null;
  }

  Future<void> _pickExpiration() async {
    final now = DateTime.now();
    final initialDate = _expiresAt ?? now.add(const Duration(days: 1));
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 20),
    );
    if (!mounted || selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expiresAt ?? now),
    );
    if (!mounted || selectedTime == null) return;

    setState(() {
      _expiresAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      _createError = null;
    });
  }

  Future<void> _createUrl() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_expiresAt != null && !_expiresAt!.isAfter(DateTime.now())) {
      setState(() => _createError = 'Expiration must be in the future.');
      return;
    }

    setState(() {
      _isCreating = true;
      _createError = null;
      _createdUrl = null;
    });

    try {
      final created = await _urlApi.create(
        originalUrl: _originalUrlController.text.trim(),
        algorithm: _algorithm,
        customAlias:
            _algorithm == 'custom' ? _customAliasController.text : null,
        expiresAt: _expiresAt,
      );
      if (!mounted) return;
      setState(() {
        _createdUrl = created;
        _originalUrlController.clear();
        _customAliasController.clear();
        _expiresAt = null;
        _algorithm = 'base62';
      });
      _formKey.currentState!.reset();
      await _loadUrls();
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _createError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  String _shortUrl(ShortUrl url) {
    final baseUri = Uri.parse(ApiConfig.baseUrl);
    return baseUri
        .replace(
          path: '/${Uri.encodeComponent(url.shortCode)}',
          query: null,
          fragment: null,
        )
        .toString();
  }

  Future<void> _copyShortUrl(ShortUrl url) async {
    try {
      await Clipboard.setData(ClipboardData(text: _shortUrl(url)));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Short URL copied to clipboard.')),
      );
    } on ApiException catch (error) {
      _showCopyError(error.message);
    } on FormatException {
      _showCopyError('The configured API base URL is invalid.');
    } on PlatformException {
      _showCopyError('Could not copy the short URL.');
    }
  }

  Future<void> _confirmDelete(ShortUrl url) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete short link?'),
            content: Text(
              'This will permanently delete ${url.shortCode} and its click analytics.',
            ),
            actions: [
              TextButton(
                key: const ValueKey('cancel-delete-url'),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const ValueKey('confirm-delete-url'),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted || _deletingUrlIds.contains(url.id)) {
      return;
    }

    setState(() => _deletingUrlIds.add(url.id));
    try {
      await _urlApi.delete(url.id);
      if (!mounted) return;
      setState(() {
        _urls = _urls?.where((item) => item.id != url.id).toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Short link deleted.')));
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _deletingUrlIds.remove(url.id));
      }
    }
  }

  Future<void> _openAnalytics(ShortUrl url) {
    return showDialog<void>(
      context: context,
      builder:
          (_) => UrlAnalyticsDialog(
            urlApi: _urlApi,
            url: url,
            shortUrl: _shortUrl(url),
          ),
    );
  }

  void _showCopyError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _logout() {
    widget.authSession.logout();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_rounded, color: Color(0xFF4658E8)),
            const SizedBox(width: 8),
            Text(
              'ShortLab',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF18233B),
              ),
            ),
          ],
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width >= 520)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(widget.email),
              ),
            ),
          TextButton(
            key: const ValueKey('dashboard-logout'),
            onPressed: _logout,
            child: const Text('Log out'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 20 : 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create and manage your shortened links.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 28),
                        _buildCreateForm(context),
                        const SizedBox(height: 36),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Your links',
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                            IconButton(
                              key: const ValueKey('refresh-urls'),
                              tooltip: 'Refresh links',
                              onPressed: _isLoading ? null : _loadUrls,
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildUrlList(context),
                      ],
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

  Widget _buildCreateForm(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8EAF1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create a short link', style: theme.textTheme.titleLarge),
              const SizedBox(height: 18),
              TextFormField(
                key: const ValueKey('original-url'),
                controller: _originalUrlController,
                enabled: !_isCreating,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Destination URL',
                  hintText: 'https://example.com/page',
                  border: OutlineInputBorder(),
                ),
                validator: _validateOriginalUrl,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const ValueKey('algorithm-selector'),
                value: _algorithm,
                decoration: const InputDecoration(
                  labelText: 'Shortening method',
                  border: OutlineInputBorder(),
                ),
                items:
                    _urlAlgorithms.entries
                        .map(
                          (algorithm) => DropdownMenuItem(
                            value: algorithm.key,
                            child: Text(algorithm.value),
                          ),
                        )
                        .toList(),
                validator: _validateAlgorithm,
                onChanged:
                    _isCreating
                        ? null
                        : (value) {
                          if (value != null) {
                            setState(() {
                              _algorithm = value;
                              _createError = null;
                            });
                          }
                        },
              ),
              if (_algorithm == 'custom') ...[
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('custom-alias'),
                  controller: _customAliasController,
                  enabled: !_isCreating,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Custom alias',
                    hintText: 'my-link',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: _validateCustomAlias,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('expiration-picker'),
                    onPressed: _isCreating ? null : _pickExpiration,
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(
                      _expiresAt == null
                          ? 'Set expiration (optional)'
                          : 'Expires ${_formatDateTime(_expiresAt!)}',
                    ),
                  ),
                  if (_expiresAt != null)
                    TextButton(
                      onPressed:
                          _isCreating
                              ? null
                              : () => setState(() => _expiresAt = null),
                      child: const Text('Clear'),
                    ),
                ],
              ),
              if (_createError != null) ...[
                const SizedBox(height: 14),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _createError!,
                    key: const ValueKey('create-url-error'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
              if (_createdUrl != null) ...[
                const SizedBox(height: 16),
                _CreatedResult(
                  url: _createdUrl!,
                  shortUrl: _shortUrl(_createdUrl!),
                ),
              ],
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const ValueKey('create-url-submit'),
                  onPressed: _isCreating ? null : _createUrl,
                  icon:
                      _isCreating
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.add_link_rounded),
                  label: Text(_isCreating ? 'Creating...' : 'Shorten URL'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrlList(BuildContext context) {
    if (_isLoading && _urls == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading links'),
        ),
      );
    }
    if (_listError != null && _urls == null) {
      return AsyncStateView(
        isLoading: false,
        errorMessage: _listError,
        onRetry: _loadUrls,
        child: const SizedBox.shrink(),
      );
    }
    final urls = _urls ?? const <ShortUrl>[];
    if (urls.isEmpty) {
      return Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE8EAF1)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.link_off_rounded,
                  size: 36,
                  color: Color(0xFF8A93A5),
                ),
                SizedBox(height: 12),
                Text('No shortened links yet. Create your first one above.'),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        if (_listError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AsyncStateView(
              isLoading: false,
              errorMessage: _listError,
              onRetry: _loadUrls,
              child: const SizedBox.shrink(),
            ),
          ),
        for (final url in urls)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _UrlCard(
              url: url,
              shortUrl: _shortUrl(url),
              onCopy: () => _copyShortUrl(url),
              onAnalytics: () => _openAnalytics(url),
              onDelete: () => _confirmDelete(url),
              isDeleting: _deletingUrlIds.contains(url.id),
            ),
          ),
      ],
    );
  }
}

class _CreatedResult extends StatelessWidget {
  const _CreatedResult({required this.url, required this.shortUrl});

  final ShortUrl url;
  final String shortUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('created-url-result'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Short link created',
            style: TextStyle(
              color: Color(0xFF126D58),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            shortUrl,
            key: const ValueKey('created-short-url'),
            style: const TextStyle(
              color: Color(0xFF4658E8),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text('Code: ${url.shortCode}'),
        ],
      ),
    );
  }
}

class _UrlCard extends StatelessWidget {
  const _UrlCard({
    required this.url,
    required this.shortUrl,
    required this.onCopy,
    required this.onAnalytics,
    required this.onDelete,
    required this.isDeleting,
  });

  final ShortUrl url;
  final String shortUrl;
  final VoidCallback onCopy;
  final VoidCallback onAnalytics;
  final VoidCallback onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE8EAF1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              shortUrl,
              key: ValueKey('short-url-${url.id}'),
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFF4658E8),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(url.originalUrl, style: textTheme.bodyMedium),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Metadata(
                  label: 'Method',
                  value: _urlAlgorithms[url.algorithm] ?? url.algorithm,
                ),
                _Metadata(
                  label: 'Created',
                  value: _formatDateTime(url.createdAt),
                ),
                if (url.expiresAt != null)
                  _Metadata(
                    label: 'Expires',
                    value: _formatDateTime(url.expiresAt!),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton.icon(
                    key: ValueKey('analytics-url-${url.id}'),
                    onPressed: onAnalytics,
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('Analytics'),
                  ),
                  TextButton.icon(
                    key: ValueKey('copy-short-url-${url.id}'),
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy'),
                  ),
                  IconButton(
                    key: ValueKey('delete-url-${url.id}'),
                    tooltip: 'Delete short link',
                    onPressed: isDeleting ? null : onDelete,
                    icon:
                        isDeleting
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value', style: Theme.of(context).textTheme.bodySmall);
  }
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}
