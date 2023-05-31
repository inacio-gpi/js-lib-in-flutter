import 'package:flutter/material.dart';

import 'html_editor_controller_web.dart';
import 'html_editor_web.dart';
import 'utils/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = '';
  String result2 = '';
  final HtmlEditorController controller = HtmlEditorController();
  final HtmlEditorController controller2 = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        primary: true,
        child: Center(
          child: SizedBox(
            width: 1200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                        onPressed: () async {
                          var txt = await controller.getText();
                          // var txt2 = await controller2.getText();
                          if (txt.contains('src="data:')) {
                            txt = '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                          }
                          setState(() {
                            result = txt;
                            // result2 = txt2;
                          });
                        },
                        child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                        onPressed: () {
                          controller.setText('<h1>Troquei tudo ha ie ie</h1>');
                        },
                        child: const Text('Trocar html', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(result),
                      Text(result2),
                    ],
                  ),
                ),
                HtmlEditor(
                  controller: controller,
                  htmlTemplateOptions: HtmlTemplateOptions(
                    customToolbarButtons: [
                      HtmlToolbarButton(
                        toolbarTextButton: 'TESTE',
                        buttonOptions: [
                          HtmlToolbarButtonOption(
                            insertContent: '<h1>TEXTO INSERIDO</h1>',
                            textButton: 'Child texte 1',
                            submenuItems: [
                              SubmenuButtonOption(insertContent: '{name}', textButton: 'TAG name'),
                            ],
                          ),
                          HtmlToolbarButtonOption(
                            insertContent: '<h1>CHILDREEEEEN</h1>',
                            textButton: 'Child texte 2',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // HtmlEditor(
                //   controller: controller2,
                //   HtmlTemplateOptions: const HtmlTemplateOptions(
                //     customToolbarButtons: [],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
