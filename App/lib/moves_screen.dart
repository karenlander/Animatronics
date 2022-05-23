
import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'edit_move_screen.dart';
import 'external/audio-recorder.dart';
import 'firebase.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool loadingFirebase = true;
  int numOfMoves = 0;
  late List<String> _moves;
  String totalDisplayTime = "";
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
    String totalAudiTime = await getTotalAudioTime();
    var parts = totalAudiTime.split(':');
    _stopWatchTimer.setPresetHoursTime(int.parse(parts[0]));
    _stopWatchTimer.setPresetMinuteTime(int.parse(parts[1]));
    _stopWatchTimer.setPresetSecondTime(int.parse(parts[2]));
    _moves = await getMovesOnFirebase();
  //  _moves =
    //    List.generate(
      //      numOfMoves, (index) => "Move ${(index + 1).toString()}");

    setState(() {
      loadingFirebase = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.radio_button_checked : Icons.radio_button_unchecked;

    Widget main;
    if (loadingFirebase) {
      loadingFirebase = false;
      main = Center(
        child: CircularProgressIndicator(color: darkOrange()),
      );
    } else {
      if(numOfMoves != _moves.length){
        _moves.add("Move ${(numOfMoves).toString()}");
        setMovesOnFirebase(numOfMoves, _moves);
      }
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
                    child: Dismissible(
                      direction: DismissDirection.endToStart,
                      key: Key(movesName),
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        child: const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        color: darkOrange(),
                      ),
                      onDismissed: (DismissDirection direction)  {
                        setState(() {
                          _moves.removeAt(index);
                          numOfMoves--;
                        });
                        setMovesOnFirebase(numOfMoves, _moves);
                      },
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
                            int parseMoveNumber = int.parse(_moves[index].split(' ')[1]);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => EditMove(moveNumber: parseMoveNumber)));
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
                    setMovesOnFirebase(numOfMoves, _moves);
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
            padding: const EdgeInsets.only(top: 30.0),
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

  Widget countdown(_stopWatchTimer, alignment) {
    return Align(
      alignment: alignment,
      child: TextButton(
          style: TextButton.styleFrom(
            primary: darkOrange(),
          ),
          onPressed: () {},
          child: StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: 0,
              builder: (context, snapshot) {
                final value = snapshot.data;
                totalDisplayTime = StopWatchTimer.getDisplayTime(value!,
                secondRightBreak: ":");
                return Text(totalDisplayTime,
                  style: TextStyle(
                      color: darkOrange(), fontFamily: 'Poppins', fontSize: 15),
                );
              }
          )),
    );
  }

  void playAndStop() async {
    final isRecording = await recorder.toggleRecording(numOfMoves + 1, false);
    setState(() {});
    if(recorder.isRecording){
      //we pressed record
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      getRequest("/record/");
    }else{
      //we pressed stop
      getRequest("/stop/");
      setTotalAudioTime(totalDisplayTime);
    }
  }

  Future<void> getRequest(String function) async {
    //TODO: change ip
    String stringUrl = "http://192.168.43.209" + function;
    Uri url = Uri.parse(stringUrl);
    await http.get(url);
  }


  void refresh() async {
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








