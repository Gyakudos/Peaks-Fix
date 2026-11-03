import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../../shell/app_access.dart';
import 'add_inventory_part_dialog.dart';

class LabourTab extends StatelessWidget {
  const LabourTab({super.key});

  static bool isLabour(InventoryPart part) =>
      (part.category ?? '').trim().toLowerCase() == 'labour';

  Future<void> _removePart(
    BuildContext context,
    TicketsRepository repository,
    InventoryPart part,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove labour from inventory?'),
        content: Text(
          'Remove ${part.name} from the active labour list? Existing '
          'ticket history will be preserved.',
        ),
        actions: [
          TextButton(
            key: Key('cancel-remove-labour-${part.id}'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: Key('confirm-remove-labour-${part.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove labour'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await repository.removeInventoryPart(part.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${part.name} removed from labour')),
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
        child: StreamBuilder<Map<int, List<LabourIncludedPart>>>(
          stream: repository.watchLabourIncludedParts(),
          builder: (context, includedSnapshot) =>
              StreamBuilder<List<InventoryPart>>(
            stream: repository.watchInventoryParts(),
            builder: (context, snapshot) {
              final included = includedSnapshot.data ??
                  const <int, List<LabourIncludedPart>>{};
              if (snapshot.hasError) {
                return const Center(
                    child: Text('Could not load labour inventory.'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final names = {for (final p in snapshot.data!) p.id: p.name};
              final labour = snapshot.data!.where(isLabour).toList();
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
                              'Labour',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Labour items that can be added to ticket '
                              'invoices.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        key: const Key('inventory-add-labour'),
                        onPressed: () => showAddInventoryPartDialog(
                          context,
                          repository: repository,
                          labour: true,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add labour'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (labour.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No labour in inventory yet. Add labour to make it '
                          'available on tickets.',
                        ),
                      ),
                    )
                  else
                    for (final part in labour)
                      ListTile(
                        leading: const Icon(Icons.engineering_outlined),
                        title: Text(part.name),
                        subtitle: Text([
                          if (part.description != null &&
                              part.description!.trim().isNotEmpty)
                            part.description!.trim(),
                          if (part.sku != null) 'SKU ${part.sku}',
                          'Labour Cost ${_money(part.retailPriceCents)}',
                          if (part.jobLevel != null)
                            jobLevelLabel(part.jobLevel!),
                          if ((included[part.id] ?? const []).isNotEmpty)
                            'Includes ${(included[part.id] ?? const []).map((item) => '${item.quantity} × ${names[item.partId] ?? 'part #${item.partId}'}').join(', ')}',
                        ].join(' · ')),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            if (AppSessionScope.accessOf(context)
                                .canChangeInventory) ...[
                              TextButton.icon(
                                key: Key('edit-labour-${part.id}'),
                                onPressed: () => showEditInventoryPartDialog(
                                  context,
                                  repository: repository,
                                  part: part,
                                  labour: true,
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
                                key: Key('delete-labour-${part.id}'),
                                tooltip: 'Remove ${part.name} from labour',
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
      ),
    );
  }

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}
