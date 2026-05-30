import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/models.dart';
import '../controllers/activity_controller.dart';
import '../../explore/views/tripay_checkout_webview.dart';

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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Cancel booking?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Booking akan dibatalkan dan status akan diperbarui.',
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'No',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(
              'Yes, cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(
          'Activity Detail',
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _ActivityDetailStateScope(
        state: this,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    booking.billboard.imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                booking.billboard.name,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              _BookingTrackerCard(booking: booking),
              const SizedBox(height: 24),
              _PaymentActionsCard(booking: booking),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF059669),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${booking.billboard.location} • ${booking.billboard.city}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Status',
                      value: (booking.rawStatus ?? booking.status).toUpperCase().replaceAll('_', ' '),
                      valueColor: const Color(0xFF059669),
                    ),
                    _InfoRow(label: 'Reference', value: booking.referenceId),
                    _InfoRow(
                      label: 'Period',
                      value:
                          '${booking.startDate.toLocal().toIso8601String().split('T').first} → ${booking.endDate.toLocal().toIso8601String().split('T').first}',
                    ),
                    _InfoRow(
                      label: 'Total Price',
                      value: 'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                    ),
                    _InfoRow(
                      label: 'Weekly Impressions',
                      value: booking.weeklyImpressions.toString(),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (booking.status == 'pending' && booking.rawStatus != 'cancelled' && booking.rawStatus != 'pending_cancel')
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancellation',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reasonController,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Cancel reason',
                            labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Reason is required';
                            }
                            return null;
                          },
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              if (booking.status == 'pending' && booking.rawStatus != 'cancelled' && booking.rawStatus != 'pending_cancel') const SizedBox(height: 24),
              if (booking.status == 'pending' && booking.rawStatus != 'cancelled' && booking.rawStatus != 'pending_cancel')
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _controller.isSubmitting.value ? null : _cancelBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        disabledBackgroundColor: const Color(0xFFEF4444).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _controller.isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              'Cancel Booking',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCancelled(BookingModel booking) {
    final rawStatus = (booking.rawStatus ?? booking.status).toLowerCase();
    return rawStatus == 'cancelled' ||
        rawStatus == 'rejected' ||
        rawStatus == 'pending_cancel';
  }

  int _workflowCurrentStep(BookingModel booking) {
    final rawStatus = (booking.rawStatus ?? booking.status).toLowerCase();

    if (rawStatus.contains('cancel')) {
      return 0;
    }
    if (rawStatus == 'pending_payment') {
      return 0;
    }
    if (rawStatus == 'waiting_confirmation') {
      return 1;
    }
    if (rawStatus == 'pending_approval' ||
        rawStatus == 'waiting_approval' ||
        rawStatus == 'review') {
      return 2;
    }
    if (rawStatus == 'pending_final_payment' ||
        rawStatus == 'waiting_final_payment' ||
        rawStatus == 'final_payment_pending' ||
        rawStatus == 'pending_pelunasan') {
      return 3;
    }
    if (rawStatus == 'active' || rawStatus == 'completed' || rawStatus == 'ready_to_install') {
      return 4;
    }

    return booking.status == 'active' ? 4 : 0;
  }

  List<Step> _buildWorkflowSteps(BookingModel booking) {
    final currentStep = _workflowCurrentStep(booking);

    return [
      _buildWorkflowStep(
        title: 'Menunggu DP',
        subtitle: 'User memilih titik reklame dan menunggu pembayaran uang muka.',
        isActive: currentStep >= 0,
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      _buildWorkflowStep(
        title: 'DP Lunas',
        subtitle: 'Slot reklame terkunci dan booking resmi tercatat.',
        isActive: currentStep >= 1,
        state: currentStep > 1 ? StepState.complete : (currentStep == 1 ? StepState.indexed : StepState.disabled),
      ),
      _buildWorkflowStep(
        title: 'Menunggu Approval',
        subtitle: 'Admin meninjau desain dan menentukan revisi atau approve.',
        isActive: currentStep >= 2,
        state: currentStep > 2 ? StepState.complete : (currentStep == 2 ? StepState.indexed : StepState.disabled),
      ),
      _buildWorkflowStep(
        title: 'Menunggu Pelunasan',
        subtitle: 'Termin akhir diterbitkan sebelum eksekusi cetak dan pemasangan.',
        isActive: currentStep >= 3,
        state: currentStep > 3 ? StepState.complete : (currentStep == 3 ? StepState.indexed : StepState.disabled),
      ),
      _buildWorkflowStep(
        title: 'Ready to Install',
        subtitle: 'Pelunasan selesai dan pekerjaan lapangan dapat dimulai.',
        isActive: currentStep >= 4,
        state: currentStep >= 4 ? StepState.complete : StepState.disabled,
      ),
    ];
  }

  Step _buildWorkflowStep({
    required String title,
    required String subtitle,
    required bool isActive,
    required StepState state,
  }) {
    return Step(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
        ),
      ),
      content: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            height: 1.4,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
      isActive: isActive,
      state: state,
    );
  }
}

