
import 'package:dio/dio.dart';
import 'package:interview_app/models/movie_model.dart';

class ImdbApi {
  Future<List<MovieModel>> fetchMovies() async {
    Dio dio = Dio();
    try {
      final response = await dio.get('https://api.themoviedb.org/3/trending/movie/week?api_key=7089b375ee238e5d7fca81def7c5b1be');

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
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      print('Error fetching movies: $e');
      throw e; // Re-throw the error so it can be handled by the provider
    }
  }
}