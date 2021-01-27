import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
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
            'Chat': (context) => Chat(),
          },
          debugShowCheckedModeBanner: false,
        )),
      );
}

class Store extends ChangeNotifier {

  List<String> boxIds = [];
  List<String> users = [];
  String userId = "";
  String password = "";
  int selectedIndex = 0;
  bool validUser = false;
  List<String> author = [];
  List<String> message = [];
  String chatBox = "";

  void navigate(int data, BuildContext context) async
  {
    switch(data)
    {
      case 0:
        await setAuth(userId, password);
        Navigator.pushNamedAndRemoveUntil(context, "Message", (r) => false);
        break;
      case 1:
        await setAuth(userId, password);
        Navigator.pushNamedAndRemoveUntil(context, "User", (r) => false);
        break;
      case 2:
        notifyListeners();
        Navigator.pushNamedAndRemoveUntil(context, "Chat", (r) => false);
        break;
      case 3:
        SystemNavigator.pop();
        break;
    }
    print(data);
    this.selectedIndex = data;
  }

  Future setAuth(String userId, String password) async
  {
    this.userId = userId;
    this.password = password;
    var url = 'https://ichatb.herokuapp.com/isauth';
    var response = await http.post(url, body: {'userid': userId, 'password': password});
    var decoded = json.decode(response.body);
    if(decoded['success'].toString().compareTo("True") == 0)
      {
        this.validUser = true;
        this.boxIds.clear();
        for(int i = 0; i < decoded['data']['boxid'].length; i++)
        {
          this.boxIds.add(decoded['data']['boxid'][i]);
        }
      }

    url = 'https://ichatb.herokuapp.com/getusers';
    response = await http.get(url);
    decoded = json.decode(response.body)['data'];

    this.users = [];

    for(int i = 0; i < decoded.length; i++)
    {
      if(this.userId != decoded[i]['userid'])
        this.users.add(decoded[i]['userid']);
    }

    notifyListeners();
  }

  Future addUser(String userId, String password) async
  {
    this.userId = userId;
    this.password = password;
    var url = 'https://ichatb.herokuapp.com/adduser';
    var response = await http.post(url, body: {'userid': userId, 'password': password});
    var decoded = json.decode(response.body);
    if(decoded['success'].toString().compareTo("True") == 0)
    {
      this.validUser = true;
      this.boxIds.clear();
      for(int i = 0; i < decoded['data']['boxid'].length; i++)
      {
        this.boxIds.add(decoded['data']['boxid'][i]);
      }
    }
    notifyListeners();
  }

  Future comment(BuildContext context, String data) async
  {
    var url = 'https://ichatb.herokuapp.com/sendbox';
    var response = await http.post(url, body: {'boxid': chatBox, 'userid': userId, 'message':data});
    var decoded = json.decode(response.body)['data']['chat'];

    url = 'https://ichatb.herokuapp.com/getusers';
    response = await http.get(url);
    decoded = json.decode(response.body)['data'];

    this.users = [];

    for(int i = 0; i < decoded.length; i++)
    {
      if(this.userId == decoded[i]['userid'])
        this.users.add(decoded[i]['userid']);
    }

    await syncBox(this.chatBox);
    Navigator.pushNamedAndRemoveUntil(context, "Chat", (r) => false);
    notifyListeners();
  }

  Future newBox(BuildContext context, String user) async
  {
    var url = 'https://ichatb.herokuapp.com/sendbox';
    this.chatBox = "#" + this.userId + "-" + user;

    var response = await http.post(url, body: {'boxid': chatBox,
      'userid': userId, 'message': "Hi, " + user});

    url = 'https://ichatb.herokuapp.com/setbox';
    response = await http.post(url, body: {'boxid': chatBox, 'userid': userId});

    url = 'https://ichatb.herokuapp.com/setbox';
    response = await http.post(url, body: {'boxid': chatBox, 'userid': user});

    url = 'https://ichatb.herokuapp.com/getusers';
    response = await http.get(url);
    var decoded = json.decode(response.body)['data'];

    this.users = [];

    for(int i = 0; i < decoded.length; i++)
    {
      if(this.userId != decoded[i]['userid'])
        this.users.add(decoded[i]['userid']);
    }

    await syncBox(this.chatBox);
    Navigator.pushNamedAndRemoveUntil(context, "Chat", (r) => false);
    notifyListeners();
  }

