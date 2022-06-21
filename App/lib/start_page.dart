import 'package:animatronics/firebase.dart';
import 'package:animatronics/set_ip.dart';
import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'information.dart';
import 'moves_screen.dart';
import 'package:lottie/lottie.dart';

class StartPage extends StatefulWidget {

  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: lightPink(),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          newIcon(Icons.info_outlined, 30, information, darkOrange()),
          newIcon(Icons.settings, 30, setIp, darkOrange()),
        ],
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(options: ParticleOptions( baseColor:primaryPink())),
        vsync: this,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Lottie.asset('lib/assets/doll.json',),
                animatronicsTittle('Animatronics', primaryOrange(), 59),
                const SizedBox(height: 140),
                newButton("Start", start),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void information(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Information()));
  }

  void setIp(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SetIp()));
  }

  void start(){
   //setNumOfMoves(0);
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MainScreen()));
  }
}