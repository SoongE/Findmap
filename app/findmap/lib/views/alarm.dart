import 'package:findmap/models/post_folder.dart';
import 'package:flutter/material.dart';
import 'package:smart_select/smart_select.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  GlobalKey<S2SingleState<int>> _smartSelectKey =
      GlobalKey<S2SingleState<int>>();

  String value = 'flutter';
  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'ion', title: 'Ionic'),
    S2Choice<String>(value: 'flu', title: 'Flutter'),
    S2Choice<String>(value: 'rea', title: 'React Native'),
  ];

  int folderValue = 0;

  List<Map<String, dynamic>> folderOptions = [
    PostFolder(0, 0, "Zero", 0, 'createdAt', 'updatedAt', 'status').toJson(),
    PostFolder(1, 1, "One", 1, 'createdAt', 'updatedAt', 'status').toJson(),
    PostFolder(2, 2, "Two", 2, 'createdAt', 'updatedAt', 'status').toJson(),
    PostFolder(3, 3, "Three", 3, 'createdAt', 'updatedAt', 'status').toJson()
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _smartSelectKey.currentState!.showModal(),
          child: Container(
            width: 100,
            height: 100,
            color: Colors.red,
          ),
        ),
        SmartSelect<int>.single(
          key: _smartSelectKey,
          title: 'Frameworks',
          value: folderValue,
          onChange: (state) => setState(() => {folderValue = state.value}),
          modalType: S2ModalType.bottomSheet,
          modalHeader: false,
          choiceLayout: S2ChoiceLayout.list,
          modalHeaderStyle: S2ModalHeaderStyle(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          ),
          modalStyle: S2ModalStyle(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          ),
          choiceItems: S2Choice.listFrom<int, Map<String, dynamic>>(
            source: folderOptions,
            value: (index, item) => item['idx'],
            title: (index, item) => item['name'],
          ),
          tileBuilder: (context, state) {
            return Container();
          },
        ),
      ],
    );
  }
}