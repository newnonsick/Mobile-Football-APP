import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
                Icons.home,
                selectedIndex,
                onItemTapped,
                0,
              ),
              _buildButton(
                Icons.table_chart,
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
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return Colors.transparent;
          },
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
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
