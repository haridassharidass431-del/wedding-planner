import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/luxury_button.dart';
import '../../../core/widgets/safe_network_image.dart';
import '../../../data/models/vendor.dart';
import '../../../data/repositories/mock_wedding_repository.dart';
import '../main_navigation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Vendor vendor;
  final VendorPackage? selectedPackage;

  const BookingScreen({super.key, required this.vendor, this.selectedPackage});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final MockWeddingRepository _repository = MockWeddingRepository();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController(
    text: '',
  );
  final TextEditingController _customerContactController =
      TextEditingController(text: '+91 98400 12345');

  late VendorPackage _currentPackage;
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  String _selectedSlot = 'Morning Muhurtham (05:30 AM - 12:00 PM)';
  final int _guestCount = 800;
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    'Morning Muhurtham (05:30 AM - 12:00 PM)',
    'Evening Reception (04:30 PM - 10:30 PM)',
    'Full Day Auspicious (24 Hours Royal Access)',
  ];

  @override
  void initState() {
    super.initState();
    _customerNameController.text = _repository.currentUserName == 'Guest'
        ? ''
        : _repository.currentUserName;
    _currentPackage =
        widget.selectedPackage ??
        (widget.vendor.packages.isNotEmpty
            ? widget.vendor.packages.first
            : const VendorPackage(
                id: 'p_def',
                name: 'Classic Auspicious Package',
                price: 75000,
                description: 'Complete essential setup',
                features: ['Full access', 'Event coordinator'],
              ));

    final initialDate = _firstAvailableDate() ?? DateTime.now().add(const Duration(days: 1));
    _selectedDate = initialDate;
    _focusedMonth = DateTime(initialDate.year, initialDate.month, 1);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customerNameController.dispose();
    _customerContactController.dispose();
    super.dispose();
  }

  DateTime? _firstAvailableDate() {
    final start = DateTime.now();
    for (int i = 0; i < 120; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      if (_repository.isDateAvailable(widget.vendor.id, date)) {
        return date;
      }
    }
    return null;
  }

  bool _isPastDate(DateTime date) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return date.isBefore(startOfToday);
  }

  bool _isAvailableDate(DateTime date) {
    return !_isPastDate(date) && _repository.isDateAvailable(widget.vendor.id, date);
  }

  bool _isValidBookingDate() {
    return !_selectedDate.isBefore(DateTime.now()) &&
        _repository.isDateAvailable(widget.vendor.id, _selectedDate);
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final leadingEmptyDays = firstDayOfMonth.weekday % 7;
    final totalCells = leadingEmptyDays + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final totalSlots = rows * 7;
    final dates = List<DateTime?>.filled(totalSlots, null, growable: false);

    for (int day = 1; day <= daysInMonth; day++) {
      dates[leadingEmptyDays + day - 1] = DateTime(
        _focusedMonth.year,
        _focusedMonth.month,
        day,
      );
    }

    return dates;
  }

  void _showSelectionStatus() {
    if (_selectedDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This date is not available. Please choose another date.'),
        ),
      );
      return;
    }

    if (!_repository.isDateAvailable(widget.vendor.id, _selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This date is not available. Please choose another date.'),
        ),
      );
      return;
    }
  }

  void _submitBookingRequest() async {
    if (!_isValidBookingDate()) {
      _showSelectionStatus();
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final customerName = _customerNameController.text.trim();
    final customerContact = _customerContactController.text.trim();
    final booking = _repository.submitBookingRequest(
      vendorId: widget.vendor.id,
      hallName: widget.vendor.name,
      customerName: customerName.isEmpty ? 'Customer' : customerName,
      customerContact: customerContact.isEmpty
          ? '+91 00000 00000'
          : customerContact,
      bookingDate: _selectedDate,
      requestedTime: _selectedSlot,
      guestCount: _guestCount,
      customerMessage: _notesController.text.trim(),
      packageName: _currentPackage.name,
      venueLocation: widget.vendor.location,
      vendorName: widget.vendor.name,
      vendorCategory: widget.vendor.category,
      vendorImage: widget.vendor.heroImage,
      totalPrice: _currentPackage.price,
    );

    setState(() => _isSubmitting = false);
    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(bookingId: booking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final calendarDays = _buildCalendarDays();

    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: SafeNetworkImage(
                        imageUrl: widget.vendor.heroImage,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vendor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.vendor.category} • ${widget.vendor.location}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softChampagne,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _currentPackage.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPlum,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final nextMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month - 1,
                              1,
                            );
                            setState(() => _focusedMonth = nextMonth);
                          },
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Text(
                            DateFormat.yMMMM().format(_focusedMonth),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPlum,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final nextMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month + 1,
                              1,
                            );
                            setState(() => _focusedMonth = nextMonth);
                          },
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        _DayLabel('Su'),
                        _DayLabel('Mo'),
                        _DayLabel('Tu'),
                        _DayLabel('We'),
                        _DayLabel('Th'),
                        _DayLabel('Fr'),
                        _DayLabel('Sa'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      itemCount: calendarDays.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final date = calendarDays[index];
                        if (date == null) {
                          return const SizedBox.shrink();
                        }

                        final isSelected =
                            DateTime(date.year, date.month, date.day) ==
                            DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                            );
                        final isPast = _isPastDate(date);
                        final isAvailable = _isAvailableDate(date);

                        return InkWell(
                          onTap: isPast || !isAvailable
                              ? null
                              : () => setState(() => _selectedDate = date),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryPlum
                                  : isPast
                                  ? Colors.grey.shade100
                                  : isAvailable
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryPlum
                                    : isPast
                                    ? Colors.grey.shade300
                                    : isAvailable
                                    ? AppColors.success
                                    : AppColors.error,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : isPast
                                          ? Colors.grey
                                          : isAvailable
                                          ? AppColors.textPrimary
                                          : AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isSelected
                                        ? 'Selected'
                                        : isPast
                                        ? 'Past'
                                        : isAvailable
                                        ? 'Available'
                                        : 'Booked',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : isPast
                                          ? Colors.grey
                                          : isAvailable
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _LegendChip(color: AppColors.success, label: 'Available'),
                        _LegendChip(color: AppColors.primaryPlum, label: 'Selected'),
                        _LegendChip(color: AppColors.error, label: 'Unavailable'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryPlum,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(label: 'Vendor', value: widget.vendor.name),
                    _SummaryRow(label: 'Service', value: _currentPackage.name),
                    _SummaryRow(
                      label: 'Date',
                      value: DateFormat('dd MMMM yyyy').format(_selectedDate),
                    ),
                    _SummaryRow(label: 'Time', value: _selectedSlot),
                    _SummaryRow(label: 'Location', value: widget.vendor.location),
                    _SummaryRow(
                      label: 'Status',
                      value: _isValidBookingDate() ? 'Available' : 'Unavailable',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPlum,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customerContactController,
                decoration: const InputDecoration(labelText: 'Phone number'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Event Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPlum,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedSlot,
                items: _timeSlots
                    .map(
                      (slot) => DropdownMenuItem(value: slot, child: Text(slot)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedSlot = value);
                },
                decoration: const InputDecoration(labelText: 'Preferred time'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              if (!_isValidBookingDate())
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'This date is not available. Please choose another date.',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.goldBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Price',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryPlum,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentPackage.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(_currentPackage.price),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Not collected now',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.borderLight),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(_currentPackage.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryPlum,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LuxuryButton(
                text: 'Continue',
                isLoading: _isSubmitting,
                isGold: true,
                icon: Icons.check_circle_outline_rounded,
                onPressed: _submitBookingRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class BookingSuccessScreen extends StatelessWidget {
  final String bookingId;
  const BookingSuccessScreen({super.key, required this.bookingId});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroPlumGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 76)),
              const SizedBox(height: 18),
              const Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your wedding service has been booked successfully.',
                style: TextStyle(
                  color: AppColors.brightGold,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'You can track the booking status in My Booking.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Reference  $bookingId',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryPlum,
                  ),
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                          const MainNavigationScreen(initialIndex: 3),
                    ),
                    (route) => false,
                  ),
                  child: const Text('View My Booking'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainNavigationScreen(),
                  ),
                  (route) => false,
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
