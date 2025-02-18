import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marhba_bik/api/firestore_service.dart';

class ApiService {
  late String _apiUrlCommission;
  late String _apiUrlTransfer;
  late String _authToken;
  bool _isInitialized = false;

  ApiService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final config = await FirestoreService().fetchPaymentConfig();
      _apiUrlCommission = config['link-commession']!;
      _apiUrlTransfer = config['link-transfer']!;
      _authToken = config['public-key']!;
      _isInitialized = true;
      //print(_apiUrlCommission);
      //print(_apiUrlTransfer);
      //print(_authToken);
    } catch (e) {
      throw Exception('Failed to initialize API service: $e');
    }
  }

  Future<Map<String, dynamic>> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
    return {};
  }

  Future<Map<String, dynamic>> calculateCommission(double amount) async {
    await _ensureInitialized(); // Ensure initialization
    try {
      final response = await http.post(
        Uri.parse(_apiUrlCommission),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == 1) {
          return {
            'success': true,
            'amount': data['amount'],
            'commission': data['commission'],
          };
        } else {
          throw Exception('Failed to calculate commission: ${data['message']}');
        }
      } else {
        throw Exception(
            'Failed to calculate commission: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to calculate commission: $e');
    }
  }

  Future<Map<String, dynamic>> createTransfer(
      double amount, String contact) async {
    await _ensureInitialized(); // Ensure initialization
    //print('Contact value before transfer: $contact');
    try {
      if (contact.isEmpty) {
        throw Exception('Please select a valid contact');
      }

      final body = jsonEncode({
        'amount': amount,
        'contacte': contact,
      });

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(_apiUrlTransfer),
        headers: headers,
        body: body,
      );

      // Log detailed request and response information
      //print('Request Headers: $headers');
      //print('Request Body: $body');
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == 1) {
          return {
            'success': true,
            'message': data['message'],
            'id': data['id'],
            'url': data['url'],
          };
        } else {
          throw Exception('Failed to create transfer: ${data['message']}');
        }
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw Exception('Failed to create transfer: ${data['message']}');
      } else {
        throw Exception('Failed to create transfer: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to create transfer: $e');
    }
  }

  Future<Map<String, dynamic>> getTransferDetails(String transferId) async {
    await _ensureInitialized(); // Ensure initialization
    final url = '$_apiUrlTransfer/$transferId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == 1,
          'completed': data['completed'] == 1,
          'data': data['data'],
        };
      } else {
        throw Exception(
            'Failed to fetch transfer details: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to fetch transfer details: $e');
    }
  }
}
