class HtmlTemplateOptions {
  const HtmlTemplateOptions({
    this.cssContentStyle,
    this.initialText,
    this.customToolbarButtons = const [],
  });
  final String? cssContentStyle;
  final String? initialText;
  final List<HtmlToolbarButton> customToolbarButtons;
}

class HtmlToolbarButton {
  final String toolbarTextButton;
  final List<HtmlToolbarButtonOption> buttonOptions;
  HtmlToolbarButton({
    required this.toolbarTextButton,
    required this.buttonOptions,
  });
}

class HtmlToolbarButtonOption {
  final String textButton;
  final String? insertContent;
  final List<SubmenuButtonOption> submenuItems;
  HtmlToolbarButtonOption({
    required this.textButton,
    this.insertContent,
    this.submenuItems = const [],
  });
}

class SubmenuButtonOption {
  final String textButton;
  final String insertContent;
  SubmenuButtonOption({
    required this.textButton,
    required this.insertContent,
  });
}