  Future syncBox(String id) async
  {
    var url = 'https://ichatb.herokuapp.com/getbox';
    var response = await http.post(url, body: {'boxid': id});
    var decoded = json.decode(response.body)['data']['chat'];

    this.author = [];
    this.message = [];

    for(int i = 0; i < decoded.length; i++)
    {
      this.author.insert(0, decoded[i]['author']);
      this.message.insert(0, decoded[i]['message']);
    }

    notifyListeners();
  }

  void deleteBox(BuildContext context, String id) async
  {
    var url = 'https://ichatb.herokuapp.com/deletebox';
    var response = await http.post(url, body: {'boxid': id});

    url = 'https://ichatb.herokuapp.com/unsetbox';
    response = await http.post(url, body: {'userid': this.userId,'boxid': id});

    String user2 = id.substring(id.indexOf('-') + 1);

    url = 'https://ichatb.herokuapp.com/unsetbox';
    response = await http.post(url, body: {'userid': user2,'boxid': id});

    this.boxIds.remove(id);
    notifyListeners();
  }

  void boxTap(BuildContext context, String id) async
  {
    this.selectedIndex = 2;
    this.chatBox = id;

    await syncBox(id);

    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, "Chat", (r) => false);
  }

  List<Widget> boxBuilder(BuildContext context)
  {
    List<Widget> wid = [];
    for(int i = 0; i < this.boxIds.length; i++)
    {
      wid.add(Card(
        child: ListTile(
          leading: Icon(Icons.all_inclusive, color: Colors.black),
          title: Text(boxIds[i]),
          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          hoverColor: Colors.greenAccent,
          tileColor: Colors.green[300],
          onTap: (){boxTap(context, boxIds[i]);},
            trailing: InkWell(
                child:Icon(Icons.delete, color: Colors.redAccent),
                onTap: (){deleteBox(context, boxIds[i]);},
            )
        ),
      ));
    }
    return wid;
  }

  List<Widget> boxBuilder2(BuildContext context)
  {
    List<Widget> wid = [];
    for(int i = 0; i < this.users.length; i++)
    {
      wid.add(Card(
        child: ListTile(
            leading: Icon(Icons.all_inclusive, color: Colors.black),
            title: Text(users[i]),
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            hoverColor: Colors.greenAccent,
            tileColor: Colors.green[300],
            trailing: InkWell(
              child:Icon(Icons.chat, color: Colors.redAccent),
              onTap: (){newBox(context, users[i]);},
            )
        ),
      ));
    }
    return wid;
  }

  List<Widget> chatBuilder(BuildContext context)
  {
    List<Widget> wid = [];
    for(int i = 0; i < this.author.length; i++)
    {
      if(this.author[i] != this.userId)
        {
          wid.add(Card(
              margin: EdgeInsets.fromLTRB(0, 5, 100, 5),
              child:
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(this.author[i],
                          style: TextStyle(fontSize:18, color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TextButton(
                          child: Text(this.message[i],
                            style: TextStyle(fontSize:14, color: Colors.white),
                          ),

                        ),
                      ],
                    ),
                  ],
                ),
              )
          ),
          );
        }
      else
        {
          wid.add(Card(
              margin: EdgeInsets.fromLTRB(100, 5, 0, 5),
              child:
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(this.author[i],
                          style: TextStyle(fontSize:18, color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: Text(this.message[i],
                            style: TextStyle(fontSize:14, color: Colors.white),
                          ),

                        ),
                      ],
                    ),
                  ],
                ),
              )
          ),
          );
        }

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
        builder:(context, store, child){
          return Scaffold(
              body: Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'IChat',
                            style: TextStyle(fontSize: 36,color: Colors.green),
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
                                onPressed: () async
                                {
                                  const oneSec = const Duration(seconds:10);
                                  await store.setAuth(text.text, password.text);
                                  if(store.validUser == true)
                                  {
                                    new Timer.periodic(oneSec, (Timer t) => store.setAuth(text.text, password.text));
                                    new Timer.periodic(oneSec, (Timer t) => store.syncBox(store.chatBox));
                                    Navigator.pushNamedAndRemoveUntil(context, "Message", (r) => false);
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
                                onPressed: () async
                                {
                                  await store.addUser(text.text, password.text);
                                  const oneSec = const Duration(seconds:10);
                                  if(store.validUser == true)
                                  {
                                    new Timer.periodic(oneSec, (Timer t) => store.setAuth(text.text, password.text));
                                    new Timer.periodic(oneSec, (Timer t) => store.syncBox(store.chatBox));
                                    Navigator.pushNamedAndRemoveUntil(context, "Message", (r) => false);
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
    return Consumer<Store>
      (builder: (context, store, child){
        return Scaffold(
            body: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: ListView(
                  children: <Widget>[
                    BottomNavigationBar(
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(Icons.markunread_mailbox_rounded, color: Colors.greenAccent),
                          label: 'Boxes',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.account_box, color: Colors.greenAccent),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.chat, color: Colors.greenAccent),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.exit_to_app, color: Colors.greenAccent),
                          label: '',
                        ),
                      ],
                      currentIndex: store.selectedIndex,
                      selectedItemColor: Colors.white,
                      onTap: (index) => {
                        store.navigate(index, context)
                      },
                    ),
                    Container(
                      height:  700,
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                      child: ListView(
                        children: store.boxBuilder(context),
                      ),
                    )
                  ],
                )));
    }
    );
  }
}

