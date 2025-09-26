import 'package:flutter/foundation.dart';
import 'package:interview_app/models/movie_model.dart';
import 'package:interview_app/services/Idmb_api.dart';

class MovieProvider extends ChangeNotifier {
  List<MovieModel> _movies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  bool _isNetworkError = false;
  int _currentPage = 1;
  bool _hasMorePages = true;

  List<MovieModel> get movies => _searchQuery.isEmpty ? _movies : _filteredMovies;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get isNetworkError => _isNetworkError;
  bool get hasMorePages => _hasMorePages;

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
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();

    try {
      final movieList = await ImdbApi().fetchMovies(page: _currentPage);
      _movies = movieList;
      _filteredMovies = movieList;
      _error = null;
      _isNetworkError = false;
      _isLoading = false;
      
      // Check if we got fewer than 20 movies (typical page size), indicating no more pages
      if (movieList.length < 20) {
        _hasMorePages = false;
      }
      
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

  void loadMoreMovies() async {
    if (_isLoadingMore || !_hasMorePages || _searchQuery.isNotEmpty) return;
    
    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final moreMovies = await ImdbApi().fetchMovies(page: _currentPage);
      
      if (moreMovies.isNotEmpty) {
        _movies.addAll(moreMovies);
        if (_searchQuery.isEmpty) {
          _filteredMovies = _movies;
        }
        
        // Check if we got fewer than 20 movies, indicating no more pages
        if (moreMovies.length < 20) {
          _hasMorePages = false;
        }
      } else {
        _hasMorePages = false;
      }
      
      _isLoadingMore = false;
      notifyListeners();
    } on NetworkException catch (e) {
      _currentPage--; // Revert page increment on error
      _isLoadingMore = false;
      notifyListeners();
    } on ApiException catch (e) {
      _currentPage--; // Revert page increment on error
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _currentPage--; // Revert page increment on error
      _isLoadingMore = false;
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