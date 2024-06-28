import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiUrlCommission =
      'https://devapi.slick-pay.com/api/v2/users/transfers/commission';

  static const String _apiUrlTransfer =
      'https://devapi.slick-pay.com/api/v2/users/transfers';
  static const String _authToken =
      '1130|wKJymsDNwSpp6zebXH7KeYfVnmPREXuLUk0r6bvdbe059959';
//4369|G2oAPkJEOE7rozz6loHDUL1lu69FOyD5Fd6HIaNr ProdApi
  //1130|wKJymsDNwSpp6zebXH7KeYfVnmPREXuLUk0r6bvdbe059959 DevApi
  Future<Map<String, dynamic>> calculateCommission(double amount) async {
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
    print('Contact value before transfer: $contact');
    try {
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
      if (contact.isEmpty) {
        throw Exception('Please select a valid contact');
      }
      // Log detailed request and response information
      print('Request Headers: $headers');
      print('Request Body: $body');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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

  // method to get transfer details
  Future<Map<String, dynamic>> getTransferDetails(String transferId) async {
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
