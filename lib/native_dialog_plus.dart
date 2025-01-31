import 'dart:async';
import 'package:flutter/services.dart';

/// DTO for a UIAlertAction
class NativeDialogPlusAction {
  /// Text of the action which is displayed
  final String text;

  /// Style of the action
  final NativeDialogPlusActionStyle style;

  /// Callback when the user clicks the action
  /// If this callback is null, then the action is disabled
  final VoidCallback? onPressed;

  NativeDialogPlusAction({
    required this.text,
    this.style = NativeDialogPlusActionStyle.defaultStyle,
    this.onPressed,
  });

  /// Get if the action is enabled or not
  bool get enabled => onPressed != null;

  Map<dynamic, dynamic> toJson() {
    return {"text": text, "style": style.index, "enabled": enabled};
  }
}

/// Enum mapping for the [UIAlertController.Style](https://developer.apple.com/documentation/uikit/uialertcontroller/style)
enum NativeDialogPlusStyle {
  /// An action sheet displayed by the view controller that presented it.
  /// Is the native equivalent to [CupertinoActionSheet](https://api.flutter.dev/flutter/cupertino/CupertinoActionSheet-class.html)
  actionSheet,

  /// An alert displayed modally for the app.
  /// Is the native equivalent to [CupertinoAlertDialog](https://api.flutter.dev/flutter/cupertino/CupertinoAlertDialog-class.html)
  alert
}

/// Enum mapping for the [UIAlertAction.Style](https://developer.apple.com/documentation/uikit/uialertaction/style)
enum NativeDialogPlusActionStyle {
  /// Apply the default style to the action’s action.
  defaultStyle,

  /// Apply a style that indicates the action cancels the operation and leaves things unchanged.
  cancel,

  /// Apply a style that indicates the action might change or delete data.
  destructive,
}

class NativeDialogPlus {
  static const MethodChannel _channel = MethodChannel('native_dialog_plus');

  /// Title of the dialog
  final String? title;

  /// Main content of the dialog
  final String? message;

  /// Style of the dialog, which determines if it is the native equivalent to a [CupertinoAlertDialog](https://api.flutter.dev/flutter/cupertino/CupertinoAlertDialog-class.html) or [CupertinoActionSheet](https://api.flutter.dev/flutter/cupertino/CupertinoActionSheet-class.html)
  final NativeDialogPlusStyle style;

  /// List of actions that the dialog has.
  /// Please note that if there is no action, the user cannot close the dialog unless he closes the whole app.
  /// The same also applies when all actions are disabled (`onPressed` is null)
  /// **IMPORTANT**
  /// Android is limited to the maximum of 3 actions one of each NativeDialogPlusActionStyle style
  /// therefore its limited to one defaultStyle, cancel and destructive each, the order of the actions in the list does not change the position in the dialog.
  /// iOS has no limit on the number of actions
  final List<NativeDialogPlusAction> actions;

  NativeDialogPlus({
    this.title,
    this.message,
    this.style = NativeDialogPlusStyle.alert,
    required this.actions,
  });

  /// Shows the native iOS Dialog and calls the specific `onPressed` handler
  ///
  /// [WrongPlatformException] if `.show()` was not called on a iOS Platform
  Future<void> show() async {
    final result = await _channel.invokeMethod<int>("showDialog", {
          "title": title,
          "message": message,
          "style": style.index,
          "actions": [for (var action in actions) action.toJson()]
        }) ??
        -1;
    if (result == -1) return;
    var action = actions[result];
    if (!action.enabled || action.onPressed == null) return;
    action.onPressed!();
  }
}
