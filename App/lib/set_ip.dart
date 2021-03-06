import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'firebase.dart';

SnackBar get PuppetIpSaved =>
    const SnackBar(content: Text('Puppet ip updated'));
SnackBar get GloveIpSaved =>
    const SnackBar(content: Text('Glove ip updated'));

class SetIp extends StatefulWidget {
  const SetIp({Key? key}) : super(key: key);

  @override
  State<SetIp> createState() => _SetIpState();
}

class _SetIpState extends State<SetIp> {
  TextEditingController ipGloveController = TextEditingController();
  TextEditingController ipPuppetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink(),
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: primaryOrange(),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              children: [
                newText(27, Colors.white, "Set ip", false, true),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top:8),
                child: RichText(
                    text: TextSpan(
                        text: 'Enter the ip of the glove',
                        style: TextStyle(
                          color: primaryOrange(),
                          fontSize: 20,
                        ))),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                        cursorColor: darkOrange(),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:darkOrange()),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkOrange()),
                          ),
                        ),
                  controller: ipGloveController,
                ),
                    )),
                IconButton(
                  icon: Icon(Icons.save,
                    color: darkPink(),
                  ),
                  iconSize: 30,
                  onPressed: ()  {
                      setIp(ipGloveController.text, "Glove");
                      ScaffoldMessenger.of(context)
                          .showSnackBar(GloveIpSaved);
                  },
                ),
              ],
            ),
            SizedBox(height:20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top:8),
                child: RichText(
                    text: TextSpan(
                        text: 'Enter the ip of the puppet',
                        style: TextStyle(
                          color: primaryOrange(),
                          fontSize: 20,
                        ))),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:darkOrange()),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkOrange()),
                          ),
                        ),
                        cursorColor: darkOrange(),
                        controller: ipPuppetController,
                      ),
                    )),
                IconButton(
                  icon: Icon(Icons.save,
                    color: darkPink(),
                  ),
                  iconSize: 30,
                  onPressed: () async {
                    setIp(ipPuppetController.text, "Puppet");
                    ScaffoldMessenger.of(context)
                        .showSnackBar(PuppetIpSaved);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
