import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'edit_move_screen.dart';
import 'external/audio-recorder.dart';
import 'firebase.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool loadingFirebase = true;
  int numOfMoves = 0;
  late List<String> _moves;

  final recorder = SoundRecorder();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  void initState() {
    super.initState();
    recorder.init();
    recorder.setRefresh(refresh);
    loadMoves();
  }

  @override
  void dispose() {
    super.dispose();
    recorder.dispose();
    _stopWatchTimer.dispose();
  }

  void loadMoves() async {
    setState(() {
      loadingFirebase = true;
    });
    numOfMoves = await getNumOfMoves();
    setState(() {
      loadingFirebase = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.stop : Icons.play_arrow;

    Widget main;
    if (loadingFirebase) {
      loadingFirebase = false;
      main = Center(
        child: CircularProgressIndicator(color: darkOrange()),
      );
    } else {
      _moves =
          List.generate(
              numOfMoves, (index) => "Move ${(index + 1).toString()}");
      main = Column(
        children: [
          countdown(_stopWatchTimer, Alignment.centerRight),
          Expanded(
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
                          //writeFile("glove/move1",await readFile ("test/file/data"));
                          //writeFile("glove/move2",await readFile ("test/file/data"));
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EditMove(moveNumber: index + 1)));
                        },
                      ),
                      leading: CircleAvatar(
                        radius: 35,
                        child: Icon(
                          //TODO: image?
                            Icons.visibility_rounded,
                            color: lightPink()),
                        backgroundColor: darkPink(),
                      ),
                      onTap: () {},
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
        ],
      );
    }
    return Scaffold(
      floatingActionButton: FabWidget(),
      backgroundColor: lightPink(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: primaryOrange(),
          elevation: 0,
          actions: [
            newIcon(icon, 30, playAndStop, Colors.white),
          ],
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              children: [
                newText(27, Colors.white, "My moves", false, true),
              ],
            ),
          ),
        ),
      ),
      body: main,
    );
  }

  void playAndStop() async {
    final isRecording = await recorder.toggleRecording(numOfMoves + 1, false);
    setState(() {});
    if(recorder.isRecording){
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    }
  }

  void refresh() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    setState(() {
      numOfMoves = numOfMoves + 1;
    });
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
        child: Icon(Icons.send),
        backgroundColor: primaryOrange(),
        onPressed: () {});
  }

}








