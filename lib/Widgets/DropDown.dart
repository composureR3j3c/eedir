import 'package:flutter/material.dart';

const List<String> list = <String>['Cash', 'Telebirr', 'Wallet', 'Bank Transfer'];

class DropdownButtonCash extends StatefulWidget {
  const DropdownButtonCash({Key? key}) : super(key: key);
  @override
  State<DropdownButtonCash> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonCash> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.teal),
      underline: Container(
        height: 2,
        color: Colors.black54,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
