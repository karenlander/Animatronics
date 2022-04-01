import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> _moves =
  List.generate(100, (index) => "Move ${index.toString()}");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: primaryOrange(),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: [
                newText(27, Colors.white, "My moves", false, true),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:20.0),
        child: ReorderableListView.builder(
            itemCount: _moves.length,
            itemBuilder: (context, index) {
              final String movesName = _moves[index];
              return Card(
                key: ValueKey(movesName),
                color: primaryPink(),
                elevation: 1,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(25),
                  title: Text(
                    movesName,
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: const Icon(
                    Icons.open_in_full_rounded,
                  ),
                  leading:  CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.visibility_rounded,
                      color: lightPink()
                    ),
                    backgroundColor: darkPink(),
                  ),
                  onTap: () {/* Do something else */},
                ),
              );
            },
            // The reorder function
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex = newIndex - 1;
                }
                final element = _moves.removeAt(oldIndex);
                _moves.insert(newIndex, element);
              });
            }),
      ),
    );
  }
}

