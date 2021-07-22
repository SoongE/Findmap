import 'package:animations/animations.dart';
import 'package:findmap/views/login/email_confirm.dart';
import 'package:flutter/material.dart';

import 'background_painter.dart';
import 'email_signin.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  ValueNotifier<bool> showSignInPage = ValueNotifier<bool>(false);

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: CustomPaint(
              painter: BackgroundPainter(
                animation: _controller,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ValueListenableBuilder<bool>(
                valueListenable: showSignInPage,
                builder: (context, value, child) {
                  return SizedBox.expand(
                    child: PageTransitionSwitcher(
                      reverse: !value,
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (child, animation, secondaryAnimation) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.vertical,
                          fillColor: Colors.transparent,
                          child: child,
                        );
                      },
                      child: value
                          ? EmailConfirm(
                              key: const ValueKey('Register'),
                              onSignInPressed: () {
                                showSignInPage.value = false;
                                _controller.reverse();
                              },
                            )
                          : SignIn(
                              key: const ValueKey('SignIn'),
                              onRegisterClicked: () {
                                showSignInPage.value = true;
                                _controller.forward();
                              },
                            ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
