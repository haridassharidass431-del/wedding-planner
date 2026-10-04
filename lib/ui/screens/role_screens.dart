import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/mock_wedding_repository.dart';
import '../../data/models/booking.dart';
import 'vendors/vendor_details_screen.dart';

final _repo = MockWeddingRepository();

class WeddingReelsScreen extends StatefulWidget {
  const WeddingReelsScreen({super.key});
  @override
  State<WeddingReelsScreen> createState() => _WeddingReelsScreenState();
}

class _WeddingReelsScreenState extends State<WeddingReelsScreen> {
  final Set<String> _liked = {};
  @override
  Widget build(BuildContext context) {
    final vendors = _repo.vendors;
    if (vendors.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('New wedding stories are coming soon.')),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          final liked = _liked.contains(vendor.id);
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                vendor.heroImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryPlum,
                  child: const Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                    stops: [0.45, 1],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 86,
                bottom: 44,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${vendor.category} · ${vendor.location}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vendor.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VendorDetailsScreen(vendor: vendor),
                        ),
                      ),
                      child: const Text('View Vendor / Book'),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                bottom: 150,
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () => setState(
                        () => liked
                            ? _liked.remove(vendor.id)
                            : _liked.add(vendor.id),
                      ),
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? AppColors.secondaryPurple : Colors.white,
                        size: 32,
                      ),
                    ),
                    const Text('Like', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 14),
                    IconButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Share link copied when sharing is available.',
                              ),
                            ),
                          ),
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Text('Share', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              Positioned(
                top: 54,
                left: 20,
                child: Text(
                  'WEDDING STORIES',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyBookingsScreen extends StatelessWidget {
  final bool vendorMode;
  const MyBookingsScreen({super.key, this.vendorMode = false});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _repo,
    builder: (context, _) {
      final List<Booking> bookings = vendorMode
          ? _repo.bookings
                .where(
                  (b) => _repo.myServices.any((s) => s['id'] == b.vendorId),
                )
                .toList()
          : _repo.getCustomerBookings(_repo.currentUserName);
      return Scaffold(
        appBar: AppBar(title: Text(vendorMode ? 'My Bookings' : 'My Booking')),
        body: bookings.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'Your bookings will appear here. Explore approved wedding services to get started.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  return _BookingCard(booking: b, vendorMode: vendorMode);
                },
              ),
      );
    },
  );
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool vendorMode;
  const _BookingCard({required this.booking, required this.vendorMode});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vendorMode ? booking.customerName : booking.vendorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Chip(label: Text(booking.status)),
            ],
          ),
          Text('${booking.vendorCategory} · ${booking.packageName}'),
          const SizedBox(height: 6),
          Text(
            '${DateFormat('EEE, d MMM yyyy').format(booking.eventDate)} · ${booking.timeSlot}',
          ),
          Text(
            '₹${booking.totalPrice.toStringAsFixed(0)} · ${booking.location}',
          ),
          if (vendorMode) Text('Contact: ${booking.customerContact}'),
          if (vendorMode && booking.status == 'Confirmed')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _repo.completeVendorBooking(booking.id),
                icon: const Icon(Icons.task_alt_rounded),
                label: const Text('Mark completed'),
              ),
            ),
        ],
      ),
    ),
  );
}

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _repo,
    builder: (context, _) {
      final items = _repo.myServices;
      final pending = items.where((s) => s['status'] == 'pending').length;
      final approved = items.where((s) => s['status'] == 'approved').length;
      return Scaffold(
        appBar: AppBar(title: const Text('Vendor Studio')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Welcome, ${_repo.currentUserName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryPlum,
              ),
            ),
            const SizedBox(height: 6),
            const Text('Your services and booking activity at a glance.'),
            const SizedBox(height: 20),
            Row(
              children: [
                _MetricCard(label: 'Services', value: '${items.length}'),
                _MetricCard(label: 'Pending', value: '$pending'),
                _MetricCard(label: 'Approved', value: '$approved'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Your services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Add a service to start building your vendor page.',
                  ),
                ),
              )
            else
              ...items.map(
                (s) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(s['name']),
                    subtitle: Text('${s['category']} · ₹${s['price']}'),
                    trailing: Chip(
                      label: Text(s['status'].toString().toUpperCase()),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _MetricCard extends StatelessWidget {
  final String label, value;
  const _MetricCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryPlum,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class AddServiceScreen extends StatefulWidget {
  final Map<String, dynamic>? service;
  const AddServiceScreen({super.key, this.service});
  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _description = TextEditingController(),
      _location = TextEditingController(),
      _price = TextEditingController(),
      _image = TextEditingController();
  String _category = AppConstants.serviceCategories.first;
  @override
  void initState() {
    super.initState();
    final service = widget.service;
    if (service == null) return;
    _name.text = service['name']?.toString() ?? '';
    _description.text = service['description']?.toString() ?? '';
    _location.text = service['location']?.toString() ?? '';
    _price.text = service['price']?.toString() ?? '';
    _category = service['category']?.toString() ?? _category;
    final images = service['images'] as List? ?? const [];
    _image.text = images.isEmpty ? '' : images.first.toString();
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _location, _price, _image]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.service == null ? 'Add a service' : 'Edit a service'),
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.service == null ? 'Share your work' : 'Update your service',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryPlum,
            ),
          ),
          const SizedBox(height: 16),
          _input(_name, 'Service name'),
          _input(_description, 'Description', lines: 3),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: AppConstants.serviceCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 14),
          _input(_location, 'Location'),
          _input(_price, 'Price (₹)', type: TextInputType.number),
          _input(_image, 'Image URL (optional)'),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              final images = _image.text.isEmpty ? <String>[] : [_image.text];
              final submitted = widget.service == null
                  ? _repo.submitService(
                          name: _name.text,
                          description: _description.text,
                          category: _category,
                          location: _location.text,
                          price: double.tryParse(_price.text) ?? 0,
                          images: images,
                        ) !=
                        null
                  : _repo.updateService(
                      id: widget.service!['id'].toString(),
                      name: _name.text,
                      description: _description.text,
                      category: _category,
                      location: _location.text,
                      price: double.tryParse(_price.text) ?? 0,
                      images: images,
                    );
              if (!submitted) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    widget.service == null
                        ? 'Submitted for review'
                        : 'Updated for review',
                  ),
                  content: const Text(
                    'Your service has been submitted for admin approval.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              widget.service == null
                  ? 'Submit for approval'
                  : 'Save and resubmit',
            ),
          ),
        ],
      ),
    ),
  );
  Widget _input(
    TextEditingController c,
    String label, {
    int lines = 1,
    TextInputType? type,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      maxLines: lines,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
      validator: (v) => label.contains('optional') || label.contains('URL')
          ? null
          : ((v ?? '').trim().isEmpty ? 'Required' : null),
    ),
  );
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin dashboard')),
    body: const AdminRequestsScreen(),
  );
}

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _repo,
    builder: (context, _) {
      final requests = _repo.pendingServices;
      return Scaffold(
        appBar: AppBar(title: const Text('Pending vendor requests')),
        body: requests.isEmpty
            ? const Center(child: Text('No pending requests.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, i) {
                  final s = requests[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['vendorName'],
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            s['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${s['category']} · ${s['location']} · ₹${s['price']}',
                          ),
                          const SizedBox(height: 6),
                          Text(s['description']),
                          if ((s['images'] as List).isNotEmpty)
                            Text(
                              'Image: ${(s['images'] as List).first}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _repo.reviewService(
                                    s['id'],
                                    approve: true,
                                  ),
                                  child: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _repo.reviewService(
                                    s['id'],
                                    approve: false,
                                    reason: 'Please update service details',
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                            ],
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
}
