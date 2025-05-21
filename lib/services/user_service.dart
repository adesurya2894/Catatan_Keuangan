import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class UserService {
  static const String baseUrl =
      'https://6819c3361ac1155635063793.mockapi.io/api/v1/users'; // ganti dengan endpoint asli kamu

  // CREATE - Tambah user baru
  static Future<bool> registerUser(UserModel user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    return response.statusCode == 201;
  }

  // READ - Ambil semua user
  static Future<List<UserModel>> fetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }

  // READ - Cek login berdasarkan email dan password
  static Future<UserModel?> login(String email, String password) async {
    final response = await http.get(Uri.parse('$baseUrl?email=$email'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      if (data.isNotEmpty && data[0]['password'] == password) {
        return UserModel.fromJson(data[0]);
      }
    }
    return null;
  }

  // UPDATE - Perbarui data user
  static Future<bool> updateUser(String id, UserModel user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    return response.statusCode == 200;
  }

  // DELETE - Hapus user
  static Future<bool> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final userData = data.firstWhere(
        (user) => user['email'] == email,
        orElse: () => null,
      );
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
    }
    return null;
  }
}
