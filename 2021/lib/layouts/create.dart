import 'package:CodeNut/components/frame.dart';
import 'package:CodeNut/store/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatelessWidget {
  final TextEditingController ques = TextEditingController();
  final TextEditingController descip = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Consumer<Store>(
      builder: (context, store, child) {
        return Frame(<Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 10),
              child: Text(
                'Question',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent),
              )),
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              maxLines: 5,
              controller: ques,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 10),
              child: Text(
                'Description',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent),
              )),
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              maxLines: 10,
              controller: descip,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            height: 50.0,
            margin: EdgeInsets.all(20),
            child: RaisedButton(
              onPressed: () async {
                await store.createPost(ques.text, descip.text);
                store.globalSync();
                Navigator.pushNamedAndRemoveUntil(
                    context, "Home", (r) => false);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(0.0),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.greenAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0)),
                child: Container(
                  constraints:
                      BoxConstraints(maxWidth: width * 0.7, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Create",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}
