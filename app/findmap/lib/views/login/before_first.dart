import 'package:findmap/src/my_colors.dart';
import 'package:findmap/utils/utils.dart';
import 'package:findmap/views/login/first.dart';
import 'package:flutter/material.dart';

class BeforeFirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Spacer(flex: 2),
            Text(
              "Draw your map",
              style: TextStyle(
                  fontFamily: "FugazOne",
                  fontSize: 20,
                  color: Colors.grey[700]),
            ),
            Text(
              "FindMap",
              style: TextStyle(fontFamily: "FugazOne", fontSize: 70),
            ),
            Spacer(flex: 1),
            Image.asset(
              'assets/logo.png',
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 2,
            ),
            Spacer(flex: 1),
            Column(
              children: [
                _buildBox(context, MyColors.myYellow, "카카오로 로그인하기",
                    textColor: Colors.black),
                Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                _buildBox(context, MyColors.myBlue, "구글로 로그인하기"),
                Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                _buildBox(context, MyColors.myPurple, "이메일로 로그인하기",
                    page: FirstPage()),
                Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                _buildBox(context, MyColors.myPink, "AppleID로 로그인하기"),
              ],
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, Color color, String string,
      {Color textColor: Colors.white, Widget? page}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: Size(MediaQuery.of(context).size.width - 80, 45),
        primary: color,
      ),
      onPressed: () =>
          page != null ? Navigator.push(context, createRoute(page)) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(string,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w500, color: textColor)),
          Align(
              alignment: Alignment.centerRight,
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  padding: EdgeInsets.all(3),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 20,
                  )))
        ],
      ),
    );
  }
}
