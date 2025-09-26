
import 'package:dio/dio.dart';
import 'package:interview_app/models/movie_model.dart';

class ImdbApi {
  final Dio _dio = Dio();

  ImdbApi() {
    // Configure Dio with timeout settings
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  Future<List<MovieModel>> fetchMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        'https://api.themoviedb.org/3/trending/movie/week?api_key=7089b375ee238e5d7fca81def7c5b1be&page=$page'
      );

      if (response.statusCode == 200) {
        // The API returns a Map with 'results' key containing the list of movies
        Map<String, dynamic> data = response.data;
        List<dynamic> moviesList = data['results'] ?? [];
        
        return moviesList.map((movie) => MovieModel(
          title: movie['title'] ?? 'Unknown Title',
          description: movie['overview'] ?? 'No description available',
          imageUrl: movie['poster_path'] != null 
              ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
              : '',
          releaseDate: movie['release_date'] ?? 'Unknown',
          rating: movie['vote_average']?.toString() ?? '0',
        )).toList();
      } else {
        throw ApiException('Server returned status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle specific Dio errors
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw NetworkException('Connection timeout. Please check your internet connection and try again.');
        case DioExceptionType.connectionError:
          throw NetworkException('No internet connection. Please check your network settings.');
        case DioExceptionType.badResponse:
          throw ApiException('Server error: ${e.response?.statusCode}');
        case DioExceptionType.cancel:
          throw NetworkException('Request was cancelled.');
        default:
          throw NetworkException('Network error occurred. Please try again.');
      }
    } catch (e) {
      // Handle any other unexpected errors
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }
}

// Custom exception classes for better error handling
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}