class _PaymentActionsCard extends StatelessWidget {
  const _PaymentActionsCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final paymentStatus = (booking.paymentStatus ?? '').toLowerCase();
    final isDownPaymentPending = paymentStatus.isEmpty ||
        paymentStatus == 'pending' ||
        paymentStatus == 'unpaid' ||
        paymentStatus == 'waiting';
    final isFinalPaymentPending = paymentStatus == 'dp_paid' ||
        paymentStatus == 'waiting_final_payment' ||
        paymentStatus == 'final_payment_pending' ||
        paymentStatus == 'pending_final_payment';

    final buttons = <Widget>[];
    if (isDownPaymentPending && (booking.checkoutUrl ?? '').isNotEmpty) {
      buttons.add(
        _PaymentButton(
          label: 'Bayar DP',
          subtitle: 'Buka pembayaran uang muka untuk mengunci slot.',
          color: const Color(0xFF059669),
          onTap: () => _openCheckout(context, booking.checkoutUrl!),
        ),
      );
    }
    if (isFinalPaymentPending && (booking.finalCheckoutUrl ?? '').isNotEmpty) {
      buttons.add(
        _PaymentButton(
          label: 'Bayar Pelunasan',
          subtitle: 'Lunasi sisa pembayaran sebelum eksekusi.',
          color: const Color(0xFF2563EB),
          onTap: () => _openCheckout(context, booking.finalCheckoutUrl!),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pembayaran Termin',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tombol akan muncul sesuai status termin yang tersedia dari backend.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          ...buttons.expand((widget) => [widget, const SizedBox(height: 12)]).toList()
            ..removeLast(),
        ],
      ),
    );
  }

  Future<void> _openCheckout(BuildContext context, String checkoutUrl) async {
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null) {
      Get.snackbar('Payment', 'Link pembayaran tidak valid.');
      return;
    }

    await Get.to(
      () => TriPayCheckoutWebView(
        checkoutUrl: uri.toString(),
        title: 'TriPay Payment',
      ),
      fullscreenDialog: true,
    );
  }
}

class _PaymentButton extends StatelessWidget {
  const _PaymentButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            const Icon(Icons.payments_outlined, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTrackerCard extends StatelessWidget {
  const _BookingTrackerCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final detailState = _ActivityDetailStateScope.of(context);
    final isCancelled = detailState._isCancelled(booking);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stacked_line_chart_rounded, color: Color(0xFF059669), size: 20),
              const SizedBox(width: 8),
              Text(
                'Tracker Pembayaran DP',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Skema booking diproses bertahap: DP, approval desain, pelunasan, lalu siap instalasi.',
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          if (isCancelled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Text(
                'Booking dibatalkan atau ditolak. Tracker dihentikan.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFBE123C),
                ),
              ),
            )
          else
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF059669),
                  onSurface: const Color(0xFF0F172A),
                ),
              ),
              child: Stepper(
                currentStep: detailState._workflowCurrentStep(booking).clamp(0, 4),
                type: StepperType.vertical,
                controlsBuilder: (context, details) => const SizedBox.shrink(),
                physics: const NeverScrollableScrollPhysics(),
                elevation: 0,
                connectorColor: MaterialStateProperty.all(const Color(0xFFD1D5DB)),
                steps: detailState._buildWorkflowSteps(booking),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityDetailStateScope extends InheritedWidget {
  const _ActivityDetailStateScope({
    required this.state,
    required super.child,
  });

  final _ActivityDetailViewState state;

  static _ActivityDetailViewState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ActivityDetailStateScope>();
    assert(scope != null, 'Activity detail state scope not found');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(covariant _ActivityDetailStateScope oldWidget) => false;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}