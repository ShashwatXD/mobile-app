import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:mobile_app/models/failure_model.dart';
import 'package:mobile_app/viewmodels/ib/ib_page_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IbInteractionBuilder extends MarkdownElementBuilder {
  IbInteractionBuilder({required this.model});

  final IbPageViewModel model;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var id = element.textContent;

    return FutureBuilder<dynamic>(
      future: model.fetchHtmlInteraction(id),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data is Failure) {
          return const Text('Error Loading Interaction');
        } else if (!snapshot.hasData) {
          return const Text('Loading Interaction...');
        }

        var textContent = snapshot.data.toString();
        var streamController = StreamController<double>();

        // Create and configure WebViewController
        final controller =
            WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadHtmlString(textContent);

        controller.setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) async {
                try {
                  var result = await controller.runJavaScriptReturningResult(
                    'document.documentElement.scrollHeight;',
                  );
                  var heightString = result.toString();
                  // Remove quotes if present (some Android versions return "123")
                  if (heightString.startsWith('"') && heightString.endsWith('"')) {
                    heightString = heightString.substring(1, heightString.length - 1);
                  }
                  final height = double.tryParse(heightString) ?? 600.0;
                  streamController.add(height);
                } catch (e) {
                  debugPrint('Error getting height: $e');
                }
              },
          ),
        );

        return StreamBuilder<double>(
          initialData: 100,
          stream: streamController.stream,
          builder: (context, snapshot) {
            return SizedBox(
              height: snapshot.data,
              child: WebViewWidget(controller: controller),
            );
          },
        );
      },
    );
  }
}
