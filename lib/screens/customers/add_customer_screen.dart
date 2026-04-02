// lib/screens/customers/add_customer_screen.dart
// Form to add a new customer

import 'package:flutter/material.dart';
import 'package:bookbaazar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  int _selectedAvatar = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final customer = Customer(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      avatarIndex: _selectedAvatar,
      createdAt: DateTime.now(),
    );

    await context.read<AppProvider>().addCustomer(customer);

    if (mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.customerSaved), backgroundColor: AppColors.primary),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.addNewCustomer),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l.addCustomerDetails, style: const TextStyle(
                      color: Colors.blue, fontSize: 13,
                    )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer name
                      Text('${l.customerName} *', style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14,
                      )),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: l.enterCustomerName,
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? l.nameRequired : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      Text('${l.phoneNumber} *', style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14,
                      )),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: l.enterPhoneNumber,
                          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? l.phoneRequired : null,
                      ),
                      const SizedBox(height: 6),
                      Text(l.usedForIdentification, style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12,
                      )),
                      const SizedBox(height: 16),

                      // Address
                      Text(l.addressOptional, style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14,
                      )),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: InputDecoration(
                          hintText: l.enterAddress,
                          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Avatar picker
                      Text(l.chooseAvatar, style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14,
                      )),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(avatarIcons.length, (i) {
                          final isSelected = _selectedAvatar == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedAvatar = i),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.primaryLighter,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                    ? Border.all(color: AppColors.primary, width: 3) : null,
                                ),
                                child: Icon(
                                  avatarIcons[i],
                                  color: isSelected ? Colors.white : AppColors.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              label: l.saveCustomer,
              icon: Icons.check_circle_outline,
              onPressed: _save,
              isLoading: _isSaving,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
