import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/partners.dart';
import '../payments/card_payment.dart';
import '../../data/photo_templates.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../calendar/date_picker_field.dart';
import '../capture/phone_capture_dialog.dart';
import '../tickets/ticket_detail_page.dart';

/// Intake reuses customer and device records while keeping a snapshot on the
/// repair ticket.
class NewRepairPage extends StatefulWidget {
  const NewRepairPage({super.key, this.quoteTicketId, this.customerName});

  /// A quote being converted; its invoice moves onto the new ticket.
  final int? quoteTicketId;

  /// Customer name carried over from the quote.
  final String? customerName;

  @override
  State<NewRepairPage> createState() => _NewRepairPageState();
}

class _NewRepairPageState extends State<NewRepairPage> {
  late final TextEditingController _customer =
      TextEditingController(text: widget.customerName ?? '');
  final FocusNode _customerFocus = FocusNode();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _serial = TextEditingController();
  final TextEditingController _deviceOther = TextEditingController();
  final TextEditingController _deviceVariant = TextEditingController();
  final TextEditingController _complaint = TextEditingController();
  final TextEditingController _deposit = TextEditingController(text: '45.00');
  PaymentMethod _depositMethod = PaymentMethod.card;
  static const int _minimumDepositCents = 4500;
  late Future<(List<DeviceOption>, List<String>)> _catalogFuture;
  bool _catalogRequested = false;

  String? _category;
  String? _brand;
  int? _modelId;
  String? _modelName;
  String? _side;
  bool _otherDevice = false;
  bool _serialMissing = false;
  bool _serialPending = false;
  int _serialRequest = 0;
  DateTime? _dropOffAt = _today();
  DateTime? _technicianStartAt;
  DateTime? _partsArriveAt;
  DateTime? _customerContactedAt;
  DateTime? _pickedUpAt;

