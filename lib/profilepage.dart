import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final List<String> _items = [
    'https://picsum.photos/250?image=33',
    'https://picsum.photos/250?image=34',
    'https://picsum.photos/250?image=35',
    'https://picsum.photos/250?image=36',
    'https://picsum.photos/250?image=37',
    'https://picsum.photos/250?image=38',
    'https://picsum.photos/250?image=39',
    'https://picsum.photos/250?image=40',
    'https://picsum.photos/250?image=41',
    'https://picsum.photos/250?image=42',
    'https://picsum.photos/250?image=43',
    'https://picsum.photos/250?image=44',
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
