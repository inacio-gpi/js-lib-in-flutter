import 'package:flutter/material.dart';

import 'html_editor_controller_web.dart';
import 'utils/utils.dart';
import 'widgets/html_editor_widget_web.dart';

class HtmlEditor extends StatelessWidget {
  const HtmlEditor({
    Key? key,
    required this.controller,
    this.htmlTemplateOptions = const HtmlTemplateOptions(),
  }) : super(key: key);

  final HtmlTemplateOptions htmlTemplateOptions;
  final HtmlEditorController controller;

  @override
  Widget build(BuildContext context) {
    return HtmlEditorWidget(
      key: key,
      initBC: context,
      htmlTemplateOptions: htmlTemplateOptions,
      controller: controller,
    );
  }
}
