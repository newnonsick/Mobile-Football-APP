import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const Divider(
          //   height: 1,
          //   thickness: 0.2,
          //   color: Colors.black,
          // ),
          const SizedBox(height: 7),
          Row(
            children: [
              const SizedBox(width: 15),
              _buildButton(
                Icons.sports_soccer,
                selectedIndex,
                onItemTapped,
                0,
              ),
              _buildButton(
                Icons.equalizer,
                selectedIndex,
                onItemTapped,
                1,
              ),
              _buildButton(
                Icons.person,
                selectedIndex,
                onItemTapped,
                2,
              ),
              const SizedBox(width: 15),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

Widget _buildButton(IconData icon, int selectedIndex,
    ValueChanged<int> onItemTapped, int index) {
  return Expanded(
    child: TextButton(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            return Colors.transparent;
          },
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Icon(icon,
              size: 30,
              color: selectedIndex == index ? Colors.pink[800] : Colors.grey),
          selectedIndex == index
              ? Icon(Icons.circle,
                  size: 7,
                  color:
                      selectedIndex == index ? Colors.pink[800] : Colors.grey)
              : Container(),
        ],
      ),
      onPressed: () => onItemTapped(index),
    ),
  );
}
