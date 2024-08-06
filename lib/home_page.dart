import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_signup_demo/profile_page.dart';
import 'book_details_page.dart';
import 'shared/widgets/book_cart.dart';
import 'all_books_page.dart'; // Import the new page

class BookEntity {
  final String imagePath;
  final String title;
  final String subtitle;
  final String genre; // Add genre field
  final double rating;

  BookEntity({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.genre,
    required this.rating,
  });
}

class HomePage extends StatefulWidget {
  final VoidCallback toggleThemeMode;

  HomePage({required this.toggleThemeMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  final TextEditingController _searchController = TextEditingController();
  List<BookEntity> booklist = [];
  List<BookEntity> searchResults = [];
  String selectedGenre = 'All';
  double selectedRating = 0.0;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/');
    }
    _fetchBooks();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchBooks() async {
    try {
      final snapshot = await _firestore.collection('books').get();
      setState(() {
        booklist = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          var ratings = List<double>.from(data['ratings'] ?? []);
          var averageRating = ratings.isEmpty
              ? 0.0
              : ratings.reduce((a, b) => a + b) / ratings.length;
          return BookEntity(
            imagePath: data['imagePath'],
            title: data['title'],
            subtitle: data['subtitle'],
            genre: data['genre'], // Fetch genre
            rating: averageRating,
          );
        }).toList();
        searchResults = booklist;
      });
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchResults = booklist.where((book) {
        return book.title
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  void _filterBooks() {
    setState(() {
      searchResults = booklist.where((book) {
        return (selectedGenre == 'All' || book.genre == selectedGenre) &&
               (book.rating >= selectedRating);
      }).toList();
    });
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Discover Latest Book',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              widget.toggleThemeMode();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search book...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.purple.withOpacity(0.1),
                  filled: true,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 20),
              if (_searchController.text.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search Results', style: TextStyle(fontSize: 18)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final book = searchResults[index];
                        return ListTile(
                          leading: Image.asset(book.imagePath),
                          title: Text(book.title),
                          subtitle: Text(book.subtitle),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailsPage(
                                  bookTitle: book.title,
                                  imagePath: book.imagePath,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('New & Trending', style: TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllBooksPage(booklist: booklist),
                            ),
                          );
                        },
                        child: Text('View All'),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            if (value == 'All') {
                              selectedGenre = 'All';
                            } else if (value == '4 and above') {
                              selectedRating = 4.0;
                            } else if (value == '3 and above') {
                              selectedRating = 3.0;
                            } else {
                              selectedGenre = value;
                              selectedRating = 0.0;
                            }
                            _filterBooks();
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'All',
                              child: Text('All Genres'),
                            ),
                            PopupMenuItem(
                              value: 'Action',
                              child: Text('Action'),
                            ),
                            PopupMenuItem(
                              value: 'Fairytale',
                              child: Text('Fairytale'),
                            ),
                            PopupMenuItem(
                              value: 'Mystery',
                              child: Text('Mystery'),
                            ),
                            PopupMenuItem(
                              value: 'Love, emotions',
                              child: Text('Love, emotions'),
                            ),
                            PopupMenuItem(
                              value: '4 and above',
                              child: Text('Rating: 4 and above'),
                            ),
                            PopupMenuItem(
                              value: '3 and above',
                              child: Text('Rating: 3 and above'),
                            ),
                          ];
                        },
                        icon: Icon(Icons.filter_list),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsPage(
                                bookTitle: 'The Color of You',
                                imagePath: 'assets/images/book1.png'),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset('assets/images/book1.png', height: 150),
                          Text('The Color of You'),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsPage(
                                bookTitle: 'Sending Some Love',
                                imagePath: 'assets/images/book2.png'),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset('assets/images/book2.png', height: 150),
                          Text('Sending Some Love'),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailsPage(
                                bookTitle: 'The Color of You',
                                imagePath: 'assets/images/book1.png'),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset('assets/images/book1.png', height: 150),
                          Text('The Color of You'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Popular', style: TextStyle(fontSize: 18)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final book = searchResults[index];
                  return BookCard(
                    imagePath: book.imagePath,
                    title: book.title,
                    subtitle: book.subtitle,
                    rating: book.rating,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.person),
      ),
    );
  }
}
