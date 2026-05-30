import 'package:dio/dio.dart';

import 'api.dart';
import 'api_client.dart';

class UserApiService {
  UserApiService(this._client);

  final ApiClient _client;
  
  get _dio => null;

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _client.get(ApiEndpoints.userDashboardSummary);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getCategories() async {
    final response = await _client.get(ApiEndpoints.userCategories);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getSpots({
    double? lat,
    double? lng,
    int? radius,
    String? query,
  }) async {
    final params = <String, dynamic>{};
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (radius != null) params['radius'] = radius;
    if (query != null && query.isNotEmpty) params['q'] = query;

    final response = await _client.get(
      ApiEndpoints.userSpots,
      queryParameters: params.isEmpty ? null : params,
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getSpotDetail(String id) async {
    final response = await _client.get(ApiEndpoints.userSpotDetail(id));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> bookSpot({
    required String spotId,
    required String startDate,
    required String endDate,
    required String durationType,
    required int durationValue,
    String? paymentMethod,
    bool? uploadDesignLater,
    String? notes,
  }) async {
    final response = await _client.post(
      ApiEndpoints.userBookSpot(spotId),
      data: {
        'start_date': startDate,
        'end_date': endDate,
        'duration_type': durationType,
        'duration_value': durationValue,
        if (paymentMethod != null && paymentMethod.isNotEmpty) 'payment_method': paymentMethod,
        if (uploadDesignLater != null) 'upload_design_later': uploadDesignLater,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getActivities({String? status}) async {
    final response = await _client.get(
      ApiEndpoints.userActivities,
      queryParameters: status == null || status.isEmpty
          ? null
          : <String, dynamic>{'status': status},
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getActivityDetail(String id) async {
    final response = await _client.get(ApiEndpoints.userActivityDetail(id));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> cancelActivity({
    required String activityId,
    required String cancelReason,
  }) async {
    final response = await _client.patch(
      ApiEndpoints.userActivityCancel(activityId),
      data: {'cancel_reason': cancelReason},
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getCompanyDetail(String id) async {
    final response = await _client.get(ApiEndpoints.userCompanyDetail(id));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateCompany({
    required String id,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? npwp,
    String? nib,
  }) async {
    final payload = <String, dynamic>{};
    if (email != null && email.isNotEmpty) payload['email'] = email;
    if (phone != null && phone.isNotEmpty) payload['phone'] = phone;
    if (address != null && address.isNotEmpty) payload['address'] = address;
    if (city != null && city.isNotEmpty) payload['city'] = city;
    if (npwp != null && npwp.isNotEmpty) payload['npwp'] = npwp;
    if (nib != null && nib.isNotEmpty) payload['nib'] = nib;

    final response = await _client.patch(
      ApiEndpoints.userCompanyUpdate(id),
      data: payload,
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _client.get(ApiEndpoints.dashboardData);
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{'data': data};
  }

  /// Set reminder ketika billboard sedang di-hold oleh orang lain
  Future<Map<String, dynamic>> setBillboardReminder({
    required String billboardId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      // Pastikan endpoint ini sesuai dengan yang kita buat di routes/api.php Laravel (Route::post('/reminders', ...))
      final response = await _dio.post(
        '/reminders', 
        data: {
          'billboard_id': billboardId,
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      // Tangkap pesan error dari backend jika ada (misal: "Anda sudah terdaftar...")
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        throw Exception(e.response!.data['message'] ?? 'Gagal menyetel pengingat');
      }
      throw Exception('Terjadi kesalahan jaringan');
    } catch (e) {
      throw Exception('Gagal menyetel pengingat: $e');
    }
  }
}