class User extends StatelessWidget {

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {

    return Consumer<Store>
      (builder: (context, store, child){
      return Scaffold(
          body: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: ListView(
                children: <Widget>[
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.markunread_mailbox_rounded, color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_box, color: Colors.greenAccent),
                        label: 'User',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.chat, color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.exit_to_app, color: Colors.greenAccent),
                        label: '',
                      ),
                    ],
                    currentIndex: store.selectedIndex,
                    selectedItemColor: Colors.white,
                    onTap: (index) => {
                      store.navigate(index, context)
                    },
                  ),
                  Container(
                    height:  700,
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                    child: ListView(
                      children: store.boxBuilder2(context),
                    ),
                  )
                ],
              )));
    }
    );
  }
}
class Chat extends StatelessWidget {

  final TextEditingController text = TextEditingController();
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Consumer<Store>
      (builder: (context, store, child){
      return Scaffold(
          body: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: ListView(
                children: <Widget>[
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.markunread_mailbox_rounded, color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_box, color: Colors.greenAccent),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.chat, color: Colors.greenAccent),
                        label: 'Chat',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.exit_to_app, color: Colors.greenAccent),
                        label: '',
                      ),
                    ],
                    currentIndex: store.selectedIndex,
                    selectedItemColor: Colors.white,
                    onTap: (index) => {
                      store.navigate(index,context)
                    },
                  ),
                  Container(
                    height:  600,
                    padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                    child: ListView(
                      children: store.chatBuilder(context),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child:Row(
                      children: [
                        Container(
                          width: 280,
                          child:
                          TextFormField(
                            controller: text,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Message',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child:  InkWell(
                            child:Icon(Icons.send, color: Colors.green, size: 50,),
                            onTap: (){store.comment(context, text.text);},
                          )
                        ),
                      ],
                  ),
                  ),
                ],
              )));
    }
    );
  }
}
