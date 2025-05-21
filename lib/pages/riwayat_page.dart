import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_buttom_nav.dart';
import 'riwayat_detail_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  int _selectedIndex = 1;
  bool _isLoading = true;
  Map<String, List<TransactionModel>> _groupedByMonth = {};
  final formatter = DateFormat('dd MMM yyyy – HH:mm');
  final monthFormatter = DateFormat('MMMM yyyy', 'id');
  final currencyFormatter =
      NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadAllTransactions();
  }

  Future<void> _loadAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      final data = await TransactionService.fetchByUserId(userId);
      Map<String, List<TransactionModel>> grouped = {};

      for (var trans in data) {
        final dt = DateTime.parse(trans.tanggal);
        final key = monthFormatter.format(dt);
        grouped.putIfAbsent(key, () => []).add(trans);
      }

      setState(() {
        _groupedByMonth = grouped;
        _isLoading = false;
      });
    }
  }

  double _calculateSelisih(List<TransactionModel> transaksi) {
    double total = 0;
    for (var t in transaksi) {
      total += t.jumlah;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Riwayat Transaksi'),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedByMonth.isEmpty
              ? const Center(child: Text('Belum ada transaksi'))
              : ListView(
                  children: _groupedByMonth.entries.map((entry) {
                    final month = entry.key;
                    final transactions = entry.value;
                    final selisih = _calculateSelisih(transactions);
                    final isPositive = selisih >= 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          month,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          currencyFormatter.format(selisih),
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RiwayatDetailPage(
                                title: month,
                                transactions: transactions,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }
}
