import 'package:flutter/material.dart';

import '../../data/tickets_repository.dart';
import '../../data/shop_scope.dart';
import 'add_inventory_part_dialog.dart';

class PartsPage extends StatelessWidget {
  const PartsPage({super.key});

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
            final parts = snapshot.data!;
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
                            'Inventory linked to ticket required-parts lists. '
                            'Adding a part to a ticket does not change stock.',
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
                if (parts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No parts in inventory yet. Add a part to make it '
                        'available in a ticket’s Required Parts list.',
                      ),
                    ),
                  )
                else
                  for (final part in parts)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.memory_outlined),
                        title: Text(part.name),
                        subtitle: Text([
                          if (part.category != null) part.category!,
                          if (part.sku != null) 'SKU ${part.sku}',
                          if (part.location != null)
                            'Location ${part.location}',
                          'Raw Parts Cost ${_money(part.rawCostCents)}',
                          'Retail Parts Cost ${_money(part.retailPriceCents)}',
                        ].join(' · ')),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Chip(
                              label: Text('Stock ${part.stock}'),
                              visualDensity: VisualDensity.compact,
                            ),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
