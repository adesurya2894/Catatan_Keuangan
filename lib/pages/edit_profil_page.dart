import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_appbar.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _avatarUrl = '';
  bool _isLoading = false;

  final List<String> avatarUrls = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=6',
    'https://i.pravatar.cc/150?img=7',
    'https://i.pravatar.cc/150?img=8',
    'https://i.pravatar.cc/150?img=9',
    'https://i.pravatar.cc/150?img=10',
    'https://i.pravatar.cc/150?img=11',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=13',
    'https://i.pravatar.cc/150?img=14',
    'https://i.pravatar.cc/150?img=15',
    'https://i.pravatar.cc/150?img=16',
    'https://i.pravatar.cc/150?img=17',
    'https://i.pravatar.cc/150?img=18',
    'https://i.pravatar.cc/150?img=19',
    'https://i.pravatar.cc/150?img=20',
    'https://i.pravatar.cc/150?img=21',
    'https://i.pravatar.cc/150?img=22',
    'https://i.pravatar.cc/150?img=23',
    'https://i.pravatar.cc/150?img=24',
    'https://i.pravatar.cc/150?img=25',
    'https://i.pravatar.cc/150?img=26',
    'https://i.pravatar.cc/150?img=27',
    'https://i.pravatar.cc/150?img=28',
    'https://i.pravatar.cc/150?img=29',
    'https://i.pravatar.cc/150?img=30',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('registered_name') ?? '';
      _emailController.text = prefs.getString('registered_email') ?? '';
      _phoneController.text = prefs.getString('registered_phone') ?? '';
      _avatarUrl = prefs.getString('profile_image') ?? '';
    });
  }

  Future<void> _pickAvatarSticker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Avatar'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: avatarUrls.map((url) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, url),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(url),
                  radius: 50,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _avatarUrl = selected;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final currentPassword = prefs.getString('registered_password') ?? '';

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    final userId = prefs.getString('user_id');
    if (userId != null) {
      final user = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        password: currentPassword,
        status: 'aktif',
        dateCreated: DateTime.now().toIso8601String(),
        avatar: _avatarUrl,
      );
      await UserService.updateUser(userId, user);
    }

    // Simpan ke lokal
    await prefs.setString('registered_name', name);
    await prefs.setString('registered_email', email);
    await prefs.setString('registered_phone', phone);
    await prefs.setString('profile_image', _avatarUrl);

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/home');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Profil'),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAvatarSticker,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                  child: _avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
