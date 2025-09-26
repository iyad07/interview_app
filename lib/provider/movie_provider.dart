import 'package:flutter/foundation.dart';
import 'package:interview_app/models/movie_model.dart';
import 'package:interview_app/services/Idmb_api.dart';

class MovieProvider extends ChangeNotifier {
  List<MovieModel> _movies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<MovieModel> get movies => _searchQuery.isEmpty ? _movies : _filteredMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<List<MovieModel>> getTrendingMovies() async {
    try {
      final movieList = await ImdbApi().fetchMovies();
      _movies = movieList;
      return _movies;
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  void loadMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final movieList = await ImdbApi().fetchMovies();
      _movies = movieList;
      _filteredMovies = movieList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
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