import 'package:flutter/material.dart';
import 'package:interview_app/provider/movie_provider.dart';
import 'package:provider/provider.dart';
import '../screens/movie_detail_page.dart';

class MovieList extends StatefulWidget {
  const MovieList({super.key});

  @override
  State<MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load movies when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).loadMovies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (movieProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error Icon
                  Icon(
                    movieProvider.isNetworkError 
                        ? Icons.wifi_off_rounded 
                        : Icons.error_outline_rounded,
                    size: 64,
                    color: movieProvider.isNetworkError 
                        ? Colors.orange 
                        : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  
                  // Error Title
                  Text(
                    movieProvider.isNetworkError 
                        ? 'Connection Problem' 
                        : 'Something Went Wrong',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Error Message
                  Text(
                    movieProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Retry Button
                  ElevatedButton.icon(
                    onPressed: () => movieProvider.retryLoadMovies(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  
                  // Additional help text for network errors
                  if (movieProvider.isNetworkError) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Please check your internet connection',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        } else if (movieProvider.movies.isEmpty && movieProvider.searchQuery.isEmpty) {
          return const Center(child: Text('No movies found'));
        } else {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: movieProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              movieProvider.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    movieProvider.searchMovies(value);//search function
                  },
                ),
              ),
              // Movies List with Pull-to-Refresh
              Expanded(
                child: movieProvider.movies.isEmpty && movieProvider.searchQuery.isNotEmpty
                    ? const Center(child: Text('No movies found for your search'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          movieProvider.retryLoadMovies();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: movieProvider.movies.length,
                          itemBuilder: (context, index) {
                            final movie = movieProvider.movies[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailPage(movie: movie),
                                    ),
                                  );
                                },
                                leading: movie.imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                          movie.imageUrl,
                                          width: 50,
                                          height: 75,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.movie, size: 50);
                                          },
                                        ),
                                      )
                                    : const Icon(Icons.movie, size: 50),
                                title: Text(
                                  movie.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(' ${movie.rating}'),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.calendar_today, size: 16),
                                        Text(' ${movie.releaseDate}'),
                                      ],
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
                ),
              ],
            );
        }
      },
    );
  }
}