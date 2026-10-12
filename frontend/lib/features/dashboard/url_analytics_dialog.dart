import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../urls/data/short_url.dart';
import '../urls/data/url_analytics.dart';
import '../urls/data/url_api.dart';

class UrlAnalyticsDialog extends StatefulWidget {
  const UrlAnalyticsDialog({
    required this.urlApi,
    required this.url,
    required this.shortUrl,
    super.key,
  });

  final UrlApi urlApi;
  final ShortUrl url;
  final String shortUrl;

  @override
  State<UrlAnalyticsDialog> createState() => _UrlAnalyticsDialogState();
}

class _UrlAnalyticsDialogState extends State<UrlAnalyticsDialog> {
  UrlAnalytics? _analytics;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final analytics = await widget.urlApi.analytics(widget.url.id);
      if (mounted) {
        setState(() {
          _analytics = analytics;
          _isLoading = false;
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return AlertDialog(
      key: const ValueKey('url-analytics-dialog'),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFDDE4DE)),
      ),
      title: Row(
        children: [
          const Expanded(child: Text('Link analytics')),
          IconButton(
            key: const ValueKey('refresh-analytics'),
            tooltip: 'Refresh analytics',
            onPressed: _isLoading ? null : _loadAnalytics,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: width < 600 ? width * 0.88 : 560,
        height: (MediaQuery.sizeOf(context).height * 0.65).clamp(280.0, 560.0),
        child: _buildBody(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _analytics == null) {
      return const Center(
        child: CircularProgressIndicator(
          key: ValueKey('analytics-loading'),
          semanticsLabel: 'Loading analytics',
        ),
      );
    }
    if (_error != null && _analytics == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _error!,
            key: const ValueKey('analytics-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            key: const ValueKey('retry-analytics'),
            onPressed: _loadAnalytics,
            child: const Text('Try again'),
          ),
        ],
      );
    }
    final analytics = _analytics!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _error!,
              key: const ValueKey('analytics-refresh-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                widget.shortUrl,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2D7064),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(analytics.originalUrl),
              const SizedBox(height: 16),
              _AnalyticsMetadata(analytics: analytics),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Click details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text('${analytics.totalClicks} total'),
                ],
              ),
              const SizedBox(height: 8),
              if (analytics.clicks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No clicks recorded yet.')),
                )
              else
                for (final click in analytics.clicks) _ClickCard(click: click),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsMetadata extends StatelessWidget {
  const _AnalyticsMetadata({required this.analytics});

  final UrlAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _AnalyticsField(label: 'URL ID', value: '${analytics.urlId}'),
        _AnalyticsField(label: 'Short code', value: analytics.shortCode),
        _AnalyticsField(label: 'Algorithm', value: analytics.algorithm),
        _AnalyticsField(
          label: 'Created',
          value: _formatAnalyticsDate(analytics.createdAt),
        ),
        _AnalyticsField(
          label: 'Expires',
          value:
              analytics.expiresAt == null
                  ? 'Never'
                  : _formatAnalyticsDate(analytics.expiresAt!),
        ),
      ],
    );
  }
}

class _ClickCard extends StatelessWidget {
  const _ClickCard({required this.click});

  final UrlClick click;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('click-${click.id}'),
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      color: const Color(0xFFF3F5F1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnalyticsField(
              label: 'Clicked',
              value: _formatAnalyticsDate(click.clickedAt),
            ),
            _AnalyticsField(label: 'IP address', value: click.ipAddress),
            _AnalyticsField(label: 'User agent', value: click.userAgent),
            _AnalyticsField(label: 'Referrer', value: click.referrer),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsField extends StatelessWidget {
  const _AnalyticsField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF586760),
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

String _formatAnalyticsDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}
