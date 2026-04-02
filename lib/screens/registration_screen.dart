// lib/screens/registration_screen.dart
import 'package:flutter/material.dart';
import 'package:bookbaazar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/common_widgets.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Green header section ─────────────────────────────
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text('📦', style: TextStyle(fontSize: 34)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('BookBaazar', style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    )),
                    const SizedBox(height: 6),
                    const Text('Offline Inventory & Credit Tracker', style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    )),
                  ],
                ),
              ),

              // ── Form section ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Set up your shop', style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, letterSpacing: -0.3,
                      )),
                      const SizedBox(height: 4),
                      const Text('This takes less than a minute', style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14,
                      )),
                      const SizedBox(height: 24),

                      _inputField(
                        label: l.yourName,
                        controller: _nameCtrl,
                        hint: 'e.g. Siddhant',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        label: l.shopName,
                        controller: _shopCtrl,
                        hint: 'e.g. Siddhu General Store',
                        icon: Icons.storefront_outlined,
                        validator: (v) => v!.trim().isEmpty ? 'Shop name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        label: '${l.phone} (Optional)',
                        controller: _phoneCtrl,
                        hint: 'e.g. 9800000000',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),

                      PrimaryButton(
                        label: l.getStarted,
                        icon: Icons.arrow_forward_rounded,
                        isLoading: _isSaving,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '100% Offline — your data stays on your phone',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
        )),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await context.read<AppProvider>().register(
      _nameCtrl.text.trim(),
      _shopCtrl.text.trim(),
      _phoneCtrl.text.trim(),
    );
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
