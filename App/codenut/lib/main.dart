import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
        create: (context) => Store(),
        child: MaterialApp(
          theme: ThemeData.dark(),
          initialRoute: 'Account',
          routes: {
            'Account': (context) => Account(),
            'Message': (context) => Message(),
            'User': (context) => User(),
            'PostView': (context) => PostView(),
            'CreatePost': (context) => CreatePost(),
          },
          debugShowCheckedModeBanner: false,
        )),
  );
}

class Store extends ChangeNotifier {
  String userId = "";
  String password = "";
  int selectedIndex = 0;
  bool validUser = false;
  List<dynamic> post;
  List<dynamic> user;
  Map<String, dynamic> current;

  void navigate(int data, BuildContext context) async {
    switch (data) {
      case 0:
        await globalSync();
        notifyListeners();
        Navigator.pushNamedAndRemoveUntil(context, "Message", (r) => false);
        break;
      case 1:
        await globalSync();
        notifyListeners();
        Navigator.pushNamedAndRemoveUntil(context, "User", (r) => false);
        break;
      case 2:
        await globalSync();
        Navigator.pushNamedAndRemoveUntil(context, "CreatePost", (r) => false);
        break;
      case 3:
        SystemNavigator.pop();
        break;
    }
    this.selectedIndex = data;
  }

