import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_buttom_nav.dart';

class RiwayatDetailPage extends StatefulWidget {
  final String title;
  final List<TransactionModel> transactions;

  const RiwayatDetailPage({
    super.key,
    required this.title,
    required this.transactions,
  });

  @override
  State<RiwayatDetailPage> createState() => _RiwayatDetailPageState();
}

class _RiwayatDetailPageState extends State<RiwayatDetailPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy - HH:mm');
    final currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      drawer: const CustomDrawer(),
      body: ListView.builder(
        itemCount: widget.transactions.length,
        itemBuilder: (context, index) {
          final item = widget.transactions[index];
          final isPemasukan = item.jumlah >= 0;
          return ListTile(
            leading: Icon(
              isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
              color: isPemasukan ? Colors.green : Colors.red,
            ),
            title: Text(item.kategori),
            subtitle: Text(formatter.format(DateTime.parse(item.tanggal))),
            trailing: Text(
              currencyFormatter.format(item.jumlah.abs()),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPemasukan ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }
}
