import 'package:flutter/material.dart';

import '../../data/photo_templates.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../tickets/ticket_detail_page.dart';

/// Intake: customer, device, identity, fault — and the shop tag, issued on
/// save. Everything lands on one ticket; there is no separate device list.
class NewRepairPage extends StatefulWidget {
  const NewRepairPage({super.key});

  @override
  State<NewRepairPage> createState() => _NewRepairPageState();
}

class _NewRepairPageState extends State<NewRepairPage> {
  final TextEditingController _customer = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _serial = TextEditingController();
  final TextEditingController _deviceOther = TextEditingController();
  final TextEditingController _deviceVariant = TextEditingController();
  final TextEditingController _complaint = TextEditingController();

  late Future<List<DeviceOption>> _catalogFuture;
  bool _catalogRequested = false;

  String? _category;
  int? _modelId;
  String? _modelName;
  bool _otherDevice = false;
  bool _serialMissing = false;

  bool _saving = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_catalogRequested) {
      _catalogRequested = true;
      _catalogFuture = ShopScope.of(context).deviceCatalog();
    }
  }

  @override
  void dispose() {
    _customer.dispose();
    _phone.dispose();
    _email.dispose();
    _serial.dispose();
    _deviceOther.dispose();
    _deviceVariant.dispose();
    _complaint.dispose();
    super.dispose();
  }

  void _setSerialMissing(bool? value) {
    final missing = value ?? false;
    setState(() {
      _serialMissing = missing;
      if (missing) {
        // A stale serial must never survive the device being marked as
        // unlabelled; the shop tag becomes the identifier.
        _serial.clear();
      }
    });
  }

  void _selectCategory(String? category) {
    setState(() {
      _category = category;
      _modelId = null;
      _modelName = null;
      _otherDevice = false;
    });
  }

  void _selectModel(int? value, List<DeviceOption> models) {
    setState(() {
      _modelId = value == -1 ? null : value;
      _otherDevice = value == -1;
      _modelName = _otherDevice
          ? null
          : models.firstWhere((model) => model.modelId == value).modelName;
    });
  }

  /// Which Report 1 checklist this device will get. The ticket stores its own
  /// copy on save; this is only the preview inside the form.
  String? get _photoTemplateKey {
    final category = _category;
    if (category == null) return null;
    final modelName =
        _otherDevice ? _deviceOther.text.trim() : (_modelName ?? '');
    if (modelName.isEmpty) return null;
    return photoTemplateKeyFor(category, modelName);
  }

  String? _validate() {
    if (_customer.text.trim().isEmpty) {
      return 'Enter the customer name.';
    }
    if (_phone.text.trim().isEmpty) {
      return 'Enter the customer phone number.';
    }
    if (_email.text.trim().isEmpty) {
      return 'Enter the customer email address.';
    }
    if (!_looksLikeEmail(_email.text)) {
      return 'That email address does not look right.';
    }
    if (_modelId == null && !_otherDevice) {
      return 'Choose the device, or pick Other / not listed.';
    }
    if (_otherDevice && _deviceOther.text.trim().isEmpty) {
      return 'Describe the device (brand and model).';
    }
    if (!_serialMissing && _serial.text.trim().isEmpty) {
      return 'Enter the serial number, or tick “No serial number sticker”.';
    }
    if (_complaint.text.trim().isEmpty) {
      return 'Describe the reported fault.';
    }
    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final created = await ShopScope.of(context).createTicket(
        customerName: _customer.text,
        customerPhone: _phone.text,
        customerEmail: _email.text,
        deviceModelId: _otherDevice ? null : _modelId,
        deviceName: _otherDevice ? _deviceOther.text : null,
        deviceVariant: _deviceVariant.text,
        photoTemplateKey: _photoTemplateKey,
        serial: _serialMissing ? null : _serial.text,
        serialMissing: _serialMissing,
        complaint: _complaint.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${created.number} created · shop tag ${created.shopTag}',
          ),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => TicketDetailPage(ticketId: created.id),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save the ticket: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New repair')),
      body: FutureBuilder<List<DeviceOption>>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final catalog = snapshot.data ?? const <DeviceOption>[];
          final categories = <String>{
            for (final option in catalog) option.category,
          }.toList();
          final models = [
            for (final option in catalog)
              if (option.category == _category) option,
          ];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                children: [
                  _Section(
                    title: 'Customer',
                    children: [
                      TextField(
                        key: const Key('intake-customer'),
                        controller: _customer,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Existing customers are reused by name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('intake-phone'),
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          hintText: 'Reach the customer about this job',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('intake-email'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Where the client report is sent',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Device',
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final category in categories)
                            DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                        ],
                        onChanged: _selectCategory,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _modelId,
                        decoration: const InputDecoration(
                          labelText: 'Model',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final model in models)
                            DropdownMenuItem(
                              value: model.modelId,
                              child: Text(model.label),
                            ),
                          const DropdownMenuItem(
                            value: -1,
                            child: Text('Other / not listed'),
                          ),
                        ],
                        onChanged: _category == null
                            ? null
                            : (value) => _selectModel(value, models),
                      ),
                      if (_otherDevice) ...[
                        const SizedBox(height: 12),
                        TextField(
                          key: const Key('intake-device-other'),
                          controller: _deviceOther,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Device',
                            hintText: 'e.g. Sega Dreamcast',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      if (_photoTemplateKey != null)
                        _ChecklistPreview(templateKey: _photoTemplateKey!),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('intake-device-variant'),
                        controller: _deviceVariant,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Model number (optional)',
                          hintText: 'e.g. PSP-3000, New 3DS XL, PS5 Slim disc',
                          helperText:
                              'The revision inside the model above. Goes on '
                              'the ticket and the reports.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('intake-serial'),
                        controller: _serial,
                        enabled: !_serialMissing,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Serial number / IMEI',
                          hintText: 'Exactly as printed on the sticker',
                          border: const OutlineInputBorder(),
                          helperText: _serialMissing
                              ? 'Not recorded: the device has no readable sticker.'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CheckboxListTile(
                        value: _serialMissing,
                        onChanged: _setSerialMissing,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('No serial number sticker'),
                        subtitle: const Text(
                          'Missing, worn or illegible. Check this instead of '
                          'typing a serial.',
                        ),
                      ),
                      if (_serialMissing) const _ShopTagNote(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Reported fault',
                    children: [
                      TextField(
                        key: const Key('intake-complaint'),
                        controller: _complaint,
                        minLines: 3,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText:
                              'What the customer says is wrong, in their words.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    _ErrorBox(message: _error!),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      FilledButton.icon(
                        key: const Key('intake-save'),
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          _saving ? 'Creating ticket…' : 'Create ticket',
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Saving issues a shop tag for this device — one sticker on '
                    'the outside, one inside — and opens the ticket.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Shows the Report 1 shot list the chosen device will get, so the checklist is
/// visible before the ticket exists. The real copy is taken at save time.
class _ChecklistPreview extends StatelessWidget {
  const _ChecklistPreview({required this.templateKey});

  final String templateKey;

  @override
  Widget build(BuildContext context) {
    final seed = photoTemplateSeed(templateKey);
    if (seed == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        key: const Key('intake-checklist'),
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        title: Text('Report 1 · ${seed.slots.length} photos'),
        subtitle: Text(seed.name),
        children: [
          for (var index = 0; index < seed.slots.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${index + 1}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Text(seed.slots[index].label)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopTagNote extends StatelessWidget {
  const _ShopTagNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.qr_code_2,
            size: 20,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Shop tag G-000000000 is issued when you save this ticket: one '
              'sticker on the outside of the device, one inside. That tag '
              'becomes its identity.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 20, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Deliberately loose: one @, a dot in the domain, no spaces. Strict RFC
/// validation rejects addresses people actually use, and a wrong address is
/// caught when the report bounces, not by a regex.
bool _looksLikeEmail(String value) {
  final email = value.trim();
  if (email.contains(' ')) return false;
  final parts = email.split('@');
  if (parts.length != 2) return false;
  final local = parts.first;
  final domain = parts.last;
  return local.isNotEmpty &&
      domain.contains('.') &&
      !domain.startsWith('.') &&
      !domain.endsWith('.');
}
