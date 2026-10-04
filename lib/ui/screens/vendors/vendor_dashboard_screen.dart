import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/vendor_earnings.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../role_screens.dart' show AddServiceScreen;

final _vendorRepo = MockWeddingRepository();

class VendorBusinessDashboardScreen extends StatelessWidget {
  const VendorBusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vendorRepo,
    builder: (context, _) {
      final services = _vendorRepo.myServices;
      final bookings = _vendorRepo.getVendorBookings();
      final summary = _vendorRepo.vendorEarnings;
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Vendor Dashboard')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            final contentWidth = constraints.maxWidth > 1240
                ? 1240.0
                : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Welcome back, ${_vendorRepo.currentUserName}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.primaryPlum,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VendorEarningsScreen(),
                            ),
                          ),
                          icon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                          label: const Text('Earnings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Business overview · bookings, services and earnings.',
                    ),
                    const SizedBox(height: 18),
                    _metricGrid(contentWidth, [
                      _Metric(
                        'Total Bookings',
                        '${bookings.length}',
                        Icons.event_note_rounded,
                      ),
                      _Metric(
                        'Pending Requests',
                        '${summary.pendingRequests}',
                        Icons.pending_actions_rounded,
                      ),
                      _Metric(
                        'Approved Services',
                        '${services.where((service) => service['status'] == 'approved').length}',
                        Icons.verified_outlined,
                      ),
                      _Metric(
                        'Total Earnings',
                        formatter.format(summary.totalEarnings),
                        Icons.account_balance_wallet_outlined,
                      ),
                    ]),
                    const SizedBox(height: 18),
                    if (desktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _WeeklyEarningsCard(summary: summary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _BookingPerformanceCard(
                              summary: summary,
                              bookings: bookings,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _WeeklyEarningsCard(summary: summary),
                      const SizedBox(height: 14),
                      _BookingPerformanceCard(
                        summary: summary,
                        bookings: bookings,
                      ),
                    ],
                    const SizedBox(height: 22),
                    const Text(
                      'Recent bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (bookings.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('New booking requests will appear here.'),
                        ),
                      )
                    else
                      ...bookings
                          .take(3)
                          .map(
                            (booking) => _RecentBookingTile(
                              booking: booking,
                              formatter: formatter,
                            ),
                          ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'My Services',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddServiceScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Post service'),
                        ),
                      ],
                    ),
                    if (services.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Your services will appear here. Post a service to start building your vendor page.',
                          ),
                        ),
                      )
                    else
                      ...services.map(
                        (service) => _ServiceTile(
                          service: service,
                          formatter: formatter,
                        ),
                      ),
                    if (services.any(
                      (service) => service['status'] == 'pending',
                    ))
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'New and edited services stay hidden from customers until admin approval.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );

  Widget _metricGrid(double width, List<_Metric> metrics) {
    final columns = width >= 900
        ? 4
        : width >= 520
        ? 2
        : 1;
    final itemWidth = (width - 40 - (columns - 1) * 12) / columns;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics
          .map(
            (metric) => SizedBox(
              width: itemWidth,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.plumTint,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(metric.icon, color: AppColors.primaryPlum),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metric.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryPlum,
                              ),
                            ),
                            Text(
                              metric.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class VendorEarningsScreen extends StatelessWidget {
  const VendorEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vendorRepo,
    builder: (context, _) {
      final summary = _vendorRepo.vendorEarnings;
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      final bookings = _vendorRepo.getVendorBookings();
      return Scaffold(
        appBar: AppBar(title: const Text('Earnings')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Income overview',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPlum,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Booking value estimates from your business records. Payments are not collected or tracked.',
                ),
                const SizedBox(height: 18),
                _metricGrid(MediaQuery.sizeOf(context).width, [
                  _Metric(
                    'Total Earnings',
                    formatter.format(summary.totalEarnings),
                    Icons.account_balance_wallet_outlined,
                  ),
                  _Metric(
                    'This Month',
                    formatter.format(summary.thisMonth),
                    Icons.calendar_month_outlined,
                  ),
                  _Metric(
                    'This Week',
                    formatter.format(summary.thisWeek),
                    Icons.date_range_outlined,
                  ),
                  _Metric(
                    'Completed Bookings',
                    '${summary.completed.length}',
                    Icons.task_alt_rounded,
                  ),
                  _Metric(
                    'Pending Amount',
                    formatter.format(summary.pendingAmount),
                    Icons.hourglass_bottom_rounded,
                  ),
                ]),
                const SizedBox(height: 18),
                _WeeklyEarningsCard(summary: summary),
                const SizedBox(height: 14),
                _BookingPerformanceCard(summary: summary, bookings: bookings),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _metricGrid(double width, List<_Metric> metrics) {
  final columns = width >= 1100
      ? 4
      : width >= 600
      ? 2
      : 1;
  final availableWidth = width > 1240 ? 1100.0 : width;
  final itemWidth = (availableWidth - 40 - (columns - 1) * 12) / columns;
  return Wrap(
    spacing: 12,
    runSpacing: 12,
    children: metrics
        .map(
          (metric) => SizedBox(
            width: itemWidth,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.plumTint,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(metric.icon, color: AppColors.primaryPlum),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPlum,
                            ),
                          ),
                          Text(
                            metric.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _Metric {
  final String label, value;
  final IconData icon;
  const _Metric(this.label, this.value, this.icon);
}

class _ServiceTile extends StatelessWidget {
  final Map<String, dynamic> service;
  final NumberFormat formatter;
  const _ServiceTile({required this.service, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final images = service['images'] as List? ?? const [];
    final image = images.isEmpty ? '' : images.first.toString();
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: SizedBox(
          width: 54,
          height: 54,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: image.isEmpty
                ? Container(
                    color: AppColors.plumTint,
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primaryPlum,
                    ),
                  )
                : Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.plumTint,
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.primaryPlum,
                      ),
                    ),
                  ),
          ),
        ),
        title: Text(
          service['name'].toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${service['category']} · ${formatter.format((service['price'] as num?) ?? 0)}',
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            Chip(label: Text(service['status'].toString().toUpperCase())),
            IconButton(
              tooltip: 'Edit service',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddServiceScreen(service: service),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentBookingTile extends StatelessWidget {
  final Booking booking;
  final NumberFormat formatter;
  const _RecentBookingTile({required this.booking, required this.formatter});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.plumTint,
        child: Icon(
          Icons.event_available_outlined,
          color: AppColors.primaryPlum,
        ),
      ),
      title: Text(
        booking.customerName.isEmpty ? 'Customer' : booking.customerName,
      ),
      subtitle: Text(
        '${booking.vendorCategory} · ${DateFormat('d MMM yyyy').format(booking.eventDate)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatter.format(booking.totalPrice),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            booking.status,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _WeeklyEarningsCard extends StatelessWidget {
  final VendorEarningsSummary summary;
  const _WeeklyEarningsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final values = summary.dailyEarnings;
    final maxValue = values.fold<double>(0, (a, b) => a > b ? a : b);
    final labels = List.generate(
      7,
      (index) => DateFormat.E()
          .format(DateTime.now().subtract(Duration(days: 6 - index)))
          .substring(0, 1),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly earnings',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Completed bookings · last 7 days',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  7,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: maxValue == 0
                                    ? 0.04
                                    : (values[index] / maxValue).clamp(0.04, 1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPlum,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Values use completed booking records; no payment integration is active.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingPerformanceCard extends StatelessWidget {
  final VendorEarningsSummary summary;
  final List<Booking> bookings;
  const _BookingPerformanceCard({
    required this.summary,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <(String, int)>[
      ('Total bookings', bookings.length),
      ('Confirmed', summary.confirmedBookings),
      ('Completed', summary.completed.length),
      ('Pending requests', summary.pendingRequests),
      ('Cancelled / declined', summary.cancelledBookings),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking performance',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text(row.$1)),
                    Text(
                      '${row.$2}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryPlum,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
