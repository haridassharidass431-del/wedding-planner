import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/luxury_button.dart';
import '../../../core/widgets/safe_network_image.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/vendor.dart';
import '../../../data/repositories/mock_wedding_repository.dart';

class BookingScreen extends StatefulWidget {
  final Vendor vendor;
  final VendorPackage? selectedPackage;

  const BookingScreen({
    super.key,
    required this.vendor,
    this.selectedPackage,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final MockWeddingRepository _repository = MockWeddingRepository();
  final TextEditingController _notesController = TextEditingController();

  late VendorPackage _currentPackage;
  late DateTime _selectedDate;
  String _selectedSlot = 'Morning Muhurtham (05:30 AM - 12:00 PM)';
  int _guestCount = 800;
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    'Morning Muhurtham (05:30 AM - 12:00 PM)',
    'Evening Reception (04:30 PM - 10:30 PM)',
    'Full Day Auspicious (24 Hours Royal Access)',
  ];

  @override
  void initState() {
    super.initState();
    _currentPackage = widget.selectedPackage ??
        (widget.vendor.packages.isNotEmpty
            ? widget.vendor.packages.first
            : const VendorPackage(
                id: 'p_def',
                name: 'Classic Auspicious Package',
                price: 75000,
                description: 'Complete essential setup',
                features: ['Full access', 'Event coordinator'],
              ));
    _selectedDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPlum,
              onPrimary: Colors.white,
              secondary: AppColors.royalGold,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _confirmBooking() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final bookingId = 'BK-${10000 + DateTime.now().millisecondsSinceEpoch % 90000}';
    final basePrice = _currentPackage.price;
    final total = basePrice + (basePrice * 0.05); // 5% coordinator fee

    final newBooking = Booking(
      id: bookingId,
      vendorId: widget.vendor.id,
      vendorName: widget.vendor.name,
      vendorCategory: widget.vendor.category,
      vendorImage: widget.vendor.heroImage,
      location: widget.vendor.location,
      packageName: _currentPackage.name,
      eventDate: _selectedDate,
      timeSlot: _selectedSlot,
      guestCount: _guestCount,
      totalPrice: total,
      status: 'Confirmed',
      bookingDate: DateTime.now(),
      specialNotes: _notesController.text.trim(),
    );

    _repository.addBooking(newBooking);

    _showSuccessDialog(bookingId, total);
  }

  void _showSuccessDialog(String bookingId, double total) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.royalGold.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.textOnGold,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Auspicious Booking Confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPlum,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Your reservation request has been registered with ${widget.vendor.name}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.plumTint,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryPlum.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Booking ID:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          Text(bookingId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryPlum)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Wedding Date:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          Text(DateFormat('dd MMMM yyyy').format(_selectedDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Estimate:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          Text(currencyFormatter.format(total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.deepGold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                LuxuryButton(
                  text: 'Back to Home',
                  isGold: true,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final basePrice = _currentPackage.price;
    final coordinatorFee = basePrice * 0.05;
    final grandTotal = basePrice + coordinatorFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Wedding Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
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
                        const SizedBox(height: 3),
                        Text(
                          '${widget.vendor.category} • ${widget.vendor.location}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.softChampagne,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Package: ${_currentPackage.name}',
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
            const SizedBox(height: 24),

            // Step 1: Select Auspicious Date
            const Text(
              '1. Select Auspicious Date (Muhurtham)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryPlum,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.goldBorder, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppColors.primaryPlum),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Tap to modify selected date',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.edit_calendar_rounded, size: 20, color: AppColors.royalGold),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Step 2: Time Slot / Session
            const Text(
              '2. Select Event Session',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryPlum,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: _timeSlots.map((slot) {
                final isSelected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.plumTint : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryPlum : AppColors.borderLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: isSelected ? AppColors.primaryPlum : AppColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryPlum : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Step 3: Estimated Guest Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3. Estimated Guests',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPlum,
                  ),
                ),
                Text(
                  '$_guestCount Guests',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryPlum,
                      inactiveTrackColor: AppColors.plumTint,
                      thumbColor: AppColors.royalGold,
                      overlayColor: AppColors.royalGold.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _guestCount.toDouble(),
                      min: 100,
                      max: 2500,
                      divisions: 24,
                      onChanged: (val) {
                        setState(() => _guestCount = val.toInt());
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('100 (Intimate)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      const Text('1000 (Grand)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      const Text('2500+ (Palatial)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step 4: Special Instructions
            const Text(
              '4. Custom Requests & Notes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryPlum,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Traditional banana leaf preferred, early room check-in, drone photography permits...',
              ),
            ),
            const SizedBox(height: 24),

            // Pricing Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.goldBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimate Breakdown',
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
                      Text('${_currentPackage.name} Base', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text(currencyFormatter.format(basePrice), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Event Coordination & Booking Fee', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text(currencyFormatter.format(coordinatorFee), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                        'Total Estimated Investment',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        currencyFormatter.format(grandTotal),
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

            // Submit Button
            LuxuryButton(
              text: 'Confirm Booking Request',
              isLoading: _isSubmitting,
              isGold: true,
              icon: Icons.check_circle_outline_rounded,
              onPressed: _confirmBooking,
            ),
          ],
        ),
      ),
    );
  }
}
