import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/feedback_api.dart';
import '../utils/feedback_store.dart';

/// C146: post-event feedback form, shared by the once-per-booking popup and
/// the persistent `Rate experience` card action.
///
/// Glossary: copy uses Booking / Customer / Status terms only.
class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({super.key, required this.bookingId});

  /// Null booking id = general feedback (no Booking linked).
  final int? bookingId;

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  static const int maxTextLength = 500;

  int _stars = 0;
  final TextEditingController _textController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars < 1 || _stars > 5 || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final text = _textController.text.trim();
      await ref.read(feedbackApiProvider).submitFeedback(
            stars: _stars,
            text: text.isEmpty ? null : text,
            bookingId: widget.bookingId,
          );
      if (widget.bookingId != null) {
        await FeedbackStore.markSubmitted(widget.bookingId!);
        await FeedbackStore.markSeen(widget.bookingId!);
      }
      ref.read(feedbackRefreshProvider.notifier).state++;
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      // Graceful offline: stay open with a retryable message; nothing is
      // persisted, so the `Rate experience` action remains available.
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Could not send feedback. '
              'Check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('feedback_dialog'),
      title: const Text('How was your experience?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tell us about your recent Booking.'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    key: Key('feedback_star_$i'),
                    tooltip: 'Rate $i star${i == 1 ? '' : 's'}',
                    icon: Icon(
                      i <= _stars ? Icons.star : Icons.star_border_outlined,
                    ),
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _stars = i),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('feedback_text_field'),
              controller: _textController,
              enabled: !_submitting,
              maxLines: 4,
              maxLength: maxTextLength,
              decoration: const InputDecoration(
                labelText: 'Share details (optional)',
                hintText: 'What did you love about the Scent bar?',
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('feedback_not_now'),
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Not now'),
        ),
        ElevatedButton(
          key: const Key('feedback_submit'),
          onPressed: (_stars < 1 || _submitting) ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

/// Shows the feedback form for [bookingId]. Returns true when feedback was
/// submitted. Dismissal (`Not now`, back, tap-outside) returns false/ null
/// and persists the id as seen so this popup instance never nags again.
Future<bool> showFeedbackDialog(BuildContext context, int? bookingId) async {
  final submitted = await showDialog<bool>(
    context: context,
    builder: (ctx) => FeedbackDialog(bookingId: bookingId),
  );
  return submitted ?? false;
}
