import 'package:apdatdoan/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../utils/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      final updatedUser = User(
        id: user.id,
        email: _emailController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        avatar: user.avatar,
      );

      authProvider.updateUser(updatedUser as User).then((success) {
        if (success) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
          );
        }
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.profile)),
        body: Center(
          child: Text(
            'Chưa đăng nhập',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isEditing)
                Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: AppStrings.name),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(hintText: AppStrings.email),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(hintText: AppStrings.phone),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration:
                      InputDecoration(hintText: AppStrings.address_label),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Lưu'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _isEditing = false);
                              _initializeControllers();
                            },
                            child: const Text('Hủy'),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      label: 'Họ tên',
                      value: user.name,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      label: 'Email',
                      value: user.email,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      label: 'Số điện thoại',
                      value: user.phone ?? 'Chưa cập nhật',
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      label: 'Địa chỉ',
                      value: user.address ?? 'Chưa cập nhật',
                      icon: Icons.location_on,
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text(AppStrings.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
