import 'dart:io';

import 'package:flutter/cupertino.dart';

/// Shows a "Done" bar above the iOS keyboard for inputs that use numeric
/// keyboards (phone, number) which do not include a dismiss key.
class KeyboardDoneToolbar extends StatelessWidget {
  const KeyboardDoneToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox.shrink();

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    if (bottomInset == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        border: Border(
          top: BorderSide(color: CupertinoColors.separator.resolveFrom(context)),
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onPressed: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Text(
            'Done',
            style: TextStyle(
              color: CupertinoColors.activeBlue.resolveFrom(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
