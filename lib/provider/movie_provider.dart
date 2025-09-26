import 'package:flutter/foundation.dart';
import 'package:interview_app/models/movie_model.dart';
import 'package:interview_app/services/Idmb_api.dart';

class MovieProvider extends ChangeNotifier {
  List<MovieModel> _movies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool _isNetworkError = false;

  List<MovieModel> get movies => _searchQuery.isEmpty ? _movies : _filteredMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get isNetworkError => _isNetworkError;

  Future<List<MovieModel>> getTrendingMovies() async {
    try {
      final movieList = await ImdbApi().fetchMovies();
      _movies = movieList;
      _error = null;
      _isNetworkError = false;
      return _movies;
    } on NetworkException catch (e) {
      _error = e.toString();
      _isNetworkError = true;
      return [];
    } on ApiException catch (e) {
      _error = e.toString();
      _isNetworkError = false;
      return [];
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isNetworkError = false;
      return [];
    }
  }

  void loadMovies() async {
    _isLoading = true;
    _error = null;
    _isNetworkError = false;
    notifyListeners();

    try {
      final movieList = await ImdbApi().fetchMovies();
      _movies = movieList;
      _filteredMovies = movieList;
      _error = null;
      _isNetworkError = false;
      _isLoading = false;
      notifyListeners();
    } on NetworkException catch (e) {
      _error = e.toString();
      _isNetworkError = true;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.toString();
      _isNetworkError = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isNetworkError = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void retryLoadMovies() {
    loadMovies();
  }

  void searchMovies(String query) {
    _searchQuery = query.toLowerCase();
    
    if (_searchQuery.isEmpty) {
      _filteredMovies = _movies;
    } else {
      _filteredMovies = _movies.where((movie) {
        return movie.title.toLowerCase().contains(_searchQuery) ||
               movie.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredMovies = _movies;
    notifyListeners();
  }
}