import 'package:flutter/material.dart';

class BookReadingPage extends StatelessWidget {
  final String bookTitle;

  BookReadingPage({required this.bookTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InteractiveViewer(
          panEnabled: true, 
          minScale: 1.0,
          maxScale: 5.0, 
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum..',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque vehicula augue at bibendum vehicula. Aenean venenatis purus nec turpis egestas, vel feugiat purus condimentum.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
