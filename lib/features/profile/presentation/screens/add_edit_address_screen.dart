// FILE PATH: lib/features/profile/presentation/screens/add_edit_address_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';
import 'package:smartshop_mobile/features/profile/data/profile_repository.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final Address? address; // null nếu là thêm mới
  const AddEditAddressScreen({super.key, this.address});

  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!.fullName;
      _phoneController.text = widget.address!.phone;
      _addressController.text = widget.address!.address;
      _cityController.text = widget.address!.city;
      _isDefault = widget.address!.isDefault;
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final messenger = ScaffoldMessenger.of(context);
      try {
        final addressData = {
          'fullName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'isDefault': _isDefault,
        };

        final User updatedUser;
        if (widget.address == null) {
          updatedUser = await ref.read(profileRepositoryProvider).addAddress(addressData);
        } else {
          updatedUser = await ref.read(profileRepositoryProvider).updateAddress(widget.address!.id, addressData);
        }

        ref.read(authProvider.notifier).updateUserData(updatedUser);
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(content: Text('Lưu địa chỉ thành công!'), backgroundColor: Colors.green));

      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.address == null ? 'Thêm địa chỉ mới' : 'Sửa địa chỉ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Họ và tên')),
            const SizedBox(height: 16),
            TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại'), keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Địa chỉ')),
            const SizedBox(height: 16),
            TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố')),
            SwitchListTile(
              title: const Text('Đặt làm địa chỉ mặc định'),
              value: _isDefault,
              onChanged: (val) => setState(() => _isDefault = val),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _onSave,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Lưu'),
            )
          ],
        ),
      ),
    );
  }
}