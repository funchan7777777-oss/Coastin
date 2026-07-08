import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/value_objects/harbor_policy_channel.dart';

class HarborPolicyWebviewPage extends StatefulWidget {
  const HarborPolicyWebviewPage({super.key, required this.policyChannel});

  final HarborPolicyChannel policyChannel;

  @override
  State<HarborPolicyWebviewPage> createState() =>
      _HarborPolicyWebviewPageState();
}

class _HarborPolicyWebviewPageState extends State<HarborPolicyWebviewPage> {
  late final WebViewController _policyController;
  int _loadProgress = 0;

  @override
  void initState() {
    super.initState();
    _policyController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _loadProgress = progress),
        ),
      )
      ..loadRequest(widget.policyChannel.publishedUri);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color(0x00000000),
      ),
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFEAFDF7),
        child: Builder(
          builder: (context) {
            final topInset = MediaQuery.viewPaddingOf(context).top;
            final barHeight = topInset + 52;
            return Stack(
              children: [
                Positioned.fill(
                  top: barHeight,
                  child: WebViewWidget(controller: _policyController),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: _PolicyTopBar(
                    title: widget.policyChannel.title,
                    loadProgress: _loadProgress,
                    topInset: topInset,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PolicyTopBar extends StatelessWidget {
  const _PolicyTopBar({
    required this.title,
    required this.loadProgress,
    required this.topInset,
  });

  final String title;
  final int loadProgress;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: topInset + 52,
      padding: EdgeInsets.fromLTRB(10, topInset + 4, 14, 0),
      decoration: BoxDecoration(
        color: const Color(0xF7F8FFFC),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D5F8B).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size.square(42),
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Icon(
                  CupertinoIcons.chevron_left,
                  color: Color(0xFF17324A),
                  size: 24,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF17324A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
          if (loadProgress < 100)
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: loadProgress / 100,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38D5D5),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
