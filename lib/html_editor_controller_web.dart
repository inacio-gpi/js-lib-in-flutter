import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class HtmlEditorController {
  HtmlEditorController({
    this.processInputHtml = true,
    this.processNewLineAsBr = false,
    this.processOutputHtml = true,
  });

  final bool processInputHtml;
  final bool processNewLineAsBr;
  final bool processOutputHtml;

  String? _viewId;

  set viewId(String? viewId) => _viewId = viewId;

  Future<String> getText() async {
    _evaluateJavascriptWeb(data: {'type': 'toIframe: getText'});
    var e = await html.window.onMessage.firstWhere((element) => json.decode(element.data)['type'] == 'toDart: getText');
    String text = json.decode(e.data)['text'];
    if (processOutputHtml && (text.isEmpty || text == '<p></p>' || text == '<p><br></p>' || text == '<p><br/></p>')) text = '';
    return text;
  }

  void setText(String text) {
    text = _processHtml(html: text);
    _evaluateJavascriptWeb(data: {'type': 'toIframe: setText', 'text': text});
  }

  String _processHtml({required html}) {
    if (processInputHtml) {
      html = html.replaceAll('\r', '').replaceAll('\r\n', '');
    }
    if (processNewLineAsBr) {
      html = html.replaceAll('\n', '<br/>').replaceAll('\n\n', '<br/>');
    } else {
      html = html.replaceAll('\n', '').replaceAll('\n\n', '');
    }
    return html;
  }

  void _evaluateJavascriptWeb({required Map<String, Object?> data}) async {
    data['view'] = _viewId;
    const jsonEncoder = JsonEncoder();
    var json = jsonEncoder.convert(data);
    html.window.postMessage(json, '*');
  }
}
