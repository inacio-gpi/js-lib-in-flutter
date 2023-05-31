import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:external_lib_web/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../html_editor_controller_web.dart';

export 'dart:html';

class HtmlEditorWidget extends StatefulWidget {
  const HtmlEditorWidget({
    Key? key,
    required this.initBC,
    required this.htmlTemplateOptions,
    required this.controller,
  }) : super(key: key);

  final BuildContext initBC;
  final HtmlTemplateOptions htmlTemplateOptions;
  final HtmlEditorController controller;

  @override
  _HtmlEditorWidgetWebState createState() => _HtmlEditorWidgetWebState();
}

class _HtmlEditorWidgetWebState extends State<HtmlEditorWidget> {
  late String createdViewId;
  late double actualHeight;
  Future<bool>? templateInit;

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  @override
  void initState() {
    super.initState();
    actualHeight = 500;
    createdViewId = getRandString(10);
    widget.controller.viewId = createdViewId;
    initTemplate();
  }

  final String buttonKey = 'button-key';
  String loadToolbarButtonKeys() {
    List<String> values = [];
    List.generate(widget.htmlTemplateOptions.customToolbarButtons.length, (index) {
      values.add(buttonKey + "$index");
    });
    return values.join(" | ");
  }

  String loadToolbarButtonScripts() {
    List<String> values = [];
    List.generate(widget.htmlTemplateOptions.customToolbarButtons.length, (index) {
      final HtmlToolbarButton toolbarButton = widget.htmlTemplateOptions.customToolbarButtons[index];
      final List<String> items = toolbarButton.buttonOptions.map((e) {
        String handleSubmenuItems;
        if (e.submenuItems.isNotEmpty) {
          final submenuItems = e.submenuItems.map((item) => '''
              {
                type: 'menuitem',
                text: '${item.textButton}',
                onAction: function () {
                  editor.insertContent('${item.insertContent}');
                }
              }
              ''').toList();
          handleSubmenuItems = """
          getSubmenuItems: function () {
            return [
              ${submenuItems.join(', ')}
            ];
          }
        """;
        } else {
          handleSubmenuItems = '''
            onAction: function () {
              editor.insertContent('${e.insertContent}');
            }
            ''';
        }
        return """
                  {
                      type: '${e.submenuItems.isNotEmpty ? 'nestedmenuitem' : 'menuitem'}',
                      text: '${e.textButton}',
                      $handleSubmenuItems
                  }
                """;
      }).toList();

      String script = """
                editor.ui.registry.addMenuButton('${buttonKey + "$index"}', {
                    text: '${toolbarButton.toolbarTextButton}',
                    fetch: function (callback) {
                        var items = [
                            ${items.join(',')}
                        ];
                        callback(items);
                    }
                });
                """;
      values.add(script);
    });
    return values.join();
  }

  void initTemplate() async {
    final String keys = loadToolbarButtonKeys();
    final String tinymceScript = '''
     <script type="text/javascript">
        tinymce.init({
            valid_children : "+body[style]",
            selector: '#einstein-editor-id',
            extended_valid_elements : "span[*],svg[*],defs[*],pattern[*],desc[*],metadata[*],g[*],mask[*],path[*],line[*],marker[*],rect[*],circle[*],ellipse[*],polygon[*],polyline[*],linearGradient[*],radialGradient[*],stop[*],image[*],view[*],text[*],textPath[*],title[*],tspan[*],glyph[*],symbol[*],switch[*],use[*]",
            content_style: '${widget.htmlTemplateOptions.cssContentStyle}',
            toolbar: 'undo redo | blocks | bold italic forecolor | alignleft aligncenter | alignright alignjustify | bullist numlist outdent indent | removeformat | code | $keys',
            plugins: [
                'advlist', 'autolink', 'lists', 'link', 'image', 'charmap', 'preview',
                'anchor', 'searchreplace', 'visualblocks', 'code', 'fullscreen',
                'insertdatetime', 'media', 'table', 'help', 'wordcount'
            ],
            setup: function (editor) {
                /* Menu items are recreated when the menu is closed and opened, so we need
                   a variable to store the toggle menu item state. */
                var toggleState = false;

                /* example, adding a toolbar menu button */
                ${loadToolbarButtonScripts()}
                /* example, adding a toolbar menu button */

            },
            content_style: 'body { font-family:Helvetica,Arial,sans-serif; font-size:14px }'
        });


        
        window.parent.addEventListener('message', handleMessage, false);
        console.log('done');
      
        function handleMessage(e) {
            if (e && e.data && e.data.includes("toIframe:")) {
                var data = JSON.parse(e.data);
                if (data["view"]?.includes("$createdViewId") ?? false) {
                    if (data["type"].includes("getText")) {
                        var str = tinymce.get("einstein-editor-id").getContent();
                        window.parent.postMessage(JSON.stringify({"type": "toDart: getText", "text": str}), "*");
                    }
                    if (data["type"].includes("setText")) {
                        tinymce.get("einstein-editor-id").setContent(data["text"]);
                    }
                }
            }
        }
    </script>
    ''';
    print('tinymceScript AKIIIIIIIII');
    print(tinymceScript);
    var filePath = 'assets/tinymce.html';
    var htmlString = await rootBundle.loadString(filePath);
    htmlString = htmlString.replaceFirst('<!--tinymceScript-->', tinymceScript);

    final iframe = html.IFrameElement()
      ..width = MediaQuery.of(widget.initBC).size.width.toString() //'800'
      ..height = actualHeight.toString()
      ..srcdoc = htmlString
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..onLoad.listen((event) async {
        html.window.onMessage.listen((event) {});
      });

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(createdViewId, (int viewId) => iframe);
    setStater(mounted, setState, () {
      templateInit = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: actualHeight,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: FutureBuilder<bool>(
                future: templateInit,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return HtmlElementView(
                      viewType: createdViewId,
                    );
                  } else {
                    return Container(height: actualHeight);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
