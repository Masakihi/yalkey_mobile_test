import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;

class LinkifyUtil {
  static Widget linkifyTextWithPreviews(String text) {
    final RegExp regex =
        RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-&?=%.]+');

    final matches = regex.allMatches(text);
    final List<InlineSpan> spans = [];

    List<String> foundUrls = [];

    int currentIndex = 0;

    for (var match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        );
      }

      String url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(color: Colors.blue, fontSize: 16),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
        ),
      );

      foundUrls.add(url);

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: spans,
          ),
        ),
        SizedBox(height: 16),
        PreviewsWidget(urls: foundUrls),
      ],
    );
  }

  static void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class PreviewsWidget extends StatefulWidget {
  final List<String> urls;
  const PreviewsWidget({Key? key, required this.urls}) : super(key: key);

  @override
  State<PreviewsWidget> createState() => _PreviewsWidget();
}

class _PreviewsWidget extends State<PreviewsWidget> {
  Map<String, PreviewData> datas = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.urls.length,
      itemBuilder: (context, index) {
        final url = widget.urls[index];
        return Container(
          key: ValueKey(index),
          margin: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            color: Color(0xfff7f7f8),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            child: LinkPreview(
              enableAnimation: true,
              onPreviewDataFetched: (data) {
                setState(() {
                  datas[url] = data;
                });
              },
              previewData: datas[url],
              text: url,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        );
      },
    );
  }
}
