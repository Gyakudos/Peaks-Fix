import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/partners.dart';
import '../tickets/quote_page.dart';

class PartnersPage extends StatefulWidget {
  const PartnersPage({super.key, this.database});

  final AppDatabase? database;

  @override
  State<PartnersPage> createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage> {
  late final AppDatabase _database = widget.database ?? AppDatabase.instance;
  List<Partner>? _partners;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final partners = await loadPartners(_database);
    if (mounted) setState(() => _partners = partners);
  }

  Future<void> _edit([Partner? existing]) async {
    final result = await showDialog<Partner>(
      context: context,
      builder: (_) => _PartnerDialog(existing: existing),
    );
    if (result == null) return;
    final all = [...?_partners];
    final index = all.indexWhere((partner) => partner.id == result.id);
    if (index >= 0) {
      all[index] = result;
    } else {
      all.add(result);
    }
    await savePartners(_database, all);
    await _reload();
  }

  Future<void> _delete(Partner partner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${partner.name}?'),
        content: const Text('Existing quotes and invoices are not changed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            key: const Key('partner-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await savePartners(_database, [
      for (final other in _partners ?? const <Partner>[])
        if (other.id != partner.id) other,
    ]);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final partners = _partners;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partners'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              key: const Key('partner-add'),
              onPressed: _edit,
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Add partner'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: partners == null
              ? const Center(child: CircularProgressIndicator())
              : partners.isEmpty
                  ? const Center(
                      child: Text(
                        'No partners yet. Add a drop-off location to build '
                        'quotes for it.',
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        for (final partner in partners)
                          Card(
                            child: ListTile(
                              key: Key('partner-${partner.id}'),
                              title: Text(partner.name),
                              subtitle: Text(
                                [
                                  if (partner.contact.isNotEmpty)
                                    partner.contact,
                                  if (partner.phone.isNotEmpty) partner.phone,
                                  if (partner.address.isNotEmpty)
                                    partner.address,
                                ].join(' · '),
                              ),
                              leading: partner.discountPercent > 0
                                  ? Chip(
                                      label: Text(
                                        '${partner.discountPercent}% off',
                                      ),
                                    )
                                  : null,
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  TextButton.icon(
                                    key: Key('partner-quote-${partner.id}'),
                                    onPressed: () => startQuote(
                                      context,
                                      partner: partner,
                                    ),
                                    icon: const Icon(Icons.request_quote),
                                    label: const Text('Build quote'),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () => _edit(partner),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove',
                                    onPressed: () => _delete(partner),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _PartnerDialog extends StatefulWidget {
  const _PartnerDialog({this.existing});

  final Partner? existing;

  @override
  State<_PartnerDialog> createState() => _PartnerDialogState();
}

class _PartnerDialogState extends State<_PartnerDialog> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _contact = TextEditingController(text: widget.existing?.contact);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _email = TextEditingController(text: widget.existing?.email);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _discount = TextEditingController(
    text: '${widget.existing?.discountPercent ?? 0}',
  );
  String? _error;

  @override
  void dispose() {
    for (final controller in [_name, _contact, _phone, _email, _address]) {
      controller.dispose();
    }
    _discount.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final discount = int.tryParse(_discount.text.trim());
    if (name.isEmpty) {
      setState(() => _error = 'Enter the partner name.');
      return;
    }
    if (discount == null || discount < 0 || discount > 100) {
      setState(() => _error = 'Discount must be a whole number, 0 to 100.');
      return;
    }
    Navigator.of(context).pop(
      Partner(
        id: widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        contact: _contact.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        discountPercent: discount,
      ),
    );
  }

  Widget _field(Key key, TextEditingController controller, String label) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          key: key,
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add partner' : 'Edit partner'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(const Key('partner-name'), _name, 'Name'),
              _field(const Key('partner-contact'), _contact, 'Contact person'),
              _field(const Key('partner-phone'), _phone, 'Phone'),
              _field(const Key('partner-email'), _email, 'Email'),
              _field(const Key('partner-address'), _address, 'Address'),
              _field(const Key('partner-discount'), _discount, 'Discount (%)'),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('partner-save'),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
