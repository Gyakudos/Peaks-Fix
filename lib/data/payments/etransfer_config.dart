import '../database.dart';

/// Shop defaults used to build the e-Transfer QR code shown at checkout.
class ETransferConfig {
  const ETransferConfig({
    this.recipient = '',
    this.question = '',
    this.answer = '',
  });

  /// The shop's e-Transfer email address (the payment source/recipient).
  final String recipient;
  final String question;
  final String answer;

  bool get isConfigured => recipient.trim().isNotEmpty;

  /// Link encoded in the QR code for [amountCents].
  String payload(int amountCents) {
    final query = [
      'to=${Uri.encodeQueryComponent(recipient.trim())}',
      'amount=${(amountCents / 100).toStringAsFixed(2)}',
      'currency=CAD',
    ].join('&');
    return 'interac://etransfer?$query';
  }
}

class ETransferConfigStore {
  ETransferConfigStore(this.database);

  final AppDatabase database;

  static const _recipientKey = 'etransfer_recipient';
  static const _questionKey = 'etransfer_question';
  static const _answerKey = 'etransfer_answer';

  Future<ETransferConfig> load() async => ETransferConfig(
        recipient: await database.readSetting(_recipientKey, ''),
        question: await database.readSetting(_questionKey, ''),
        answer: await database.readSetting(_answerKey, ''),
      );

  Future<void> save(ETransferConfig config) async {
    await database.writeSetting(_recipientKey, config.recipient.trim());
    await database.writeSetting(_questionKey, config.question.trim());
    await database.writeSetting(_answerKey, config.answer.trim());
  }
}
