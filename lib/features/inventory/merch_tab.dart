import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../../shell/app_access.dart';
import 'add_merch_item_dialog.dart';
import 'adjust_stock_dialog.dart';

class MerchTab extends StatelessWidget {
  const MerchTab({super.key});

  Future<void> _removeItem(
    BuildContext context,
    TicketsRepository repository,
    InventoryMerchItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove item from merchandise?'),
        content: Text(
          'Remove ${item.name} from the active merchandise list? Existing '
          'sales and revenue history will be preserved.',
        ),
        actions: [
          TextButton(
            key: Key('cancel-remove-merch-item-${item.id}'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: Key('confirm-remove-merch-item-${item.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove item'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await repository.removeMerchItem(item.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} removed from merchandise')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove ${item.name}: $error')),
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
        child: StreamBuilder<List<InventoryMerchItem>>(
          stream: repository.watchMerchItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Could not load merchandise inventory.'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
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
                            'Merch',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Retail stock sold over the counter. Separately '
                            'tracked from repair parts for stock and revenue.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      key: const Key('merch-add-item'),
                      onPressed: () => showAddMerchItemDialog(
                        context,
                        repository: repository,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add item'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No merchandise yet. Add an item to start tracking '
                        'retail stock, cost and price.',
                      ),
                    ),
                  )
                else
                  for (final item in items)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.storefront_outlined),
                        title: Text(item.name),
                        subtitle: Text([
                          if (item.description != null &&
                              item.description!.trim().isNotEmpty)
                            item.description!.trim(),
                          if (item.category != null) item.category!,
                          if (item.sku != null) 'SKU ${item.sku}',
                          if (item.location != null)
                            'Location ${item.location}',
                          'Cost ${_money(item.costCents)}',
                          'Retail ${_money(item.priceCents)}',
                          if (item.priceCents > 0)
                            '${(item.profitCents * 100 / item.priceCents).round()}'
                                '% margin',
                        ].join(' · ')),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Chip(
                              label: Text('Stock ${item.stock}'),
                              visualDensity: VisualDensity.compact,
                            ),
                            if (AppSessionScope.accessOf(context)
                                    .canAdjustStock &&
                                !AppSessionScope.accessOf(context)
                                    .canChangeInventory)
                              TextButton.icon(
                                key: Key('adjust-stock-merch-${item.id}'),
                                onPressed: () => showAdjustStockDialog(
                                  context,
                                  name: item.name,
                                  stock: item.stock,
                                  onSave: (stock) => saveMerchItemStock(
                                    repository,
                                    item,
                                    stock,
                                  ),
                                ),
                                icon: const Icon(Icons.exposure),
                                label: const Text('Adjust stock'),
                              ),
                            if (AppSessionScope.accessOf(context)
                                .canChangeInventory) ...[
                              TextButton.icon(
                                key: Key('edit-merch-item-${item.id}'),
                                onPressed: () => showEditMerchItemDialog(
                                  context,
                                  repository: repository,
                                  item: item,
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF0D47A1),
                                  visualDensity: VisualDensity.compact,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                              IconButton(
                                key: Key('delete-merch-item-${item.id}'),
                                tooltip: 'Remove ${item.name} from merchandise',
                                onPressed: () =>
                                    _removeItem(context, repository, item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}
