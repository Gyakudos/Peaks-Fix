import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/database.dart';
import '../../data/etransfer.dart';

/// A QR code carrying the e-Transfer recipient, amount and message, with the
/// same details written out underneath.
class ETransferQrPanel extends StatefulWidget {
  const ETransferQrPanel({
    super.key,
    required this.amountCents,
    this.reference,
  });

  final int amountCents;
  final String? reference;

  @override
  State<ETransferQrPanel> createState() => _ETransferQrPanelState();
}

class _ETransferQrPanelState extends State<ETransferQrPanel> {
  late final Future<ETransferConfig> _config =
      loadETransferConfig(AppDatabase.instance);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<ETransferConfig>(
      future: _config,
      builder: (context, snapshot) {
        final config = snapshot.data;
        if (config == null) return const SizedBox(height: 8);
        if (!config.isConfigured) {
          return Text(
            'Add the e-Transfer email in Settings to show a QR code.',
            key: const Key('etransfer-not-configured'),
            style: TextStyle(color: theme.colorScheme.error),
          );
        }
        if (widget.amountCents <= 0) {
          return const Text('Enter an amount to generate the QR code.');
        }
        final payload = eTransferPayload(
          config,
          amountCents: widget.amountCents,
          reference: widget.reference,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: QrImageView(
                key: const Key('etransfer-qr'),
                data: payload,
                size: 180,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              payload,
              key: const Key('etransfer-details'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
