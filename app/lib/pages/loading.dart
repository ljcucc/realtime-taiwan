import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/lang.dart';

class LoadingPage extends StatefulWidget {
  /// will call this aysnc function while loading screen
  final Stream<String?> Function() onLoading;

  const LoadingPage({
    super.key,
    required this.onLoading,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  String msg = "";
  @override
  void initState() {
    super.initState();
    _loading();
  }

  _loading() async {
    await for (final msg in widget.onLoading()) {
      setState(() {
        this.msg = msg!;
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 800;
    Widget helpWidget = Positioned(
      bottom: 16,
      right: 16,
      child: IconButton(
        icon: Icon(Icons.info_outline),
        onPressed: () {},
      ),
    );

    if (isPhone) {
      helpWidget = Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Center(
          child: TextButton.icon(
            icon: Icon(Icons.info_outline),
            label: Text(lang(context).help),
            onPressed: () {},
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            helpWidget,
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    constraints: BoxConstraints(maxWidth: 250),
                    child: LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(msg),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
