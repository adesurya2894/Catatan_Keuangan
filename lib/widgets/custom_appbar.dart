import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.teal,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      leading: GestureDetector(
        onTap: () {
          // Navigasi ke HomePage jika belum di sana
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo-catke.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
