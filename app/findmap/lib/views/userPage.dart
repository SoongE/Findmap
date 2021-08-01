import 'dart:convert';

import 'package:findmap/models/user.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/first.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';

class UserPage extends StatefulWidget {
  final User user;

  UserPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.lightGreen,
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: UserPageBody(user: widget.user),
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
            radius: 70.0,
            backgroundImage: NetworkImage(
              'https://avatars.githubusercontent.com/u/53206234?v=4',
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 15)),
          Text(
            user.nickName,
            style: TextStyle(
              fontSize: 40.0,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pacifico',
            ),
          ),
          Text(
            user.name,
            style: TextStyle(
              color: Colors.yellow.shade300,
              fontSize: 20.0,
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
                  title: Text(user.phoneNum,
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
                      fontSize: 18.0,
                      color: Colors.teal.shade900,
                      fontFamily: 'Source Sans Pro'),
                ),
              )),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                leading: Icon(
                  LineIcons.cocktail,
                  color: Colors.redAccent,
                ),
                title: Text(
                  user.taste,
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.teal.shade900,
                      fontFamily: 'Source Sans Pro'),
                ),
              )),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final storage = new FlutterSecureStorage();
    await storage.deleteAll();

    var _isSignOutSafe = fetchSignOut();

    _isSignOutSafe.then((value) => value
        ? {
            showSnackbar(context, "정상적으로 로그아웃 되었습니다"),
            Navigator.pushAndRemoveUntil(
                context, createRoute(FirstPage()), (route) => false),
          }
        : showSnackbar(context, "정상적으로 로그아웃되지 않았습니다"));
  }

  Future<bool> fetchSignOut() async {
    final response = await http.patch(
      Uri.http(BASEURL, '/users/logout'),
      headers: {
        "token": user.accessToken,
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body)['success'];
    } else {
      throw Exception('Failed to load post');
    }
  }
}
