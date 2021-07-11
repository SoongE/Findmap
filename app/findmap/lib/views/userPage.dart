import 'dart:convert';
import 'dart:async';

import 'package:findmap/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<User> fetchUser() async {
  var queryParameters = {
    'postId': "1",
  };
  var url = Uri.https('jsonplaceholder.typicode.com', '/users/1');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

class UserPage extends StatefulWidget {
  UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<User> user;

  @override
  void initState() {
    super.initState();
    user = fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.green,
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: FutureBuilder<User>(
          future: fetchUser(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? UserPageBody(user: snapshot.data!)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class UserPageBody extends StatelessWidget {
  final User user;

  UserPageBody({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 50.0,
            backgroundColor: Colors.orange,
            // backgroundImage: ImageAsset,
          ),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 40.0,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pacifico',
            ),
          ),
          Text(
            'THE CUTTEST',
            style: TextStyle(
              fontFamily: 'Source Sans Pro',
              color: Colors.yellow.shade300,
              fontSize: 20.0,
              letterSpacing: 2.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20.0,
            width: 150.0,
            child: Divider(
              color: Colors.blue.shade100,
            ),
          ),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Colors.redAccent,
                  ),
                  title: Text('+82 123 456 789',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.teal.shade900,
                        fontFamily: 'Source Sans Pro',
                      )))),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                leading: Icon(
                  Icons.email,
                  color: Colors.redAccent,
                ),
                title: Text(
                  user.email,
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.teal.shade900,
                      fontFamily: 'Source Sans Pro'),
                ),
              )),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                leading: Icon(
                  Icons.comment,
                  color: Colors.redAccent,
                ),
                title: Text(
                  'Hello World! Hello Flutter!',
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.teal.shade900,
                      fontFamily: 'Source Sans Pro'),
                ),
              )),
        ],
      ),
    );
  }
}
