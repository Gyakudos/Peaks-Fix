import '../data/database.dart';

/// Where customers send Interac e-Transfers. With auto-deposit on, no
/// password is needed; [password] is only for accounts without it.
class ETransferConfig {
  const ETransferConfig({this.email = '', this.password = ''});

  final String email;
  final String password;

  bool get isConfigured => email.trim().isNotEmpty;
}

const _emailKey = 'etransfer_email';
const _passwordKey = 'etransfer_password';

Future<ETransferConfig> loadETransferConfig(AppDatabase database) async =>
    ETransferConfig(
      email: await database.readSetting(_emailKey, ''),
      password: await database.readSetting(_passwordKey, ''),
    );

Future<void> saveETransferConfig(
  AppDatabase database,
  ETransferConfig config,
) async {
  await database.writeSetting(_emailKey, config.email.trim());
  await database.writeSetting(_passwordKey, config.password.trim());
}

/// The text a customer sees after scanning. Interac has no public QR format
/// that banking apps can pay from, so this is a readable set of instructions.
String eTransferPayload(
  ETransferConfig config, {
  required int amountCents,
  String? reference,
}) {
  final ref = reference?.trim() ?? '';
  return [
    'Interac e-Transfer',
    'To: ${config.email.trim()}',
    'Amount: \$${(amountCents / 100).toStringAsFixed(2)} CAD',
    if (ref.isNotEmpty) 'Message: $ref',
    if (config.password.trim().isNotEmpty)
      'Security answer: ${config.password.trim()}',
  ].join('\n');
}
