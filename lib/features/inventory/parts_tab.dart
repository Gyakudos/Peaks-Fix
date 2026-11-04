import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../../shell/app_access.dart';
import 'add_inventory_part_dialog.dart';
import 'adjust_stock_dialog.dart';
import 'labour_tab.dart';

/// True when every word in [query] appears in the part's ID, brand, name,
/// description, category, vendor, vendor SKU or location.
bool partMatchesSearch(InventoryPart part, String query) {
  final terms = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  if (terms.isEmpty) return true;
  final haystack = [
    part.sku,
    part.id.toString(),
    part.brand,
    part.name,
    part.description,
    part.category,
    part.vendorId,
    part.vendorSku,
    part.location,
  ].whereType<String>().join(' ').toLowerCase();
  return terms.every(haystack.contains);
}

class PartsTab extends StatefulWidget {
  const PartsTab({super.key});

  @override
  State<PartsTab> createState() => _PartsTabState();
}

class _PartsTabState extends State<PartsTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _removePart(
    BuildContext context,
    TicketsRepository repository,
    InventoryPart part,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove part from inventory?'),
        content: Text(
          'Remove ${part.name} from the active inventory list? Existing '
          'ticket and stock history will be preserved.',
        ),
        actions: [
          TextButton(
            key: Key('cancel-remove-inventory-part-${part.id}'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: Key('confirm-remove-inventory-part-${part.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove part'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await repository.removeInventoryPart(part.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${part.name} removed from inventory')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove ${part.name}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: StreamBuilder<List<InventoryPart>>(
          stream: repository.watchInventoryParts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text('Could not load parts inventory.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final allParts = snapshot.data!
                .where((p) =>
                    !LabourTab.isLabour(p) && !isShopSupplyCategory(p.category))
                .toList();
            final parts =
                allParts.where((p) => partMatchesSearch(p, _query)).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parts',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inventory linked to ticket parts invoices. '
                            'Adding a part does not change inventory; closing '
                            'the ticket takes it out of inventory. Stock Min is the '
                            'minimum level: Inventory turns red when it '
                            'reaches it and yellow when it drops below. Committed shows what open tickets '
                            'still need.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      key: const Key('inventory-add-part'),
                      onPressed: () => showAddInventoryPartDialog(
                        context,
                        repository: repository,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add part'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('inventory-search'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search by ID, brand, name or any term',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            key: const Key('inventory-search-clear'),
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                if (allParts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No parts in inventory yet. Add a part to make it '
                        'available in a ticket’s Parts Invoice.',
                      ),
                    ),
                  )
                else if (parts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No parts match your search.'),
                    ),
                  )
                else
                  for (final part in parts)
                    ListTile(
                      leading: const Icon(Icons.memory_outlined),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (part.brand != null)
                            Text(
                              part.brand!,
                              key: Key('part-brand-${part.id}'),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          Text(part.name),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text([
                            if (part.description != null &&
                                part.description!.trim().isNotEmpty)
                              part.description!.trim(),
                            if (part.category != null) part.category!,
                            if (part.vendorSku != null)
                              'Vendor SKU ${part.vendorSku}',
                            if (part.purchaseType == PartPurchaseType.bulk)
                              'Bulk ${part.bulkQuantity} · '
                                  '${_money(part.bulkTotalCents)} total',
                            if (part.location != null)
                              'Location ${part.location}',
                          ].join(' · ')),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (part.sku != null)
                                _InfoBlock(
                                  key: Key('part-sku-${part.id}'),
                                  label: 'SKU',
                                  value: part.sku!,
                                  color: const Color(0xFF1565C0),
                                ),
                              if (part.vendorId != null)
                                _InfoBlock(
                                  key: Key('part-vendor-${part.id}'),
                                  label: 'Vendor',
                                  value: part.vendorId!,
                                  color: const Color(0xFF6A1B9A),
                                ),
                              _InfoBlock(
                                key: Key('part-raw-cost-${part.id}'),
                                label: 'Raw Parts Cost',
                                value: _money(part.rawCostCents),
                                color: const Color(0xFFE65100),
                              ),
                              _InfoBlock(
                                key: Key('part-retail-cost-${part.id}'),
                                label: 'Retail Parts Cost',
                                value: _money(part.retailPriceCents),
                                color: const Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Tooltip(
                            message:
                                'Current on-hand inventory. Deducted when a '
                                'ticket is closed.',
                            child: Chip(
                              key: Key('part-inventory-${part.id}'),
                              label: Text('Inventory ${part.inventory}'),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: _stockColor(part),
                              side: _stockColor(part) == null
                                  ? null
                                  : BorderSide(color: _stockColor(part)!),
                            ),
                          ),
                          Tooltip(
                            message:
                                'Minimum stock level (Stock Min). Inventory turns '
                                'red at this level and yellow below it. '
                                'Alerts/target '
                                'for reordering.',
                            child: Chip(
                              key: Key('part-stock-min-${part.id}'),
                              label: Text('Stock Min ${part.minimumStock}'),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          Tooltip(
                            message: 'Committed: quantity still needed by open '
                                'tickets. Closing a ticket takes its parts '
                                'out of inventory.',
                            child: Chip(
                              key: Key('part-committed-${part.id}'),
                              label: Text(
                                'Committed ${part.committedQuantity}',
                              ),
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                          if (AppSessionScope.accessOf(context)
                                  .canAdjustStock &&
                              !AppSessionScope.accessOf(context)
                                  .canChangeInventory)
                            TextButton.icon(
                              key: Key('adjust-stock-${part.id}'),
                              onPressed: () => showAdjustStockDialog(
                                context,
                                name: part.name,
                                stock: part.stock,
                                onSave: (stock) => saveInventoryPartStock(
                                  repository,
                                  part,
                                  stock,
                                ),
                              ),
                              icon: const Icon(Icons.exposure),
                              label: const Text('Adjust stock'),
                            ),
                          if (AppSessionScope.accessOf(context)
                              .canChangeInventory) ...[
                            TextButton.icon(
                              key: Key('edit-inventory-part-${part.id}'),
                              onPressed: () => showEditInventoryPartDialog(
                                context,
                                repository: repository,
                                part: part,
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF0D47A1),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              icon: const Icon(Icons.build),
                              label: const Text('Edit'),
                            ),
                            IconButton(
                              key: Key('delete-inventory-part-${part.id}'),
                              tooltip: 'Remove ${part.name} from inventory',
                              onPressed: () =>
                                  _removePart(context, repository, part),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ],
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color? _stockColor(InventoryPart part) {
    if (part.inventory < part.minimumStock) return const Color(0xFFFFEE58);
    if (part.inventory == part.minimumStock) return const Color(0xFFEF5350);
    return null;
  }

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}

/// A coloured box that makes one inventory detail stand out.
class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        border: Border.all(color: color.withValues(alpha: .6), width: 1.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
