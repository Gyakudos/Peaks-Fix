import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../data/device_catalog.dart';
import '../../data/warranty.dart';
import 'section_heading.dart';

/// The Settings section that manages categories, brand headings and devices.
///
/// Deleting here never rewrites old tickets: they keep the device name they
/// recorded, while the picker stops offering the removed row.
class DeviceCatalogSection extends StatefulWidget {
  const DeviceCatalogSection({super.key, this.database});

  /// Supplied by tests; the app uses the shared database.
  final AppDatabase? database;

  @override
  State<DeviceCatalogSection> createState() => _DeviceCatalogSectionState();
}

class _DeviceCatalogSectionState extends State<DeviceCatalogSection> {
  late final AppDatabase _database = widget.database ?? AppDatabase.instance;
  late final DeviceCatalog _catalog = DeviceCatalog(_database);

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on CatalogNameError catch (error) {
      _showMessage(error.message);
    } catch (error, stack) {
      debugPrint('Device catalog change failed: $error\n$stack');
      _showMessage('That change could not be saved.');
    }
  }

  Future<void> _addCategory() async {
    final name = await _askName(
      context,
      title: 'Add device category',
      label: 'Category name',
      confirm: 'Add category',
    );
    if (name == null || !mounted) return;
    await _run(() => _catalog.addCategory(name));
  }

  Future<void> _renameCategory(CatalogCategory category) async {
    final name = await _askName(
      context,
      title: 'Rename category',
      label: 'Category name',
      confirm: 'Save',
      initial: category.name,
    );
    if (name == null || !mounted) return;
    await _run(() => _catalog.renameCategory(category.id, name));
  }

  Future<void> _editCategoryWarranty(CatalogCategory category) async {
    final updated = await _askWarrantyDays(
      context,
      initial: category.warrantyDays,
    );
    if (updated == null || !mounted) return;
    await _run(() => _catalog.setCategoryWarrantyDays(category.id, updated));
  }

  Future<void> _deleteCategory(CatalogCategory category) async {
    final confirmed = await _confirm(
      context,
      title: 'Remove ${category.name}?',
      body: _removalBody(
        headings: category.brands.length,
        devices: category.deviceCount,
      ),
      action: 'Remove category',
    );
    if (!confirmed || !mounted) return;
    await _run(() => _catalog.deleteCategory(category.id));
  }

  void _openCategory(CatalogCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DeviceCategoryPage(
          categoryId: category.id,
          categoryName: category.name,
          database: _database,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          title: 'Device catalog',
          action: FilledButton.icon(
            key: const Key('catalog-add-category'),
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
            label: const Text('Add category'),
          ),
        ),
        StreamBuilder<List<CatalogCategory>>(
          stream: _catalog.watch(),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? const <CatalogCategory>[];
            if (categories.isEmpty) {
              return const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('No device categories yet.'),
              );
            }
            return Column(
              children: [
                for (final category in categories) _categoryTile(category),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _categoryTile(CatalogCategory category) {
    return ListTile(
      key: Key('catalog-category-${category.id}'),
      contentPadding: EdgeInsets.zero,
      title: Text(category.name),
      subtitle: Text(_categorySummary(category)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message:
                category.isActive ? 'Shown in intake' : 'Hidden from intake',
            child: Switch(
              key: Key('catalog-category-active-${category.id}'),
              value: category.isActive,
              onChanged: (isActive) => _run(
                () => _catalog.setCategoryActive(category.id, isActive),
              ),
            ),
          ),
          PopupMenuButton<_CategoryAction>(
            key: Key('catalog-category-menu-${category.id}'),
            tooltip: 'Category actions',
            onSelected: (action) => switch (action) {
              _CategoryAction.rename => _renameCategory(category),
              _CategoryAction.warranty => _editCategoryWarranty(category),
              _CategoryAction.delete => _deleteCategory(category),
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _CategoryAction.rename,
                child: Text('Rename category'),
              ),
              PopupMenuItem(
                value: _CategoryAction.warranty,
                child: Text('Warranty period'),
              ),
              PopupMenuItem(
                value: _CategoryAction.delete,
                child: Text('Remove category'),
              ),
            ],
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _openCategory(category),
    );
  }
}

/// One category's brand headings and the devices under each heading.
class DeviceCategoryPage extends StatefulWidget {
  const DeviceCategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.database,
  });

  final int categoryId;
  final String categoryName;

  /// Supplied by tests; the app uses the shared database.
  final AppDatabase? database;

  @override
  State<DeviceCategoryPage> createState() => _DeviceCategoryPageState();
}

