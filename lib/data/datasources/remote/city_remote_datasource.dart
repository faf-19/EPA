import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/data/models/city_model.dart';

abstract class CityRemoteDataSource {
  Future<List<CityModel>> fetchCities();
}

class CityRemoteDataSourceImpl implements CityRemoteDataSource {
  final Dio dio;
  final GetStorage storage;

  CityRemoteDataSourceImpl({
    required this.dio,
    GetStorage? storage,
  }) : storage = storage ?? GetStorage();

  @override
  Future<List<CityModel>> fetchCities() async {
    try {
      final token = storage.read('auth_token');
      final response = await dio.get(
        ApiConstants.citiesEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Cities API Response: ${response.data}');
      print('Cities API Response Status Code: ${response.statusCode}');
      print('Cities API Response Type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
          print('✓ Cities data is a direct List with ${data.length} items');
        } else if (response.data is Map && response.data['cities'] is List) {
          data = response.data['cities'];
          print('✓ Cities data found in "cities" key with ${data.length} items');
        } else if (response.data is Map && response.data['data'] is List) {
          data = response.data['data'];
          print('✓ Cities data found in "data" key with ${data.length} items');
        } else {
          print('✗ Unexpected response format. Available keys: ${(response.data as Map).keys.toList()}');
          throw Exception('Unexpected response format');
        }
        
        print('Raw cities data: $data');
        
        final citiesList = data.map((e) => CityModel.fromJson(e)).toList();
        
        print('=== PARSED CITIES (${citiesList.length} total) ===');
        for (var i = 0; i < citiesList.length; i++) {
          final city = citiesList[i];
          print('City $i: id=${city.id}, name=${city.name}, description=${city.description ?? "N/A"}');
        }
        print('=== END CITIES LIST ===');
        
        return citiesList;
      } else {
        throw Exception(
          response.data['message'] ??
              response.data['error'] ??
              'Failed to load cities',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        throw Exception(
          e.response?.data['message'] ??
              e.response?.data['error'] ??
              'Failed to load cities',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load cities: $e');
    }
  }
}

