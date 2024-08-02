import 'package:flutter/material.dart';
import 'package:login_signup_demo/book_details_page.dart';

class BookCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double rating; // Add rating

  const BookCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating, // Add rating
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset('$imagePath'),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Row(
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 20),
              Text(rating.toString()), // Display rating
            ],
          ),
        ],
      ),
      trailing: Icon(Icons.forward),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(
              bookTitle: title,
              imagePath: '$imagePath',
            ),
          ),
        );
      },
    );
  }
}
