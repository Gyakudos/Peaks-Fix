import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/payments/payment_processor.dart';

/// Runs a card charge or refund through the shop's payment processor.
///
/// Returns true when the payment should be recorded in the app: cash and
/// "other" payments, shops with no processor, or a processor that approved
/// it. If the processor can't take it, the user may still record it as a card
/// payment handled outside the app; returns false if they cancel.
Future<bool> authorizeCardPayment(
  BuildContext context, {
  required PaymentProcessor processor,
  required PaymentMethod method,
  required int amountCents,
  required String reference,
  bool refund = false,
}) async {
  if (method != PaymentMethod.card || processor.kind == ProcessorKind.manual) {
    return true;
  }
  ProcessorResult result;
  final token = ProcessorCancelToken();
  final navigator = Navigator.of(context, rootNavigator: true);
  var waiting = false;
  if (processor.kind != ProcessorKind.manual) {
    waiting = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _WaitingDialog(
        refund: refund,
        amountCents: amountCents,
        onCancel: () => token.cancelled = true,
      ),
    );
  }
  try {
    result = refund
        ? await processor.refund(amountCents: amountCents, reference: reference)
        : await processor.charge(
            amountCents: amountCents,
            reference: reference,
            cancel: token,
          );
  } catch (error) {
    result = ProcessorResult.failure('$error');
  }
  if (waiting && navigator.mounted) navigator.pop();
  if (result.success) return true;
  if (token.cancelled || !context.mounted) return false;
  final record = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${processor.kind.label} could not process the card'),
      content: Text(
        '${result.message ?? 'The payment did not go through.'}\n\n'
        'Record it as a card ${refund ? 'refund' : 'payment'} handled '
        'outside the app?',
      ),
      actions: [
        TextButton(
          key: const Key('card-payment-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('card-payment-record-manually'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Record manually'),
        ),
      ],
    ),
  );
  return record ?? false;
}

class _WaitingDialog extends StatefulWidget {
  const _WaitingDialog({
    required this.refund,
    required this.amountCents,
    required this.onCancel,
  });

  final bool refund;
  final int amountCents;
  final VoidCallback onCancel;

  @override
  State<_WaitingDialog> createState() => _WaitingDialogState();
}

class _WaitingDialogState extends State<_WaitingDialog> {
  bool _cancelling = false;

  @override
  Widget build(BuildContext context) {
    final amount = '\$${(widget.amountCents / 100).toStringAsFixed(2)}';
    return AlertDialog(
      title: Text(widget.refund ? 'Refunding $amount' : 'Charge $amount'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              _cancelling
                  ? 'Cancelling…'
                  : widget.refund
                      ? 'Contacting the payment processor…'
                      : 'Waiting for the customer to pay on the terminal…',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('card-payment-stop-waiting'),
          onPressed: _cancelling
              ? null
              : () {
                  setState(() => _cancelling = true);
                  widget.onCancel();
                },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
