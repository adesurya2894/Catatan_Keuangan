class TransactionModel {
  final String? id;
  final String userId;
  final String tipe; // "pemasukan" atau "pengeluaran"
  final String kategori;
  final double jumlah;
  final String keterangan;
  final String tanggal;

  TransactionModel({
    this.id,
    required this.userId,
    required this.tipe,
    required this.kategori,
    required this.jumlah,
    required this.keterangan,
    required this.tanggal,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['userId'],
      tipe: json['tipe'],
      kategori: json['kategori'],
      jumlah: (json['jumlah'] as num).toDouble(),
      keterangan: json['keterangan'],
      tanggal: json['tanggal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tipe': tipe,
      'kategori': kategori,
      'jumlah': jumlah,
      'keterangan': keterangan,
      'tanggal': tanggal,
    };
  }
}
