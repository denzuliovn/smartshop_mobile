// FILE PATH: lib/features/profile/presentation/screens/address_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartshop_mobile/core/mock_data/models.dart';
import 'package:smartshop_mobile/features/auth/application/auth_provider.dart';
import 'package:smartshop_mobile/features/profile/data/profile_repository.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập.")));
    }

    final addresses = authState.user.addresses;

    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ của tôi')),
      body: addresses.isEmpty
          ? const Center(child: Text("Bạn chưa có địa chỉ nào."))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  child: ListTile(
                    title: Text(address.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${address.address}, ${address.city}\n${address.phone}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (address.isDefault) const Chip(label: Text('Mặc định'), backgroundColor: Colors.green),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => context.push('/add-edit-address', extra: address),
                        ),
                      ],
                    ),
                    onTap: () async { // Đặt làm mặc định
                      if (!address.isDefault) {
                        try {
                          final updatedUser = await ref.read(profileRepositoryProvider).setDefaultAddress(address.id);
                          ref.read(authProvider.notifier).updateUserData(updatedUser);
                        } catch (e) { /* Handle error */ }
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-edit-address'),
        child: const Icon(Icons.add),
      ),
    );
  }
}