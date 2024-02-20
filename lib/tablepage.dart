import 'package:flutter/material.dart';

class TablePage extends StatelessWidget {
  TablePage({Key? key}) : super(key: key);

  final List<String> _items = [
    'https://picsum.photos/250?image=21',
    'https://picsum.photos/250?image=22',
    'https://picsum.photos/250?image=23',
    'https://picsum.photos/250?image=24',
    'https://picsum.photos/250?image=25',
    'https://picsum.photos/250?image=26',
    'https://picsum.photos/250?image=27',
    'https://picsum.photos/250?image=28',
    'https://picsum.photos/250?image=29',
    'https://picsum.photos/250?image=30',
    'https://picsum.photos/250?image=31',
    'https://picsum.photos/250?image=32',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return Image.network(
            _items[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
