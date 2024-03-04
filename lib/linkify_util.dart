import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'dart:developer';

void printAll(String _log) {
  log(_log, name: 'Response');
}

class LinkifyUtil extends StatefulWidget {
  final String text;

  const LinkifyUtil({Key? key, required this.text}) : super(key: key);

  @override
  _LinkifyUtilState createState() => _LinkifyUtilState();
}

class _LinkifyUtilState extends State<LinkifyUtil> {
  bool _isExpanded = false;
  List<InlineSpan> _spansExpanded = [];
  List<InlineSpan> _spansEclipsed = [];

  @override
  Widget build(BuildContext context) {
    final spans = _buildTextSpans(widget.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: _isExpanded ? _spansExpanded : _spansEclipsed,
          ),
        ),
        PreviewsWidget(urls: _extractUrls(widget.text)),
      ],
    );
  }

  void _buildTextSpans(String text) {
    final RegExp regex =
        RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-&?=%.]+');

    final matches = regex.allMatches(text);
    final List<InlineSpan> spans = [];

    int currentIndex = 0;
    int totalTextLength = 0;

    for (var match in matches) {
      if (match.start > currentIndex) {
        totalTextLength += match.start - currentIndex;
        if (totalTextLength > 100) {
          _spansEclipsed = [...spans];
          _spansEclipsed.add(
            TextSpan(
              text: text.substring(currentIndex, 100),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          );
          _spansEclipsed.add(
            TextSpan(
              text: 'もっと見る',
              style: TextStyle(color: Colors.blue, fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
            ),
          );
        }
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        );
      }

      String url = match.group(0)!;
      totalTextLength += url.length;
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(color: Colors.blue, fontSize: 16),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      totalTextLength = text.length;
      if (totalTextLength > 100) {
        if (_spansEclipsed.isEmpty) {
          _spansEclipsed = [...spans];
          _spansEclipsed.add(
            TextSpan(
              text: text.substring(currentIndex, 100),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          );
        }

        _spansEclipsed.add(
          TextSpan(
            text: '...もっと見る',
            style: TextStyle(color: Colors.blue, fontSize: 16),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                print('expandします');
                printAll(_spansEclipsed[0].toString());
                printAll(_spansExpanded[0].toString());
                print(_isExpanded);
                setState(() {
                  _isExpanded = true;
                });
              },
          ),
        );
      }
      spans.add(
        TextSpan(
          text: remainingText,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      );
    }
    _spansExpanded = spans;

    // print(totalTextLength);
    if (totalTextLength <= 100) {
      _isExpanded = true;
    }
  }

  List<String> _extractUrls(String text) {
    final RegExp regex =
        RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-&?=%.]+');

    final matches = regex.allMatches(text);
    final List<String> urls = [];

    for (var match in matches) {
      String url = match.group(0)!;
      urls.add(url);
    }

    return urls;
  }

  void _launchURL(String url) async {
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
        return GestureDetector(
          onTap: () => _launchURL(url), // タップ時にURLを開く
          child: Container(
            key: ValueKey(index),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              color: Color(0xfff7f7f8),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
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
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