  void navpost(BuildContext context, String ques, String author) async {
    this.current = {'question': ques, 'author': author};
    await postSync();
    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, "PostView", (r) => false);
  }

  Future globalSync() async {
    var url = 'https://codenutb.herokuapp.com/getallpost';
    var response = await http.get(url);
    var decoded = json.decode(response.body);
    this.post = decoded['data'];

    url = 'https://codenutb.herokuapp.com/getalluser';
    response = await http.get(url);
    decoded = json.decode(response.body);
    this.user = decoded['data'];

    notifyListeners();
  }

  Future postSync() async {
    this.userId = userId;
    this.password = password;
    if (current == null) return;
    var url = 'https://codenutb.herokuapp.com/downvoteq';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': current['question'],
      'author': current['author']
    });
    url = 'https://codenutb.herokuapp.com/upvoteq';
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

  Future setAuth(String userId, String password) async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/isauth';
    var response =
        await http.post(url, body: {'userid': userId, 'password': password});
    var decoded = json.decode(response.body);

    if (decoded['success'].toString().compareTo("True") == 0) {
      this.validUser = true;
      const oneSec = const Duration(seconds: 10);
      new Timer.periodic(oneSec, (Timer t) async => await globalSync());
      new Timer.periodic(oneSec, (Timer t) async => await postSync());
    }
    notifyListeners();
  }

  Future addUser(String userId, String password) async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/adduser';
    var response =
        await http.post(url, body: {'userid': userId, 'password': password});
    var decoded = json.decode(response.body);
    print(decoded);
    if (decoded['success'].toString().compareTo("True") == 0) {
      this.validUser = true;
      const oneSec = const Duration(seconds: 10);
      new Timer.periodic(oneSec, (Timer t) async => await globalSync());
      new Timer.periodic(oneSec, (Timer t) async => await postSync());
    }
    notifyListeners();
  }

  void upvoteq() async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/upvoteq';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author']
    });

    notifyListeners();
  }

  void downvoteq() async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/downvoteq';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author']
    });

    notifyListeners();
  }

  void upvotec(int idx) async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/upvotec';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author'],
      'idx': idx.toString()
    });

    notifyListeners();
  }

  void downvotec(int idx) async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/downvotec';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author'],
      'idx': idx.toString()
    });

    notifyListeners();
  }

  void deletePost(BuildContext context) async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/deletepost';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author']
    });

    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, "Message", (r) => false);
  }

  void savePost(BuildContext context, String nq, String nd) async {
    this.userId = userId;
    this.password = password;

    print(nd.isEmpty);
    print(this.current['question']);

    nq = (nq.isEmpty == true) ? this.current['question'] : nq;
    nd = (nd.isEmpty == true) ? this.current['description'] : nd;

    var url = 'https://codenutb.herokuapp.com/updatepost';
    var body = {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author'],
      'newdescription': nd,
      'newquestion': nq
    };

    this.current['question'] = nq;
    this.current['description'] = nd;

    var response = await http.post(url, body: body);

    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, "PostView", (r) => false);
  }

  void addcomment(String com) async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/createcomment';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author'],
      'comment': com
    });

    notifyListeners();
  }

  void deleteComment(int idx) async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/deletecomment';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author'],
      'idx': idx.toString()
    });

    notifyListeners();
  }

  void saveComment(String comment, int idx) async {
    this.userId = userId;
    this.password = password;
    var url = 'https://codenutb.herokuapp.com/updatecomment';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'author': this.current['author'],
      'idx': idx.toString(),
      'newcomment': comment
    });

    notifyListeners();
  }

  void createPost(String q, String d) async {
    this.userId = userId;
    this.password = password;

    print(userId);
    print(password);

    this.current = {'question': q, 'description': d, 'author': userId};

    var url = 'https://codenutb.herokuapp.com/createpost';
    var response = await http.post(url, body: {
      'userid': userId,
      'password': password,
      'question': this.current['question'],
      'description': this.current['description'],
      'author': userId
    });
    print(response.body);
    notifyListeners();
  }

  List<Widget> postBuilder(BuildContext context) {
    List<Widget> wid = [];
    for (int i = 0; i < post.length; i++) {
      wid.add(Card(
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 15, 5, 15),
                      child: DecoratedBox(
                          decoration:
                              const BoxDecoration(color: Colors.redAccent),
                          child: Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Row(children: [
                                Text(
                                  "Votes ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.green),
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(
                                        post[i]['votes'],
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
                          decoration:
                              const BoxDecoration(color: Colors.redAccent),
                          child: Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Row(children: [
                                Text(
                                  "Author ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.green),
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(
                                        post[i]['author'],
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
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 300,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Click to View',
                          hintText: post[i]['question'],
                          hintStyle:
                              TextStyle(fontSize: 18, color: Colors.white),
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
                      padding: EdgeInsets.fromLTRB(5, 10, 10, 5),
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.green[600],
                        child: Text('Full View'),
                        onPressed: () {
                          navpost(
                              context, post[i]['question'], post[i]['author']);
                        },
                      ),
                    )
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

  List<Widget> contribBuilder(BuildContext context) {
    List<Widget> wid = [];
    for (int i = 0; i < user.length; i++) {
      wid.add(Card(
        child: ListTile(
            leading: Icon(Icons.adjust, color: Colors.black),
            title: Text(
              user[i]['userid'],
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            hoverColor: Colors.greenAccent,
            tileColor: Colors.green[300],
            trailing: InkWell(
              child: Text(
                user[i]['exp'],
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

  List<Widget> chatBuilder(BuildContext context) {
    final TextEditingController text = TextEditingController();
    List<Widget> wid = [];
    for (int i = 0; i < current['comments'].length; i++) {
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
                          decoration:
                              const BoxDecoration(color: Colors.redAccent),
                          child: Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Row(children: [
                                Text(
                                  "Votes ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.green),
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
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: DecoratedBox(
                          decoration:
                              const BoxDecoration(color: Colors.redAccent),
                          child: Container(
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Row(children: [
                                Text(
                                  "Author ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.green),
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
                      width: 300,
                      child: TextFormField(
                        controller: text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Click To Read",
                          hintText: current['comments'][i]['comment'],
                          hintStyle:
                              TextStyle(fontSize: 18, color: Colors.white),
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
                    Container(
                      height: 60,
                      width: 150,
                      padding: EdgeInsets.fromLTRB(50, 0, 20, 20),
                      child: Opacity(
                        opacity: (current['author'] == userId) ? 1 : 0,
                        child: RaisedButton(
                            textColor: Colors.white,
                            color: (current['author'] == userId)
                                ? Colors.green
                                : Colors.transparent,
                            child: (current['author'] == userId)
                                ? Text('Delete')
                                : Text(''),
                            onPressed:
                                (userId == current['comments'][i]['author'])
                                    ? () {
                                        deleteComment(i);
                                      }
                                    : () {
                                        ;
                                      }),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 110,
                      padding: EdgeInsets.fromLTRB(5, 0, 20, 20),
                      child: Opacity(
                          opacity: (current['author'] == userId) ? 1 : 0,
                          child: RaisedButton(
                              textColor: Colors.white,
                              color: (current['author'] == userId)
                                  ? Colors.green
                                  : Colors.transparent,
                              child: (current['author'] == userId)
                                  ? Text('Save')
                                  : Text(''),
                              onPressed:
                                  (userId == current['comments'][i]['author'])
                                      ? () {
                                          saveComment(text.text, i);
                                        }
                                      : () {
                                          ;
                                        })),
                    ),
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

class Account extends StatelessWidget {
  final TextEditingController text = TextEditingController();
  final TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(
      builder: (context, store, child) {
        return Scaffold(
            body: Padding(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'CodeNut',
                          style: TextStyle(fontSize: 36, color: Colors.green),
                        )),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        controller: text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'UserId',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextFormField(
                        obscureText: true,
                        controller: password,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                            height: 60,
                            width: 190,
                            padding: EdgeInsets.fromLTRB(40, 20, 10, 0),
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: Colors.green,
                              child: Text('Log In'),
                              onPressed: () async {
                                await store.setAuth(text.text, password.text);
                                if (store.validUser == true) {
                                  await store.globalSync();
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, "Message", (r) => false);
                                }
                              },
                            )),
                        Container(
                            height: 60,
                            width: 160,
                            padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: Colors.green,
                              child: Text('Sign Up'),
                              onPressed: () async {
                                await store.addUser(text.text, password.text);
                                if (store.validUser == true) {
                                  await store.globalSync();
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, "Message", (r) => false);
                                }
                              },
                            )),
                      ],
                    ),
                  ],
                )));
      },
    );
  }
}

class Message extends StatelessWidget {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(builder: (context, store, child) {
      return Scaffold(
          body: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: ListView(
                children: <Widget>[
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.markunread_mailbox_rounded,
                            color: Colors.greenAccent),
                        label: 'Posts',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.account_box, color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.edit, color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.exit_to_app, color: Colors.greenAccent),
                        label: '',
                      ),
                    ],
                    currentIndex: store.selectedIndex,
                    selectedItemColor: Colors.white,
                    onTap: (index) => {store.navigate(index, context)},
                  ),
                  Container(
                    height: 730,
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: ListView(
                      children: store.postBuilder(context),
                    ),
                  )
                ],
              )));
    });
  }
}

class User extends StatelessWidget {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(builder: (context, store, child) {
      return Scaffold(
          body: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: ListView(
                children: <Widget>[
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.markunread_mailbox_rounded,
                            color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.account_box, color: Colors.greenAccent),
                        label: 'Contributors',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.create, color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.exit_to_app, color: Colors.greenAccent),
                        label: '',
                      ),
                    ],
                    currentIndex: store.selectedIndex,
                    selectedItemColor: Colors.white,
                    onTap: (index) => {store.navigate(index, context)},
                  ),
                  Container(
                    height: 745,
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: ListView(
                      children: store.contribBuilder(context),
                    ),
                  )
                ],
              )));
    });
  }
}

class PostView extends StatelessWidget {
  final TextEditingController text3 = TextEditingController();
  final TextEditingController text4 = TextEditingController();
  final TextEditingController text5 = TextEditingController();
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(builder: (context, store, child) {
      return Scaffold(
          body: Padding(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
              child: ListView(
                children: <Widget>[
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.markunread_mailbox_rounded,
                            color: Colors.greenAccent),
                        label: 'Post',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.account_box, color: Colors.greenAccent),
                        label: 'Contributors',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.create, color: Colors.greenAccent),
                        label: 'Create',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.exit_to_app, color: Colors.greenAccent),
                        label: '',
                      ),
                    ],
                    currentIndex: store.selectedIndex,
                    selectedItemColor: Colors.white,
                    onTap: (index) => {store.navigate(index, context)},
                  ),
                  Container(
                    height: 270,
                    padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: ListView(
                      children: <Widget>[
                        Card(
                          color: Colors.black12,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 15, 5, 15),
                                        child: DecoratedBox(
                                            decoration: const BoxDecoration(
                                                color: Colors.redAccent),
                                            child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    7, 5, 5, 5),
                                                child: Row(children: [
                                                  Text(
                                                    "Votes ",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                  DecoratedBox(
                                                      decoration:
                                                          const BoxDecoration(
                                                              color:
                                                                  Colors.green),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                5, 0, 5, 0),
                                                        child: Text(
                                                          store
                                                              .current['votes'],
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
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
                                    child: Icon(Icons.thumb_up,
                                        color: Colors.white, size: 28),
                                    onTap: () {
                                      store.upvoteq();
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                                  ),
                                  InkWell(
                                    child: Icon(Icons.thumb_down,
                                        color: Colors.white, size: 28),
                                    onTap: () {
                                      store.downvoteq();
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 15, 5, 15),
                                        child: DecoratedBox(
                                            decoration: const BoxDecoration(
                                                color: Colors.redAccent),
                                            child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 5, 5, 5),
                                                child: Row(children: [
                                                  Text(
                                                    "Author ",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                  DecoratedBox(
                                                      decoration:
                                                          const BoxDecoration(
                                                              color:
                                                                  Colors.green),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                5, 0, 5, 0),
                                                        child: Text(
                                                          store.current[
                                                              'author'],
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      )),
                                                ]))),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 322,
                                        padding:
                                            EdgeInsets.fromLTRB(20, 10, 10, 10),
                                        child: TextFormField(
                                          controller: text4,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Question',
                                            hintText: store.current['question'],
                                            hintStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 322,
                                        padding:
                                            EdgeInsets.fromLTRB(20, 10, 10, 10),
                                        child: TextFormField(
                                          controller: text5,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Description',
                                            hintText:
                                                store.current['description'],
                                            hintStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              height: 60,
                              width: 190,
                              padding: EdgeInsets.fromLTRB(25, 10, 20, 10),
                              child: Opacity(
                                  opacity:
                                      (store.current['author'] == store.userId)
                                          ? 1
                                          : 0,
                                  child: RaisedButton(
                                      textColor: Colors.white,
                                      color: (store.current['author'] ==
                                              store.userId)
                                          ? Colors.green
                                          : Colors.transparent,
                                      child: (store.current['author'] ==
                                              store.userId)
                                          ? Text('Delete')
                                          : Text(''),
                                      onPressed: (store.userId ==
                                              store.current['author'])
                                          ? () {
                                              store.deletePost(context);
                                            }
                                          : () {
                                              ;
                                            })),
                            ),
                            Container(
                                height: 60,
                                width: 160,
                                padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                                child: Opacity(
                                    opacity: (store.current['author'] ==
                                            store.userId)
                                        ? 1
                                        : 0,
                                    child: RaisedButton(
                                        textColor: Colors.white,
                                        color: (store.current['author'] ==
                                                store.userId)
                                            ? Colors.green
                                            : Colors.transparent,
                                        child: (store.current['author'] ==
                                                store.userId)
                                            ? Text('Save')
                                            : Text(''),
                                        onPressed: (store.userId ==
                                                store.current['author'])
                                            ? () {
                                                store.savePost(context,
                                                    text4.text, text5.text);
                                              }
                                            : () {
                                                ;
                                              }))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
                      child: Text(
                        'Comments',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      )),
                  Container(
                    height: 250,
                    padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                    child: ListView(
                      children: store.chatBuilder(context),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Row(
                      children: [
                        Container(
                          width: 280,
                          child: TextFormField(
                            controller: text3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Message',
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: InkWell(
                              child: Icon(
                                Icons.send,
                                color: Colors.green,
                                size: 50,
                              ),
                              onTap: () {
                                store.addcomment(text3.text);
                              },
                            )),
                      ],
                    ),
                  ),
                ],
              )));
    });
  }
}

class CreatePost extends StatelessWidget {
  final TextEditingController ques = TextEditingController();
  final TextEditingController descip = TextEditingController();

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Consumer<Store>(builder: (context, store, child) {
      return Scaffold(
          body: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: ListView(
                children: <Widget>[
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.markunread_mailbox_rounded,
                            color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.account_box, color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.create, color: Colors.greenAccent),
                        label: 'Create',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.exit_to_app, color: Colors.greenAccent),
                        label: '',
                      ),
                    ],
                    currentIndex: store.selectedIndex,
                    selectedItemColor: Colors.white,
                    onTap: (index) => {store.navigate(index, context)},
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 50, 20, 0),
                      child: Text(
                        'New Post',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 50, 20, 10),
                      child: Text(
                        'Question',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      )),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
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
                            color: Colors.green),
                      )),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      controller: descip,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Container(
                      height: 120,
                      width: 160,
                      padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.green,
                        child: Text('Create'),
                        onPressed: () async {
                          print(ques.text);
                          await store.createPost(ques.text, descip.text);
                          Navigator.pushNamedAndRemoveUntil(
                              context, "Message", (r) => false);
                        },
                      )),
                ],
              )));
    });
  }
}
