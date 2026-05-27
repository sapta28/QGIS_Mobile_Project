import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme.dart';
import '../../../../models/models.dart';
import '../controllers/activity_controller.dart';

class ActivityDetailView extends StatefulWidget {
  const ActivityDetailView({super.key, required this.booking});

  final BookingModel booking;

  @override
  State<ActivityDetailView> createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ActivityController get _controller => Get.find<ActivityController>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _cancelBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('Booking akan dibatalkan dan status akan diperbarui.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final success = await _controller.cancelActivity(
      activityId: widget.booking.id,
      cancelReason: _reasonController.text.trim(),
    );

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                booking.billboard.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              booking.billboard.name,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.billboard.location} • ${booking.billboard.city}',
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Status',
              value: (booking.rawStatus ?? booking.status).toUpperCase().replaceAll('_', ' '),
            ),
            _InfoRow(label: 'Reference', value: booking.referenceId),
            _InfoRow(
              label: 'Period',
              value:
                  '${booking.startDate.toLocal().toIso8601String().split('T').first} → ${booking.endDate.toLocal().toIso8601String().split('T').first}',
            ),
            _InfoRow(label: 'Total Price', value: 'Rp ${booking.totalPrice.toStringAsFixed(0)}'),
            _InfoRow(label: 'Weekly Impressions', value: booking.weeklyImpressions.toString()),
            const SizedBox(height: 24),
            if (booking.status == 'pending' && booking.checkoutUrl != null && booking.checkoutUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final url = Uri.parse(booking.checkoutUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        Get.snackbar('Error', 'Could not launch payment URL');
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Pay Now / Bayar Sekarang'),
                  ),
                ),
              ),
            if (booking.status == 'pending' && booking.rawStatus != 'cancelled' && booking.rawStatus != 'pending_cancel')
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Cancel reason',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Reason is required';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
              ),
            if (booking.status == 'pending' && booking.rawStatus != 'cancelled' && booking.rawStatus != 'pending_cancel') const SizedBox(height: 16),
            if (booking.status == 'pending' && booking.rawStatus != 'cancelled' && booking.rawStatus != 'pending_cancel')
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: _controller.isSubmitting.value ? null : _cancelBooking,
                    child: _controller.isSubmitting.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Cancel Booking'),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
