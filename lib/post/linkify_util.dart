import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'dart:developer';
import '../search/search_post.dart';

void printAll(String _log) {
  log(_log, name: 'Response');
}

class LinkifyUtil extends StatefulWidget {
  final String text;
  final bool withPreview;
  final int maxWords;

  const LinkifyUtil(
      {Key? key, required this.text, bool? withPreview, int? maxWords})
      : withPreview = withPreview ?? true,
        maxWords = maxWords ?? 100,
        super(key: key);

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
        const SizedBox(height: 5),
        if (widget.withPreview) PreviewsWidget(urls: _extractUrls(widget.text)),
      ],
    );
  }

  void _buildTextSpans(String text) {
    final RegExp regex = RegExp(
        r'((?:https?|ftp):\/\/[\w/\-?=%.]+\.[\w/\-&?=%.]+)|((?<=\s|^)#[\w\一-\龥ぁ-んァ-ンー]+(?=\s|$))',
        multiLine: true);
    final RegExp regexHash = RegExp(r'^#');

    final matches = regex.allMatches(text);
    final List<InlineSpan> spans = [];

    int currentIndex = 0;
    int totalTextLength = 0;
    int lastLinkStart = 0;

    for (var match in matches) {
      if (match.start > currentIndex) {
        totalTextLength += match.start - currentIndex;
        if (totalTextLength > widget.maxWords) {
          _spansEclipsed = [...spans];
          _spansEclipsed.add(
            TextSpan(
              text: text.substring(currentIndex, widget.maxWords),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
          _spansEclipsed.add(
            TextSpan(
              text: 'もっと見る',
              style: TextStyle(color: const Color(0xFFAE0103), fontSize: 16),
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
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }

      String url = match.group(0)!;
      totalTextLength += url.length;
      if (regexHash.hasMatch(url)) {
        spans.add(TextSpan(
          text: url,
          style: TextStyle(color: const Color(0xFFAE0103), fontSize: 16),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPostListPage(keyword: url),
                ),
              );
            },
        ));
      } else {
        spans.add(
          TextSpan(
            text: url,
            style: TextStyle(color: const Color(0xFFAE0103), fontSize: 16),
            recognizer: TapGestureRecognizer()..onTap = () => _launchURL(url),
          ),
        );
      }

      currentIndex = match.end;
      lastLinkStart = match.start;
    }

    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      totalTextLength = text.length;
      if (totalTextLength > widget.maxWords) {
        if (_spansEclipsed.isEmpty) {
          _spansEclipsed = [...spans];
          _spansEclipsed.add(
            TextSpan(
              text: text.substring(currentIndex, widget.maxWords),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        _spansEclipsed.add(
          TextSpan(
            text: '...もっと見る',
            style: TextStyle(color: const Color(0xFFAE0103), fontSize: 16),
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
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } else {
      if (lastLinkStart <= widget.maxWords) {
        _isExpanded = true;
      }
    }
    _spansExpanded = spans;

    // print(totalTextLength);
    if (totalTextLength <= widget.maxWords) {
      _isExpanded = true;
    }
  }

  List<String> _extractUrls(String text) {
    final RegExp regex = RegExp(
        r'\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[A-Z0-9+&@#\/%=~_|]',
        caseSensitive: false);
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
  final style = const TextStyle(
    color: Color(0xFFAE0103),
    fontSize: 14,
    //fontWeight: FontWeight.w500,
    //height: 1.375,
  );

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
              // color: Color(0xfff7f7f8),
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              child: LinkPreview(
                linkStyle: style,
                /*
                metadataTextStyle: style.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                metadataTitleStyle: style.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                 */
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