class _DeviceCategoryPageState extends State<DeviceCategoryPage> {
  late final AppDatabase _database = widget.database ?? AppDatabase.instance;
  late final DeviceCatalog _catalog = DeviceCatalog(_database);

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action,
      {bool close = false}) async {
    try {
      await action();
      if (close && mounted) Navigator.of(context).pop();
    } on CatalogNameError catch (error) {
      _showMessage(error.message);
    } catch (error, stack) {
      debugPrint('Device catalog change failed: $error\n$stack');
      _showMessage('That change could not be saved.');
    }
  }

  Future<void> _addBrand() async {
    final name = await _askName(
      context,
      title: 'Add brand heading',
      label: 'Brand name',
      confirm: 'Add heading',
    );
    if (name == null || !mounted) return;
    await _run(() => _catalog.addBrand(widget.categoryId, name));
  }

  Future<void> _renameBrand(CatalogBrand brand) async {
    final name = await _askName(
      context,
      title: 'Rename heading',
      label: 'Brand name',
      confirm: 'Save',
      initial: brand.name,
    );
    if (name == null || !mounted) return;
    await _run(() => _catalog.renameBrand(brand.id, name));
  }

  Future<void> _deleteBrand(CatalogBrand brand) async {
    final confirmed = await _confirm(
      context,
      title: 'Remove ${brand.name}?',
      body: _removalBody(devices: brand.devices.length),
      action: 'Remove heading',
    );
    if (!confirmed || !mounted) return;
    await _run(() => _catalog.deleteBrand(brand.id));
  }

  Future<void> _addDevice(CatalogBrand brand) async {
    final name = await _askName(
      context,
      title: 'Add device',
      label: 'Device name',
      confirm: 'Add device',
    );
    if (name == null || !mounted) return;
    await _run(() => _catalog.addDevice(brand.id, name));
  }

  Future<void> _renameDevice(CatalogDevice device) async {
    final name = await _askName(
      context,
      title: 'Rename device',
      label: 'Device name',
      confirm: 'Save',
      initial: device.name,
    );
    if (name == null || !mounted) return;
    await _run(() => _catalog.renameDevice(device.id, name));
  }

  Future<void> _deleteDevice(CatalogDevice device) async {
    final confirmed = await _confirm(
      context,
      title: 'Remove ${device.name}?',
      body: '"${device.name}" leaves the intake picker. Past tickets keep the '
          'device name they recorded.',
      action: 'Remove device',
    );
    if (!confirmed || !mounted) return;
    await _run(() => _catalog.deleteDevice(device.id));
  }

  Future<void> _editWarranty(CatalogCategory category) async {
    final updated = await _askWarrantyDays(
      context,
      initial: category.warrantyDays,
    );
    if (updated == null || !mounted) return;
    await _run(() => _catalog.setCategoryWarrantyDays(category.id, updated));
  }

  Future<void> _deleteCategory() async {
    final confirmed = await _confirm(
      context,
      title: 'Remove ${widget.categoryName}?',
      body: 'Every heading and device under "${widget.categoryName}" leaves '
          'the intake picker. Past tickets keep the device names they '
          'recorded.',
      action: 'Remove category',
    );
    if (!confirmed || !mounted) return;
    await _run(
      () => _catalog.deleteCategory(widget.categoryId),
      close: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: StreamBuilder<CatalogCategory?>(
        stream: _catalog.watchCategory(widget.categoryId),
        builder: (context, snapshot) {
          final category = snapshot.data;
          if (category == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('This category was removed.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              ListTile(
                key: const Key('catalog-category-warranty'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_user_outlined),
                title: const Text('Warranty period'),
                subtitle: Text(
                  '${WarrantyConfig.daysLabel(category.warrantyDays)} · '
                  'offered on Report 3',
                ),
                trailing: TextButton(
                  key: const Key('catalog-category-warranty-edit'),
                  onPressed: () => _editWarranty(category),
                  child: const Text('Change'),
                ),
              ),
              const Divider(),
              SectionHeading(
                title: 'Brand headings',
                action: FilledButton.icon(
                  key: const Key('catalog-add-brand'),
                  onPressed: _addBrand,
                  icon: const Icon(Icons.add),
                  label: const Text('Add heading'),
                ),
              ),
              if (category.brands.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.category_outlined),
                  title: Text('No headings yet.'),
                  subtitle: Text(
                    'Add a brand heading, then the devices you service under it.',
                  ),
                ),
              for (final brand in category.brands)
                _BrandCard(
                  brand: brand,
                  onAddDevice: () => _addDevice(brand),
                  onRename: () => _renameBrand(brand),
                  onDelete: () => _deleteBrand(brand),
                  onRenameDevice: _renameDevice,
                  onDeleteDevice: _deleteDevice,
                  onToggleDevice: (device, isActive) => _run(
                    () => _catalog.setDeviceActive(device.id, isActive),
                  ),
                ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  key: const Key('catalog-delete-category'),
                  onPressed: _deleteCategory,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove this category'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({
    required this.brand,
    required this.onAddDevice,
    required this.onRename,
    required this.onDelete,
    required this.onRenameDevice,
    required this.onDeleteDevice,
    required this.onToggleDevice,
  });

  final CatalogBrand brand;
  final VoidCallback onAddDevice;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final ValueChanged<CatalogDevice> onRenameDevice;
  final ValueChanged<CatalogDevice> onDeleteDevice;
  final void Function(CatalogDevice device, bool isActive) onToggleDevice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: Key('catalog-brand-${brand.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    brand.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  key: Key('catalog-add-device-${brand.id}'),
                  onPressed: onAddDevice,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add device'),
                ),
                PopupMenuButton<_BrandAction>(
                  key: Key('catalog-brand-menu-${brand.id}'),
                  tooltip: 'Heading actions',
                  onSelected: (action) => switch (action) {
                    _BrandAction.rename => onRename(),
                    _BrandAction.delete => onDelete(),
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _BrandAction.rename,
                      child: Text('Rename heading'),
                    ),
                    PopupMenuItem(
                      value: _BrandAction.delete,
                      child: Text('Remove heading'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (brand.devices.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('No devices yet.'),
              ),
            ),
          for (final device in brand.devices)
            ListTile(
              key: Key('catalog-device-${device.id}'),
              dense: true,
              contentPadding: const EdgeInsets.only(left: 16, right: 4),
              leading: Icon(
                Icons.memory_outlined,
                color: device.isActive
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
              title: Text(device.name),
              subtitle:
                  device.isActive ? null : const Text('Hidden from intake'),
              trailing: PopupMenuButton<_DeviceAction>(
                key: Key('catalog-device-menu-${device.id}'),
                tooltip: 'Device actions',
                onSelected: (action) => switch (action) {
                  _DeviceAction.rename => onRenameDevice(device),
                  _DeviceAction.toggle => onToggleDevice(
                      device,
                      !device.isActive,
                    ),
                  _DeviceAction.delete => onDeleteDevice(device),
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _DeviceAction.rename,
                    child: Text('Rename device'),
                  ),
                  PopupMenuItem(
                    value: _DeviceAction.toggle,
                    child: Text(
                      device.isActive ? 'Hide from intake' : 'Show in intake',
                    ),
                  ),
                  const PopupMenuItem(
                    value: _DeviceAction.delete,
                    child: Text('Remove device'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum _CategoryAction { rename, warranty, delete }

enum _BrandAction { rename, delete }

enum _DeviceAction { rename, toggle, delete }

String _categorySummary(CatalogCategory category) {
  final headings = category.brands.length;
  final devices = category.deviceCount;
  return [
    if (!category.isActive) 'Hidden',
    '${WarrantyConfig.daysLabel(category.warrantyDays)} warranty',
    '$headings ${headings == 1 ? 'heading' : 'headings'}',
    '$devices ${devices == 1 ? 'device' : 'devices'}',
  ].join(' · ');
}

String _removalBody({int headings = 0, int devices = 0}) {
  final parts = [
    if (headings > 0) '$headings ${headings == 1 ? 'heading' : 'headings'}',
    if (devices > 0) '$devices ${devices == 1 ? 'device' : 'devices'}',
  ];
  final attached = parts.isEmpty
      ? 'Nothing else is filed under it.'
      : '${parts.join(' and ')} under it will be removed too.';
  return '$attached Past tickets keep the device names they recorded.';
}

Future<String?> _askName(
  BuildContext context, {
  required String title,
  required String label,
  required String confirm,
  String? initial,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(
      title: title,
      label: label,
      confirm: confirm,
      initial: initial,
    ),
  );
}

Future<int?> _askWarrantyDays(
  BuildContext context, {
  required int initial,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _WarrantyDaysDialog(initial: initial),
  );
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('catalog-confirm-remove'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.label,
    required this.confirm,
    this.initial,
  });

  final String title;
  final String label;
  final String confirm;
  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  bool get _canSave => _controller.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSave) return;
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          width: 380,
          child: TextField(
            key: const Key('catalog-name-field'),
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: widget.label),
            onSubmitted: (_) => _submit(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('catalog-name-save'),
            onPressed: _canSave ? _submit : null,
            child: Text(widget.confirm),
          ),
        ],
      );
}

class _WarrantyDaysDialog extends StatefulWidget {
  const _WarrantyDaysDialog({required this.initial});

  final int initial;

  @override
  State<_WarrantyDaysDialog> createState() => _WarrantyDaysDialogState();
}

class _WarrantyDaysDialogState extends State<_WarrantyDaysDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.initial}');

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  int? get _days {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 1 || value > WarrantyConfig.maxDays) {
      return null;
    }
    return value;
  }

  void _submit() {
    final days = _days;
    if (days == null) return;
    Navigator.pop(context, days);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Warranty period'),
        content: SizedBox(
          width: 380,
          child: TextField(
            key: const Key('catalog-warranty-days'),
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Days of cover',
              helperText: '1–${WarrantyConfig.maxDays} days · '
                  'default ${WarrantyConfig.defaultDays}',
              errorText: _days == null ? 'Enter a number of days.' : null,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('catalog-warranty-save'),
            onPressed: _days == null ? null : _submit,
            child: const Text('Save'),
          ),
        ],
      );
}
