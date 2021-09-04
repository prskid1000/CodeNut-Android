import 'dart:async';
import 'dart:convert';

import 'package:CodeNut/services/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Store extends ChangeNotifier {
  final Services scv = Services();

  String theme = 'dark';
  int selectedIndex = 0;

  String userId = "";
  String password = "";
  bool authenticated = false;

  List<dynamic> post;
  List<dynamic> user;
  Map<String, dynamic> current;

  Map<String, dynamic> sheet = new Map();

  var oneSec = const Duration(seconds: 10);
  Timer userTimer;

  void setTimer() {
    userTimer = new Timer.periodic(oneSec, (Timer t) => {globalSync()});
  }

  void stopTimer() {
    userTimer.cancel();
  }

  void toggleTheme(context) {
    if (this.theme.compareTo('dark') == 0) {
      this.theme = 'light';
    } else {
      this.theme = 'dark';
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme Changed to ' + this.theme)));
    notifyListeners();
  }

  void navigate(int data, BuildContext context) async {
    switch (data) {
      case 0:
        await globalSync();
        Navigator.pushNamedAndRemoveUntil(context, "Home", (r) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
            context, "Contributors", (r) => false);
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(context, "Create", (r) => false);
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, "Account", (r) => false);
        break;
      case 4:
        SystemNavigator.pop();
        break;
    }
    this.selectedIndex = data;
  }

  Future isAuth() async {
    if (await scv.isAuth(this.userId, this.password) == true) {
      this.authenticated = true;
      return true;
    } else {
      return false;
    }
  }

  void navPost(BuildContext context, Map<String, dynamic> current) async {
    this.current = current;
    print(this.current);
    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, "Post", (r) => false);
  }

  Future globalSync() async {
    var url = Uri.https(dotenv.env['SERVER'], '/getallpost');
    var response = await http.get(url);
    var decoded = json.decode(response.body);
    this.post = decoded['data'];

    url = Uri.https(dotenv.env['SERVER'], '/getalluser');
    response = await http.get(url);
    decoded = json.decode(response.body);
    this.user = decoded['data'];

    notifyListeners();
  }

  Future postSync() async {
    this.userId = userId;
    this.password = password;
    if (current == null) return;
    var url = Uri.https(dotenv.env['SERVER'], '/downvoteq');
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': current['question'],
      'author': current['author']
    });

    url = Uri.https(dotenv.env['SERVER'], '/upvoteq');
    response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': current['question'],
      'author': current['author']
    });
    var decoded = json.decode(response.body)['data'];

    this.current = decoded;
    notifyListeners();
  }

  Future addUser() async {
    var url = Uri.https(dotenv.env['SERVER'], '/adduser');
    var response = await http
        .post(url, body: {'userid': this.userId, 'password': this.password});
    var decoded = json.decode(response.body);
    notifyListeners();
  }

  Future upvoteq() async {
    var url = Uri.https(dotenv.env['SERVER'], '/upvoteq');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author']
    });
    await postSync();
    notifyListeners();
  }

  Future downvoteq() async {
    var url = Uri.https(dotenv.env['SERVER'], '/downvoteq');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author']
    });
    await postSync();
    notifyListeners();
  }

  Future upvotec(int idx) async {
    var url = Uri.https(dotenv.env['SERVER'], '/upvotec');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author'],
      'idx': idx.toString()
    });
    await postSync();
    notifyListeners();
  }

  Future downvotec(int idx) async {
    var url = Uri.https(dotenv.env['SERVER'], '/downvotec');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author'],
      'idx': idx.toString()
    });
    await postSync();
    notifyListeners();
  }

  Future deletePost(BuildContext context) async {
    var url = Uri.https(dotenv.env['SERVER'], '/deletepost');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author']
    });

    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, "Home", (r) => false);
  }

  Future savePost(BuildContext context, String nq, String nd) async {
    nq = (nq.isEmpty == true) ? this.current['question'] : nq;
    nd = (nd.isEmpty == true) ? this.current['description'] : nd;

    var url = Uri.https(dotenv.env['SERVER'], '/updatepost');
    var body = {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author'],
      'newdescription': nd,
      'newquestion': nq
    };

    var response = await http.post(url, body: body);
    await postSync();
    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, "Post", (r) => false);
  }

  Future addcomment(String com) async {
    var url = Uri.https(dotenv.env['SERVER'], '/createcomment');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author'],
      'comment': com
    });
    await postSync();
    notifyListeners();
  }

  Future deleteComment(int idx) async {
    var url = Uri.https(dotenv.env['SERVER'], '/deletecomment');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author'],
      'idx': idx.toString()
    });
    await postSync();
    notifyListeners();
  }

  Future saveComment(String comment, int idx) async {
    var url = Uri.https(dotenv.env['SERVER'], '/updatecomment');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'author': this.current['author'],
      'idx': idx.toString(),
      'newcomment': comment
    });
    await postSync();
    notifyListeners();
  }

  Future createPost(String q, String d) async {
    this.current = {'question': q, 'description': d, 'author': this.userId};
    var url = Uri.https(dotenv.env['SERVER'], '/createpost');
    var response = await http.post(url, body: {
      'userid': this.userId,
      'password': this.password,
      'question': this.current['question'],
      'description': this.current['description'],
      'author': this.userId
    });
    await postSync();
    notifyListeners();
  }

  List<Widget> postBuilder(BuildContext context) {
    List<Widget> wid = [];
    double width = MediaQuery.of(context).size.width;
    if (this.post == null) return [];
    for (int i = 0; i < this.post.length; i++) {
      wid.add(Card(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Container(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 15, 5, 15),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0))),
                            child: Container(
                                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: Row(children: [
                                  Text(
                                    "Votes ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.compareTo(('dark')) == 0
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  DecoratedBox(
                                      decoration: const BoxDecoration(
                                          color: Colors.red),
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: Text(
                                          this.post[i]['votes'],
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      )),
                                ]))),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0))),
                            child: Container(
                                padding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                                child: Row(children: [
                                  Text(
                                    "Author ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.compareTo(('dark')) == 0
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  DecoratedBox(
                                      decoration: const BoxDecoration(
                                          color: Colors.redAccent),
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(3, 3, 3, 3),
                                        child: Text(
                                          this.post[i]['author'],
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      )),
                                ]))),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      this.post[i]['question'],
                      style: new TextStyle(
                          color: theme.compareTo(('dark')) == 0
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      this.post[i]['description'],
                      style: new TextStyle(
                          color: theme.compareTo(('dark')) == 0
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 10, 10, 5),
                    child: RaisedButton(
                      onPressed: () async {
                        navPost(context, this.post[i]);
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
                              BoxConstraints(maxWidth: 100, minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text(
                            "View",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ));
    }
    return wid;
  }

  List<Widget> contribBuilder(BuildContext context) {
    List<Widget> wid = [];
    if (this.user == null) return [];
    for (int i = 0; i < this.user.length; i++) {
      wid.add(Card(
        child: ListTile(
            leading: Icon(Icons.adjust, color: Colors.black),
            title: Text(
              this.user[i]['userid'],
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            hoverColor: Colors.greenAccent,
            tileColor: Colors.green[300],
            trailing: InkWell(
              child: Text(
                this.user[i]['exp'],
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
            )),
      ));
    }
    return wid;
  }

  List<Widget> commentBuilder(BuildContext context) {
    List<Widget> wid = [];
    if (this.current == null) return [];
    for (int i = 0; i < this.current['comments'].length; i++) {
      final TextEditingController text = TextEditingController();
      wid.add(Card(
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 15, 5, 15),
                      child: DecoratedBox(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0))),
                          child: Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Row(children: [
                                Text(
                                  "Votes ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: theme.compareTo(('dark')) == 0
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.redAccent),
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(
                                        current['comments'][i]['votes'],
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )),
                              ]))),
                    )
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: DecoratedBox(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0))),
                          child: Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Row(children: [
                                Text(
                                  "Author ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: theme.compareTo(('dark')) == 0
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.redAccent),
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(
                                        current['comments'][i]['author'],
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )),
                              ]))),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                ),
                InkWell(
                  child: Icon(Icons.thumb_up, color: Colors.white, size: 28),
                  onTap: () {
                    upvotec(i);
                  },
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                ),
                InkWell(
                  child: Icon(Icons.thumb_down, color: Colors.white, size: 28),
                  onTap: () {
                    downvotec(i);
                  },
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      width: 290,
                      child: TextField(
                        maxLines: 3,
                        controller: text,
                        readOnly: (this.current['comments'][i]['author'] ==
                                this.userId)
                            ? false
                            : true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: current['comments'][i]['comment'],
                          hintStyle: TextStyle(
                              fontSize: 18,
                              color: this.theme.compareTo('dark') == 0
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                  ],
                ),
                Row(
                  children: [
                    (this.current['comments'][i]['author'] != this.userId)
                        ? Opacity(
                            opacity: 0,
                          )
                        : Container(
                            height: 60,
                            width: 160,
                            padding: EdgeInsets.fromLTRB(50, 0, 20, 20),
                            child: RaisedButton(
                              textColor: Colors.black,
                              color: Colors.greenAccent,
                              child: Text('Delete',
                                  style: TextStyle(fontSize: 19)),
                              onPressed: () => {deleteComment(i)},
                            )),
                    (this.current['comments'][i]['author'] == this.userId)
                        ? Container(
                            height: 60,
                            width: 110,
                            padding: EdgeInsets.fromLTRB(5, 0, 20, 20),
                            child: RaisedButton(
                                textColor: Colors.black,
                                color: Colors.greenAccent,
                                child: Text('Save',
                                    style: TextStyle(fontSize: 19)),
                                onPressed: () => {saveComment(text.text, i)}),
                          )
                        : Opacity(opacity: 0),
                  ],
                ),
              ],
            )
          ],
        ),
      ));
    }
    return wid;
  }
}
