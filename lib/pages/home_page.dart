import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:catatan_keuangan/services/transaction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_buttom_nav.dart';
import '../models/transaction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showFabOptions = false;
  List<TransactionModel> _riwayatUser = [];
  bool _isLoading = true;
  double _pemasukan = 0;
  double _pengeluaran = 0;

  int get selisih => (_pemasukan - _pengeluaran).toInt();
  final formatter =
      NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
  final monthYearFormatter = DateFormat('MMMM yyyy', 'id');

  @override
  void initState() {
    super.initState();
    _loadTransaksi();
  }

  Future<void> _loadTransaksi() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      try {
        final allTransactions = await TransactionService.fetchByUserId(userId);

        final now = DateTime.now();
        final filtered = allTransactions.where((t) {
          final date = DateTime.parse(t.tanggal);
          return date.month == now.month && date.year == now.year;
        }).toList();

        double pemasukan = 0;
        double pengeluaran = 0;

        for (var t in filtered) {
          if (t.jumlah >= 0) {
            pemasukan += t.jumlah;
          } else {
            pengeluaran += t.jumlah.abs();
          }
        }

        setState(() {
          _riwayatUser = filtered.take(10).toList();
          _pemasukan = pemasukan;
          _pengeluaran = pengeluaran;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showInputDialog(String tipe) {
    final _jumlahController = TextEditingController();
    final _keteranganController = TextEditingController();

    final List<String> kategoriPemasukan = [
      'Gaji',
      'Investasi',
      'Lainnya',
    ];

    final List<String> kategoriPengeluaran = [
      'Makan',
      'Belanja',
      'Transportasi',
      'Kesehatan',
      'Pendidikan',
      'Hiburan',
      'Tagihan',
      'Lainnya',
    ];

    final List<String> kategoriList =
        tipe == 'pemasukan' ? kategoriPemasukan : kategoriPengeluaran;

    String? _selectedKategori;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            tipe == 'pemasukan' ? 'Tambah Pemasukan' : 'Tambah Pengeluaran'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: kategoriList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) => _selectedKategori = val!,
              ),
              TextField(
                controller: _jumlahController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _keteranganController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final jumlah = double.tryParse(_jumlahController.text) ?? 0;
              final keterangan = _keteranganController.text.trim();

              if (_selectedKategori == null || jumlah <= 0) return;

              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString('user_id');

              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID tidak ditemukan')),
                );
                return;
              }

              final transaksi = TransactionModel(
                userId: userId,
                kategori: _selectedKategori!,
                jumlah: tipe == 'pengeluaran' ? -jumlah : jumlah,
                keterangan: keterangan,
                tipe: tipe,
                tanggal: DateTime.now().toIso8601String(),
              );

              final success =
                  await TransactionService.createTransaction(transaksi);

              if (!mounted) return;
              Navigator.pop(ctx);

              if (success) {
                _loadTransaksi();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil disimpan')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal menyimpan transaksi')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(TransactionModel transaksi) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(transaksi.kategori),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jumlah: ${formatter.format(transaksi.jumlah)}',
                  style: TextStyle(
                      color: transaksi.jumlah >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Tanggal: ${DateFormat('dd MMM yyyy – HH:mm').format(DateTime.parse(transaksi.tanggal))}',
              ),
              const SizedBox(height: 8),
              Text('Keterangan: ${transaksi.keterangan}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus transaksi ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final success =
                      await TransactionService.deleteTransaction(transaksi.id!);
                  if (!context.mounted) return;

                  Navigator.pop(context); // Tutup detail modal
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(success ? 'Transaksi dihapus' : 'Gagal menghapus'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                  _loadTransaksi(); // Refresh data
                }
              },
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text('Hapus', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final ringkasanLabel = 'Ringkasan ${monthYearFormatter.format(now)}';
    final riwayatLabel = 'Riwayat ${monthYearFormatter.format(now)}';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Catatan Keuangan'),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ringkasanLabel,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.green.withOpacity(0.05),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pemasukan',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formatter.format(_pemasukan),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red.withOpacity(0.05),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pengeluaran',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "-" + formatter.format(_pengeluaran),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.green.withOpacity(0.05),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selisih',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formatter.format(selisih),
                                      style: TextStyle(
                                        color: selisih >= 0
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(riwayatLabel,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _riwayatUser.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data transaksi bulan ini'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _riwayatUser.length,
                          itemBuilder: (context, index) {
                            final item = _riwayatUser[index];
                            final isPemasukan = item.jumlah >= 0;
                            return ListTile(
                              onTap: () => _showDetailDialog(item),
                              leading: Icon(
                                isPemasukan
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isPemasukan ? Colors.green : Colors.red,
                              ),
                              title: Text(item.kategori),
                              subtitle: Text(DateFormat('dd MMM yyyy – HH:mm')
                                  .format(DateTime.parse(item.tanggal))),
                              trailing: Text(
                                formatter.format(item.jumlah.abs()),
                                style: TextStyle(
                                  color:
                                      isPemasukan ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showFabOptions) ...[
            FloatingActionButton.extended(
              heroTag: 'pemasukan',
              onPressed: () {
                _showInputDialog('pemasukan');
                setState(() => _showFabOptions = false);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Pemasukan',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              heroTag: 'pengeluaran',
              onPressed: () {
                _showInputDialog('pengeluaran');
                setState(() => _showFabOptions = false);
              },
              icon: const Icon(Icons.remove, color: Colors.white),
              label: const Text('Pengeluaran',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            onPressed: () => setState(() => _showFabOptions = !_showFabOptions),
            child: Icon(_showFabOptions ? Icons.close : Icons.add,
                color: Colors.white),
            backgroundColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionButton(
      {super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal.shade100,
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
