import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectableTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final InputDecoration decoration;
  final TextStyle? style;
  final TextInputType keyboardType;

  const SelectableTextField(
      {super.key,
      required this.controller,
      required this.focusNode,
      this.autofocus = false,
      this.maxLines = 1,
      this.minLines = 1,
      this.decoration = const InputDecoration(),
      this.style,
      this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      style: style,
      decoration: decoration,
      // 启用文本选择
      enableInteractiveSelection: true,
      contextMenuBuilder: (context, editableTextState) {
        return _buildAdaptiveContextMenu(
            context,
            editableTextState.contextMenuAnchors,
            editableTextState.contextMenuButtonItems);
      },
    );
  }

  Widget _buildAdaptiveContextMenu(
      BuildContext context,
      TextSelectionToolbarAnchors anchors,
      List<ContextMenuButtonItem> buttonItems) {
    return AdaptiveTextSelectionToolbar(
      anchors: anchors,
      children: buttonItems.map((item) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              item.onPressed;
              ContextMenuController.removeAny();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                item.label ?? '',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TinyStackSelectableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isOwnMessage;

  const TinyStackSelectableText({super.key, required this.text, this.style, this.isOwnMessage = false});

  @override
  State<TinyStackSelectableText> createState() => _TinyStackSelectableTextState();
}

class _TinyStackSelectableTextState extends State<TinyStackSelectableText> {
  TextSelection _selection = TextSelection.collapsed(offset: 0);
  final LayerLink _layerLink = LayerLink();
  final _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<ContextMenuButtonItem> _buildMenuItems() {
    return [
      if (_selection.isValid && !_selection.isCollapsed)
      ContextMenuButtonItem(
        label: '复制',
        onPressed: () {
          final selectedText = widget.text.substring(
            _selection.start,
            _selection.end,
          );
          Clipboard.setData(ClipboardData(text: selectedText));
          ContextMenuController.removeAny();
        }
      ),
      ContextMenuButtonItem(
          label: '全选',
          onPressed: () {
            setState(() {
              _selection = TextSelection(baseOffset: 0, extentOffset: widget.text.length);
            });
            ContextMenuController.removeAny();
          }
      ),
    ];
  }

  Widget _buildMaterialContextMenu(BuildContext context, TextSelectionToolbarAnchors anchors) {
    return TextSelectionToolbar(
      anchorAbove: anchors.primaryAnchor,
      anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
      children: _buildMenuItems().map((item) {
        return _TextSelectionToolbarTextButton(
          onPressed: item.onPressed,
          child: Text(item.label ?? ''),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SelectableText.rich(
        key: _textKey,
        TextSpan(text: widget.text, style: widget.style),
        contextMenuBuilder: (context, menuState) {
          return _buildMaterialContextMenu(context, menuState.contextMenuAnchors);
        },
        onSelectionChanged: (selection, cause) {
          setState(() {
            _selection = selection;
          });
        },
      ),
    );
  }
}


class _TextSelectionToolbarTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _TextSelectionToolbarTextButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(64, 36),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}