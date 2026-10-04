import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/mock_wedding_repository.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = MockWeddingRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Your planner'), centerTitle: false),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryPlum,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR WEDDING PLAN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Every detail, in one place.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Keep track of bookings and next steps as your day comes together.',
                    style: TextStyle(color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'BOOKINGS',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            if (repo.bookings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Your confirmed vendor bookings will appear here.',
                  ),
                ),
              ),
            ...repo.bookings.map(
              (booking) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.plumTint,
                    child: Icon(
                      Icons.event_available_rounded,
                      color: AppColors.primaryPlum,
                    ),
                  ),
                  title: Text(
                    booking.vendorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${booking.vendorCategory} · ${booking.status}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'NEXT STEPS',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            const _PlannerTask(
              icon: Icons.location_city_rounded,
              title: 'Choose your wedding venue',
              subtitle: 'Confirm capacity and availability',
            ),
            const _PlannerTask(
              icon: Icons.restaurant_rounded,
              title: 'Plan your guest experience',
              subtitle: 'Shortlist catering and menu options',
            ),
            const _PlannerTask(
              icon: Icons.camera_alt_rounded,
              title: 'Capture your celebration',
              subtitle: 'Compare photography portfolios',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerTask extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PlannerTask({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.plumTint,
        child: Icon(icon, color: AppColors.primaryPlum),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.circle_outlined, color: AppColors.textMuted),
    ),
  );
}
