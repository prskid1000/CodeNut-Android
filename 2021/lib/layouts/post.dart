import 'package:CodeNut/components/frame.dart';
import 'package:CodeNut/store/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Post extends StatelessWidget {
  final TextEditingController text3 = new TextEditingController();
  final TextEditingController text4 = new TextEditingController();
  final TextEditingController text5 = new TextEditingController();

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Consumer<Store>(
      builder: (context, store, child) {
        return Frame(<Widget>[
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
                                      color:
                                          store.theme.compareTo(('dark')) == 0
                                              ? Colors.white
                                              : Colors.black),
                                ),
                                DecoratedBox(
                                    decoration:
                                        const BoxDecoration(color: Colors.red),
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      child: Text(
                                        store.current['votes'],
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
                                      color:
                                          store.theme.compareTo(('dark')) == 0
                                              ? Colors.white
                                              : Colors.black),
                                ),
                                DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.redAccent),
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                                      child: Text(
                                        store.current['author'],
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
                    store.upvoteq();
                  },
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                ),
                InkWell(
                  child: Icon(Icons.thumb_down, color: Colors.white, size: 28),
                  onTap: () {
                    store.downvoteq();
                  },
                )
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  Container(
                    width: width * 0.82,
                    child: TextFormField(
                      maxLines: 5,
                      readOnly: (store.current['author'] == store.userId)
                          ? false
                          : true,
                      controller: text4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: store.current['question'],
                        hintStyle: TextStyle(
                            fontSize: 18,
                            color: store.theme.compareTo('dark') == 0
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                ],
              )),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: [
                Container(
                  width: width * 0.82,
                  child: TextFormField(
                    maxLines: 10,
                    readOnly: (store.current['author'] == store.userId)
                        ? false
                        : true,
                    controller: text5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: store.current['description'],
                      hintStyle: TextStyle(
                          fontSize: 18,
                          color: store.theme.compareTo('dark') == 0
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: store.current['author'] != store.userId
                ? Opacity(opacity: 0)
                : Row(
                    children: [
                      Container(
                        height: 60,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: RaisedButton(
                          onPressed: () =>
                              {store.savePost(context, text4.text, text5.text)},
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
                              constraints: BoxConstraints(
                                  maxWidth: 150, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text(
                                "Edit",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 60,
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: RaisedButton(
                          onPressed: (store.userId == store.current['author'])
                              ? () {
                                  store.deletePost(context);
                                }
                              : () {},
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
                              constraints: BoxConstraints(
                                  maxWidth: 150, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text(
                                "Delete",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: [
                Container(
                  width: width * 0.70,
                  child: TextFormField(
                    maxLines: 3,
                    controller: text3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Your Comment",
                      hintStyle: TextStyle(
                          fontSize: 18,
                          color: store.theme.compareTo('dark') == 0
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
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
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              children: store.commentBuilder(context),
            ),
          ),
        ]);
      },
    );
  }
}
