import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class TransactionService {
  static const String baseUrl =
      'https://6819c3361ac1155635063793.mockapi.io/api/v1/transactions';

  // Get all transactions
  static Future<List<TransactionModel>> fetchTransactions() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data transaksi');
    }
  }

  // Get transactions by userId
  static Future<List<TransactionModel>> fetchByUserId(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl?userId=$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      // Sort by tanggal descending
      final sorted = data.map((e) => TransactionModel.fromJson(e)).toList()
        ..sort((a, b) =>
            DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)));

      return sorted;
    } else {
      throw Exception('Gagal mengambil transaksi user');
    }
  }

  // Create new transaction
  static Future<bool> createTransaction(TransactionModel tx) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(tx.toJson()),
    );
    return response.statusCode == 201;
  }

  // Update transaction
  static Future<bool> updateTransaction(String id, TransactionModel tx) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(tx.toJson()),
    );
    return response.statusCode == 200;
  }

  // Delete transaction
  static Future<bool> deleteTransaction(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}