  bool _saving = false;
  String? _error;
  int? _customerId;
  List<Partner> _partners = const [];
  Partner? _partner;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    final partners = await loadPartners(AppDatabase.instance);
    if (!mounted || partners.isEmpty) return;
    final quoted = (widget.customerName ?? '').trim().toLowerCase();
    setState(() {
      _partners = partners;
      for (final partner in partners) {
        if (quoted.isNotEmpty && partner.name.toLowerCase() == quoted) {
          _partner = partner;
        }
      }
    });
  }

  String? _selectedCustomerName;
  int? _customerDeviceId;
  List<CustomerDeviceEntry> _customerDevices = const [];

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_catalogRequested) {
      _catalogRequested = true;
      _catalogFuture = _loadIntakeCatalog();
    }
  }

  Future<(List<DeviceOption>, List<String>)> _loadIntakeCatalog() async {
    final repository = ShopScope.of(context);
    final catalog = await repository.deviceCatalog();
    final categories = await repository.deviceCategories();
    return (catalog, categories);
  }

  @override
  void dispose() {
    _customer.dispose();
    _customerFocus.dispose();
    _phone.dispose();
    _email.dispose();
    _serial.dispose();
    _deviceOther.dispose();
    _deviceVariant.dispose();
    _complaint.dispose();
    _deposit.dispose();
    super.dispose();
  }

  /// Ticking the box replaces the factory serial with a shop-applied one:
  /// `PFS-` plus nine random digits, generated before the ticket exists so the
  /// operator can write it on the device and see it on the form.
  Future<void> _setSerialMissing(bool? value) async {
    final missing = value ?? false;
    final token = ++_serialRequest;

    if (!missing) {
      setState(() {
        _serialMissing = false;
        _serialPending = false;
        _serial.clear();
      });
      return;
    }

    // A stale factory serial must never survive the device being marked as
    // unlabelled.
    setState(() {
      _serialMissing = true;
      _serialPending = true;
      _serial.clear();
      _error = null;
    });

    try {
      final applied = await ShopScope.of(context).nextShopSerial();
      if (!mounted || token != _serialRequest || !_serialMissing) return;
      setState(() {
        _serial.text = applied;
        _serialPending = false;
      });
    } catch (error) {
      if (!mounted || token != _serialRequest) return;
      setState(() {
        _serialMissing = false;
        _serialPending = false;
        _error = 'Could not generate a shop serial: $error';
      });
    }
  }

  void _selectCategory(String? category) {
    setState(() {
      _customerDeviceId = null;
      _category = category;
      _brand = null;
      _modelId = null;
      _modelName = null;
      _side = null;
      _otherDevice = false;
    });
  }

  void _selectBrand(String? brand) {
    setState(() {
      _customerDeviceId = null;
      _brand = brand;
      _modelId = null;
      _modelName = null;
      _side = null;
      _otherDevice = false;
    });
  }

  void _selectModel(int? value, List<DeviceOption> models) {
    setState(() {
      _customerDeviceId = null;
      _modelId = value == -1 ? null : value;
      _otherDevice = value == -1;
      _modelName = _otherDevice
          ? null
          : models.firstWhere((model) => model.modelId == value).modelName;
      // A side belongs to the model it was chosen for.
      _side = null;
    });
  }

  /// A single Joy-Con is booked on its own, so intake asks which half it is.
  bool get _needsSide => deviceSideRequired(_modelName);

  Future<void> _findExistingCustomer() async {
    final repository = ShopScope.of(context);
    final contacts = [_phone.text.trim(), _email.text.trim()]
        .where((value) => value.isNotEmpty)
        .toSet();
    if (contacts.isEmpty) {
      setState(() => _error = 'Enter a phone number or email to search.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final matches = <int, CustomerRecord>{};
      for (final contact in contacts) {
        for (final customer
            in await repository.findCustomersByContact(contact)) {
          matches[customer.id] = customer;
        }
      }
      if (!mounted) return;
      if (matches.isEmpty) {
        setState(() => _error = 'No customer matches that phone or email.');
        return;
      }
      final selected = await showDialog<CustomerRecord>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Select customer'),
          content: SizedBox(
            width: 480,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final customer in matches.values)
                  ListTile(
                    key: Key('intake-customer-result-${customer.id}'),
                    title: Text(customer.name),
                    subtitle: Text([
                      if (customer.phone?.isNotEmpty == true) customer.phone!,
                      if (customer.email?.isNotEmpty == true) customer.email!,
                    ].join(' · ')),
                    onTap: () => Navigator.of(dialogContext).pop(customer),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      if (selected == null || !mounted) return;
      await _selectCustomer(selected);
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not search customer records: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selectCustomer(CustomerRecord customer) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final devices =
          await ShopScope.of(context).watchCustomerDevices(customer.id).first;
      if (!mounted) return;
      setState(() {
        _customerId = customer.id;
        _selectedCustomerName = customer.name;
        _customerDeviceId = null;
        _customer.text = customer.name;
        _phone.text = customer.phone ?? '';
        _email.text = customer.email ?? '';
        _customerDevices = devices;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not load customer records: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onCustomerNameChanged(String value) {
    if (_customerId == null ||
        value.trim().toLowerCase() ==
            (_selectedCustomerName ?? '').toLowerCase()) {
      return;
    }
    setState(() {
      _customerId = null;
      _selectedCustomerName = null;
      _customerDeviceId = null;
      _customerDevices = const [];
    });
  }

  void _selectCustomerDevice(
    int? deviceId,
    List<DeviceOption> catalog,
  ) {
    final device = _customerDevices
        .where((candidate) => candidate.id == deviceId)
        .firstOrNull;
    if (deviceId == null || device == null) {
      setState(() => _customerDeviceId = null);
      return;
    }
    final catalogModel = catalog
        .where((candidate) => candidate.modelId == device.modelId)
        .firstOrNull;
    setState(() {
      _customerDeviceId = device.id;
      _category = device.category ?? catalogModel?.category;
      _brand = catalogModel?.brand;
      _modelId = device.modelId;
      _modelName = device.modelName ?? catalogModel?.modelName;
      _otherDevice = device.modelId == null;
      _deviceOther.text = device.modelId == null ? device.label : '';
      _deviceVariant.text = device.deviceVariant ?? '';
      _side = device.deviceSide;
      _serial.text = device.serial ?? '';
      _serialMissing = device.serialMissing;
      _serialPending = false;
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
    if (_needsSide && _side == null) {
      return 'Choose which side this Joy-Con is: left or right.';
    }
    if (!_serialMissing && _serial.text.trim().isEmpty) {
      return 'Enter the serial number, or tick “No serial number sticker”.';
    }
    if (_serialMissing && _serial.text.trim().isEmpty) {
      return 'Wait for the shop serial to finish generating.';
    }
    if (_complaint.text.trim().isEmpty) {
      return 'Describe the reported fault.';
    }
    final deposit = _depositCents();
    if (deposit == null || deposit < _minimumDepositCents) {
      return 'A deposit of at least \$45.00 is required to drop off a device.';
    }
    return null;
  }

  int? _depositCents() {
    final amount = double.tryParse(
      _deposit.text.trim().replaceAll(',', '').replaceAll('\$', ''),
    );
    if (amount == null || !amount.isFinite) return null;
    return (amount * 100).round();
  }

  Future<void> _save({bool importPhotos = false}) async {
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
      final repository = ShopScope.of(context);
      final processor = await repository.paymentProcessor();
      if (!mounted) return;
      final depositReference =
          'Deposit${DateTime.now().millisecondsSinceEpoch}';
      final approved = await authorizeCardPayment(
        context,
        processor: processor,
        method: _depositMethod,
        amountCents: _depositCents()!,
        reference: depositReference,
      );
      if (!approved) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      if (!mounted) return;
      final created = await repository.createTicket(
        customerId: _customerId,
        customerName: _customer.text,
        customerPhone: _phone.text,
        customerEmail: _email.text,
        deviceModelId: _otherDevice ? null : _modelId,
        deviceName: _otherDevice ? _deviceOther.text : null,
        deviceVariant: _deviceVariant.text,
        deviceSide: _side,
        customerDeviceId: _customerDeviceId,
        photoTemplateKey: _photoTemplateKey,
        serial: _serial.text,
        serialMissing: _serialMissing,
        dates: TicketDates(
          dropOffAt: _dropOffAt,
          technicianStartAt: _technicianStartAt,
          partsArriveAt: _partsArriveAt,
          customerContactedAt: _customerContactedAt,
          pickedUpAt: _pickedUpAt,
        ),
        partnerName: _partner?.name ?? '',
        complaint: _complaint.text,
      );
      if (widget.quoteTicketId case final quoteId?) {
        await repository.adoptQuote(quoteId: quoteId, ticketId: created.id);
      }
      if (_partner case final partner? when partner.hasDiscount) {
        await repository.setInvoiceDiscount(
          ticketId: created.id,
          kind: InvoiceDiscountKind.none,
          value: 0,
          partnerPartsPercent: partner.partsDiscountPercent,
          partnerLabourPercent: partner.labourDiscountPercent,
        );
      }
      await repository.recordTicketDeposit(
        ticketId: created.id,
        amountCents: _depositCents()!,
        method: _depositMethod,
      );
      await processor.attachReference(depositReference, created.number);
      if (!mounted) return;
      if (importPhotos) {
        final checklist =
            await repository.watchPhotoChecklist(created.id).first;
        if (!mounted) return;
        await showPhoneCaptureDialog(
          context,
          repository: repository,
          ticketId: created.id,
          ticketNumber: created.number,
          device: _otherDevice
              ? _deviceOther.text.trim()
              : (_modelName ?? _category ?? 'Device'),
          checklist: checklist,
        );
        if (!mounted) return;
      }
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
      body: FutureBuilder<(List<DeviceOption>, List<String>)>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final catalog = snapshot.data?.$1 ?? const <DeviceOption>[];
          final categories = snapshot.data?.$2 ?? const <String>[];
          const brandCategories = [
            'Ebikes',
            'Consoles',
            'Retro consoles',
            'Portable Consoles',
            'Vacuum',
            'Handheld PCs',
          ];
          final showBrand = brandCategories.contains(_category);
          final brands = {
            for (final option in catalog)
              if (option.category == _category && option.brand.isNotEmpty)
                option.brand,
          }.toList()
            ..sort((a, b) {
              if (a == 'Unknown') return b == 'Unknown' ? 0 : 1;
              if (b == 'Unknown') return -1;
              return a.toLowerCase().compareTo(b.toLowerCase());
            });
          final models = [
            for (final option in catalog)
              if (option.category == _category &&
                  (!showBrand || option.brand == _brand))
                option,
          ];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: ListView(
                key: const Key('intake-form-scroll'),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                children: [
                  _Section(
                    title: 'Customer',
                    children: [
                      if (_partners.isNotEmpty) ...[
                        DropdownButtonFormField<Partner?>(
                          key: const Key('intake-partner'),
                          initialValue: _partner,
                          decoration: const InputDecoration(
                            labelText: 'Partner (drop-off location)',
                            helperText:
                                'Applies the partner discount to the invoice.',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<Partner?>(
                              value: null,
                              child: Text('Walk-in (no partner)'),
                            ),
                            for (final partner in _partners)
                              DropdownMenuItem<Partner?>(
                                value: partner,
                                child: Text(
                                  partner.hasDiscount
                                      ? '${partner.name} '
                                          '(${partner.discountLabel})'
                                      : partner.name,
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _partner = value),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Autocomplete<CustomerRecord>(
                        textEditingController: _customer,
                        focusNode: _customerFocus,
                        displayStringForOption: (customer) => customer.name,
                        optionsBuilder: (value) {
                          final query = value.text.trim();
                          if (query.length < 2) {
                            return const <CustomerRecord>[];
                          }
                          return ShopScope.of(context)
                              .searchCustomersByName(query);
                        },
                        onSelected: _selectCustomer,
                        optionsViewBuilder: (context, onSelected, options) =>
                            Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 240,
                                maxWidth: 600,
                              ),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                children: [
                                  for (final customer in options)
                                    ListTile(
                                      key: Key(
                                        'intake-customer-suggestion-${customer.id}',
                                      ),
                                      title: Text(customer.name),
                                      subtitle: Text([
                                        if (customer.phone?.isNotEmpty == true)
                                          customer.phone!,
                                        if (customer.email?.isNotEmpty == true)
                                          customer.email!,
                                      ].join(' · ')),
                                      onTap: () => onSelected(customer),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        fieldViewBuilder:
                            (context, controller, focusNode, onSubmitted) =>
                                TextField(
                          key: const Key('intake-customer'),
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          onChanged: _onCustomerNameChanged,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Customer name',
                            helperText:
                                'Start typing to find an existing customer.',
                            border: OutlineInputBorder(),
                          ),
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
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            key: const Key('intake-find-customer'),
                            onPressed: _saving ? null : _findExistingCustomer,
                            icon: const Icon(Icons.person_search_outlined),
                            label: const Text('Find by phone/email'),
                          ),
                          if (_customerId != null)
                            Chip(
                              avatar: const Icon(Icons.link, size: 16),
                              label: const Text('Existing customer selected'),
                              onDeleted: _saving
                                  ? null
                                  : () => setState(() {
                                        _customerId = null;
                                        _customerDevices = const [];
                                        _customerDeviceId = null;
                                      }),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Device',
                    children: [
                      if (_customerId != null &&
                          _customerDevices.isNotEmpty) ...[
                        DropdownButtonFormField<int>(
                          key: const Key('intake-saved-device'),
                          initialValue: _customerDeviceId,
                          decoration: const InputDecoration(
                            labelText: 'Existing customer device',
                            helperText:
                                'Choose a device already recorded for this customer.',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final device in _customerDevices)
                              DropdownMenuItem(
                                value: device.id,
                                child: Text(
                                  '${device.label} · '
                                  '${device.serial ?? 'no serial recorded'}',
                                ),
                              ),
                          ],
                          onChanged: _saving
                              ? null
                              : (value) =>
                                  _selectCustomerDevice(value, catalog),
                        ),
                        const SizedBox(height: 12),
                      ],
                      DropdownButtonFormField<String>(
                        key: const Key('intake-category'),
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
                      if (showBrand) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: const Key('intake-brand'),
                          initialValue: _brand,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final brand in brands)
                              DropdownMenuItem(
                                value: brand,
                                child: Text(brand),
                              ),
                          ],
                          onChanged: _selectBrand,
                        ),
                      ],
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        key: const Key('intake-model'),
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
                        onChanged:
                            _category == null || (showBrand && _brand == null)
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
                      if (_needsSide) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: const Key('intake-side'),
                          initialValue: _side,
                          decoration: const InputDecoration(
                            labelText: 'Side',
                            helperText:
                                'A Joy-Con is booked one half at a time. '
                                'Which half is this?',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'left',
                              child: Text('Left (L)'),
                            ),
                            DropdownMenuItem(
                              value: 'right',
                              child: Text('Right (R)'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _side = value),
                        ),
                      ],
                      if (_photoTemplateKey != null)
                        _ChecklistPreview(
                          templateKey: _photoTemplateKey!,
                          deviceName:
                              _otherDevice ? _deviceOther.text.trim() : null,
                          onImportPhotos:
                              _saving ? null : () => _save(importPhotos: true),
                        ),
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
                        style: _serialMissing
                            ? TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              )
                            : null,
                        decoration: InputDecoration(
                          labelText: _serialMissing
                              ? 'Shop-applied serial'
                              : 'Serial number / IMEI',
                          hintText: _serialMissing
                              ? 'Generated automatically'
                              : 'Exactly as printed on the sticker',
                          border: const OutlineInputBorder(),
                          helperText: _serialPending
                              ? 'Generating a shop serial…'
                              : _serialMissing
                                  ? 'Replaces the missing sticker and goes on '
                                      'the ticket and reports.'
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CheckboxListTile(
                        key: const Key('intake-serial-missing'),
                        value: _serialMissing,
                        onChanged: _saving
                            ? null
                            : (value) => _setSerialMissing(value),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text('No serial number sticker'),
                        subtitle: const Text(
                          'Missing, worn or illegible. The shop issues a '
                          'PFS- serial for this device instead.',
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
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Deposit',
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('intake-deposit'),
                              controller: _deposit,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Deposit',
                                prefixText: '\$',
                                helperText:
                                    'Minimum \$45.00 to drop off a device. '
                                    'Applied to the final invoice.',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<PaymentMethod>(
                              key: const Key('intake-deposit-method'),
                              initialValue: _depositMethod,
                              decoration: const InputDecoration(
                                labelText: 'Paid by',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: PaymentMethod.cash,
                                  child: Text('Cash'),
                                ),
                                DropdownMenuItem(
                                  value: PaymentMethod.card,
                                  child: Text('Card'),
                                ),
                                DropdownMenuItem(
                                  value: PaymentMethod.other,
                                  child: Text('Other'),
                                ),
                                DropdownMenuItem(
                                  value: PaymentMethod.eTransfer,
                                  child: Text('E-transfer'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _depositMethod = value ?? _depositMethod,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Repair dates',
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final fieldWidth = constraints.maxWidth >= 600
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final field in <({
                                String label,
                                DateTime? value,
                                ValueChanged<DateTime?> onChanged,
                                bool required,
                              })>[
                                (
                                  label: 'Drop Off',
                                  value: _dropOffAt,
                                  onChanged: (value) =>
                                      setState(() => _dropOffAt = value),
                                  required: true,
                                ),
                                (
                                  label: 'Technician Start Date',
                                  value: _technicianStartAt,
                                  onChanged: (value) => setState(
                                        () => _technicianStartAt = value,
                                      ),
                                  required: false,
                                ),
                                (
                                  label: 'Parts Arrive',
                                  value: _partsArriveAt,
                                  onChanged: (value) =>
                                      setState(() => _partsArriveAt = value),
                                  required: false,
                                ),
                                (
                                  label: 'Customer Contacted',
                                  value: _customerContactedAt,
                                  onChanged: (value) => setState(
                                        () => _customerContactedAt = value,
                                      ),
                                  required: false,
                                ),
                                (
                                  label: 'Date of Pick Up',
                                  value: _pickedUpAt,
                                  onChanged: (value) =>
                                      setState(() => _pickedUpAt = value),
                                  required: false,
                                ),
                              ])
                                SizedBox(
                                  width: fieldWidth,
                                  child: DatePickerField(
                                    label: field.label,
                                    value: field.value,
                                    onChanged: field.onChanged,
                                    required: field.required,
                                  ),
                                ),
                            ],
                          );
                        },
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
                        onPressed: _saving || _serialPending ? null : _save,
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
  const _ChecklistPreview({
    required this.templateKey,
    this.deviceName,
    this.onImportPhotos,
  });

  final String templateKey;
  final String? deviceName;
  final VoidCallback? onImportPhotos;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpansionTile(
            key: const Key('intake-checklist'),
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            title: Text('Report 1 · ${seed.slots.length} photos'),
            subtitle: Text(
              templateKey == 'general_electronics' &&
                      (deviceName ?? '').isNotEmpty
                  ? deviceName!
                  : seed.name,
            ),
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
          if (onImportPhotos != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton.tonalIcon(
                      key: const Key('intake-import-photos-qr'),
                      onPressed: onImportPhotos,
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Create & import with QR'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saves the ticket first, then opens the phone photo link.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              'Shop serial PFS-000000000 replaces the missing sticker. Saving '
              'also issues shop tag G-000000000 — one sticker outside the '
              'device, one inside.',
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
