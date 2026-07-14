import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/shared_moment.dart';
import '../providers/shared_moments_provider.dart';

class SharedMomentsPage extends ConsumerWidget {
  const SharedMomentsPage({super.key, required this.childId});
  final String childId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(sharedMomentsProvider(childId));
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        title: const Text('Moments partagés'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/child/$childId/house'),
        ),
      ),
      body: moments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Impossible de retrouver les souvenirs pour le moment.'),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_outline_rounded,
                        size: 48,
                        color: Color(0xFFD38C9D),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Vos prochains beaux moments apparaîtront ici.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) => _MomentCard(items[index]),
              ),
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard(this.moment);
  final SharedMoment moment;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF7DDE4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(_icon(moment.iconId), color: const Color(0xFFB4657B)),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moment.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4D3D47),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                moment.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF756873), fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                '${_date(moment.date)} · avec ${_guardian(moment.guardianId)}',
                style: const TextStyle(
                  color: Color(0xFF9A7E88),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  static String _guardian(String id) =>
      id.isEmpty ? 'ton Gardien' : '${id[0].toUpperCase()}${id.substring(1)}';
  static IconData _icon(String id) => switch (id) {
    'palette' => Icons.palette_rounded,
    'plant' => Icons.local_florist_rounded,
    'nature' => Icons.park_rounded,
    'gift' => Icons.card_giftcard_rounded,
    'build' => Icons.construction_rounded,
    'chat' => Icons.chat_bubble_rounded,
    _ => Icons.favorite_rounded,
  };
}
