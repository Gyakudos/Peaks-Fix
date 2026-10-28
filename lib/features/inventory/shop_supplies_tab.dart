import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import 'add_inventory_part_dialog.dart';

class ShopSuppliesTab extends StatelessWidget {
  const ShopSuppliesTab({super.key});

  Future<void> _removePart(
    BuildContext context,
    TicketsRepository repository,
    InventoryPart part,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove shop supply?'),
        content: Text(
          'Remove ${part.name} from shop supplies? Existing history will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await repository.removeInventoryPart(part.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${part.name} removed from shop supplies')),
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
                child: Text('Could not load shop supplies inventory.'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final parts = snapshot.data!
                .where((part) => isShopSupplyCategory(part.category))
                .toList();
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
                            'Shop Supplies',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Supplies used on repairs, like thermal paste. They are '
                            'listed under Shop Supplies on the invoice but '
                            'never billed to the customer, and come out of '
                            'inventory when the ticket closes.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      key: const Key('add-shop-supply'),
                      onPressed: () => showAddInventoryPartDialog(
                        context,
                        repository: repository,
                        shopSupply: true,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add supply'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (parts.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No shop supplies yet',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add supplies you use in-house to track inventory.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final part in parts)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.handyman_outlined),
                        title: Text(part.name),
                        subtitle: Text([
                          if (part.description != null &&
                              part.description!.trim().isNotEmpty)
                            part.description!.trim(),
                          if (part.category != null) part.category!,
                          if (part.sku != null) 'SKU ${part.sku}',
                          if (part.location != null)
                            'Location ${part.location}',
                          if (part.purchaseType == PartPurchaseType.tube)
                            'Full tubes ${part.fullTubes} · '
                                '${part.usesInOpenTube} uses in open tube',
                          'Inventory ${part.inventory}',
                          'Minimum stock ${part.minimumStock}',
                        ].join(' · ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () => showEditInventoryPartDialog(
                                context,
                                repository: repository,
                                part: part,
                                shopSupply: true,
                              ),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _removePart(context, repository, part),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remove'),
                            ),
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
}
