import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'edit_move_screen.dart';
import 'file.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int numOfMoves = 0;
  late List<String> _moves;

  void initState() {
    super.initState();
    for(int i=1; i<=15; i++){
      numOfMoves++;
    }
    //TODO: make as many moves as in storage
    _moves = List.generate(100, (index) => "Move ${(index+1).toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FabWidget(),
      backgroundColor: lightPink(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: primaryOrange(),
          elevation: 0,
          actions: [
            newIcon(Icons.refresh, 30, refresh, Colors.white),
            //newIcon(Icons.refresh, 30, refresh, Colors.white),
           // newIcon(Icons.refresh, 30, refresh, Colors.white),
          ],
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
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
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
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.mode_edit,
                    ),
                    onPressed: () async {
                      writeFile("test2/file",await readFile ("test/file/data"));
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EditMove()));
                    },
                  ),
                  leading:  CircleAvatar(
                    radius: 35,
                    child:
                     Icon(
                       //TODO: image?
                        Icons.visibility_rounded,
                        color: lightPink()
                      ),
                    backgroundColor: darkPink(),
                  ),
                  onTap: () {
                  },
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

class FabWidget extends StatefulWidget {
  const FabWidget({Key? key}) : super(key: key);

  @override
  _FabWidgetState createState() => _FabWidgetState();
}

class _FabWidgetState extends State<FabWidget> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.play_arrow),
        backgroundColor: primaryOrange(),
        onPressed: (){

        }
    );
  }
}

void refresh(){

}

