import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'book_reading_page.dart';

class BookDetailsPage extends StatefulWidget {
  final String bookTitle;
  final String imagePath;

  BookDetailsPage({required this.bookTitle, required this.imagePath});

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final TextEditingController _reviewController = TextEditingController();

  Future<void> _addReview(String review) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('books').doc(widget.bookTitle);

      await docRef.update({
        'reviews': FieldValue.arrayUnion([review]),
      });

      if (mounted) {
        setState(() {
          // Optionally update the UI or state
        });
      }
    } catch (e) {
      print('Error adding review: $e');
    }
  }

  Future<void> _addRating(double rating) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('books').doc(widget.bookTitle);

      await docRef.update({
        'ratings': FieldValue.arrayUnion([rating]),
      });

      // Recalculate the average rating and update the book's document
      DocumentSnapshot doc = await docRef.get();
      List<dynamic> ratings = doc['ratings'];
      double avgRating = ratings.fold(0.0, (sum, item) => sum + item) / ratings.length;

      await docRef.update({'avgRating': avgRating});

      if (mounted) {
        setState(() {
          // Use avgRating if needed
        });
      }
    } catch (e) {
      print('Error adding rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(widget.imagePath, height: 200),
              SizedBox(height: 20),
              Text(
                widget.bookTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'This is a detailed description of the book. It can be quite long and include many details about the book.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookReadingPage(bookTitle: widget.bookTitle),
                    ),
                  );
                },
                child: Text('Read Book'),
              ),
              SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('books')
                    .doc(widget.bookTitle)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    print('No data available');
                    return Text('No data available');
                  }

                  var bookData = snapshot.data!.data() as Map<String, dynamic>;
                  var reviews = bookData['reviews'] ?? [];
                  var ratings = bookData['ratings'] ?? [];
                  double avgRating = ratings.isEmpty
                      ? 0.0
                      : ratings.fold(0.0, (sum, item) => sum + item) / ratings.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      for (var review in reviews)
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(review),
                        ),
                      TextField(
                        controller: _reviewController,
                        decoration: InputDecoration(
                          labelText: 'Add a review',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_reviewController.text.isNotEmpty) {
                            _addReview(_reviewController.text);
                            _reviewController.clear();
                          }
                        },
                        child: Text('Submit Review'),
                      ),
                      SizedBox(height: 20),
                      Text('Average Rating: ${avgRating.toStringAsFixed(1)}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          _addRating(rating);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
