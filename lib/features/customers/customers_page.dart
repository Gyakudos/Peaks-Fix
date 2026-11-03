import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../../data/warranty.dart';
import '../partners/partners_page.dart';
import '../tickets/ticket_detail_page.dart';
import '../tickets/ticket_widgets.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              key: const Key('customers-partners'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PartnersPage(),
                ),
              ),
              icon: const Icon(Icons.business_center_outlined),
              label: const Text('Partners'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              key: const Key('customer-add'),
              onPressed: () => _editCustomer(context, repository),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add customer'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  key: const Key('customer-search'),
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search customers',
                    hintText: 'Name, phone, or email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<List<CustomerRecord>>(
                    stream: repository.watchCustomers(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const _LoadError(
                          message: 'Could not load customer records.',
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final query = _searchController.text.trim().toLowerCase();
                      final customers = (snapshot.data ?? const [])
                          .where((customer) =>
                              query.isEmpty ||
                              customer.name.toLowerCase().contains(query) ||
                              (customer.phone ?? '')
                                  .toLowerCase()
                                  .contains(query) ||
                              (customer.email ?? '')
                                  .toLowerCase()
                                  .contains(query))
                          .toList();
                      if (customers.isEmpty) {
                        return Center(
                          child: Text(query.isEmpty
                              ? 'No customers yet. Add a customer or create a repair ticket.'
                              : 'No customers match that search.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) => _CustomerCard(
                          customer: customers[index],
                          repository: repository,
                          onEdit: () => _editCustomer(
                              context, repository, customers[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editCustomer(
    BuildContext context,
    TicketsRepository repository, [
    CustomerRecord? customer,
  ]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _CustomerDialog(customer: customer, repository: repository),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(customer == null ? 'Customer added.' : 'Customer saved.'),
        ),
      );
    }
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.repository,
    required this.onEdit,
  });

  final CustomerRecord customer;
  final TicketsRepository repository;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        key: Key('customer-${customer.id}'),
        leading: CircleAvatar(
          child: Text(
            customer.name.trim().isEmpty
                ? '?'
                : customer.name.trim().substring(0, 1).toUpperCase(),
          ),
        ),
        title: Text(customer.name),
        subtitle: Text([
          if (customer.phone?.isNotEmpty == true) customer.phone!,
          if (customer.email?.isNotEmpty == true) customer.email!,
        ].join(' · ')),
        trailing: IconButton(
          key: Key('customer-edit-${customer.id}'),
          tooltip: 'Edit ${customer.name}',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        children: [
          if (customer.notes?.isNotEmpty == true)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(customer.notes!),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Devices',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          StreamBuilder<List<CustomerDeviceEntry>>(
            stream: repository.watchCustomerDevices(customer.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _LoadError(
                  message: 'Could not load customer devices.',
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const LinearProgressIndicator();
              }
              final devices = snapshot.data ?? const [];
              if (devices.isEmpty) {
                return const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('No devices recorded yet.'),
                );
              }
              return Column(
                children: [
                  for (final device in devices)
                    _CustomerDeviceTile(
                      key: Key('customer-device-${device.id}'),
                      device: device,
                    ),
                ],
              );
            },
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Repair history',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          StreamBuilder<List<TicketBoardEntry>>(
            stream: repository.watchCustomerTickets(customer.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _LoadError(
                  message: 'Could not load repair history.',
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const LinearProgressIndicator();
              }
              final tickets = snapshot.data ?? const [];
              if (tickets.isEmpty) {
                return const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('No repair tickets yet.'),
                );
              }
              return Column(
                children: [
                  for (final ticket in tickets)
                    ListTile(
                      key: Key('customer-ticket-${ticket.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: Text(
                          '${ticket.number} · ${ticket.deviceWithVariant}'),
                      subtitle: Text(
                        '${ticket.status.label} · ${shortDate(ticket.createdAt)} · '
                        '${ticket.complaint}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TicketDetailPage(ticketId: ticket.id),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CustomerDeviceTile extends StatelessWidget {
  const _CustomerDeviceTile({super.key, required this.device});

  final CustomerDeviceEntry device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warranty = device.warranty;
    final active = warranty?.isActiveAt(DateTime.now()) ?? false;
    final warrantyColor = warranty == null
        ? theme.colorScheme.onSurfaceVariant
        : active
            ? theme.colorScheme.primary
            : theme.colorScheme.error;
    final warrantyText = warranty == null
        ? 'No warranty on file'
        : active
            ? 'Warranty until ${shortDate(warranty.expiresAt)} · '
                '${WarrantyConfig.daysLabel(warranty.days)}'
            : 'Warranty expired ${shortDate(warranty.expiresAt)}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.devices_other),
      title: Text(device.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text([
            if (device.deviceVariant?.isNotEmpty == true) device.deviceVariant!,
            if (device.deviceSide != null) deviceSideLabel(device.deviceSide),
            device.serial ??
                (device.serialMissing
                    ? 'no serial sticker'
                    : 'serial not recorded'),
          ].join(' · ')),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: warrantyColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  warrantyText,
                  key: Key('customer-device-warranty-${device.id}'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: warrantyColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerDialog extends StatefulWidget {
  const _CustomerDialog({
    required this.customer,
    required this.repository,
  });

  final CustomerRecord? customer;
  final TicketsRepository repository;

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _notes;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.customer?.name ?? '');
    _phone = TextEditingController(text: widget.customer?.phone ?? '');
    _email = TextEditingController(text: widget.customer?.email ?? '');
    _notes = TextEditingController(text: widget.customer?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter the customer name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.saveCustomer(
        customerId: widget.customer?.id,
        name: _name.text,
        phone: _phone.text,
        email: _email.text,
        notes: _notes.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not save customer: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer == null ? 'Add customer' : 'Edit customer'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('customer-name'),
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                key: const Key('customer-phone'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                key: const Key('customer-email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                key: const Key('customer-notes'),
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
              if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('customer-save'),
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Save'),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}
