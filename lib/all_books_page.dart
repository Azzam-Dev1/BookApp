import 'package:flutter/material.dart';
import 'book_details_page.dart';
import 'home_page.dart';

class AllBooksPage extends StatelessWidget {
  final List<BookEntity> booklist;

  AllBooksPage({required this.booklist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Books'),
      ),
      body: ListView.builder(
        itemCount: booklist.length,
        itemBuilder: (context, index) {
          final book = booklist[index];
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
    );
  }
}
