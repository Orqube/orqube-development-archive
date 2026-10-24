// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:js_util' as js_util;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'adsense_config.dart';

class OrqubeAdSenseAd extends StatelessWidget {
  const OrqubeAdSenseAd({
    super.key,
    required this.placement,
    this.maxWidth = 1180,
  });

  final String placement;
  final double maxWidth;

  String get _slot => placement == 'mining'
      ? AdSenseConfig.miningResponsiveSlot
      : AdSenseConfig.homeResponsiveSlot;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('public_config')
          .doc('ads')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink();
        final data = snapshot.data?.data();
        final enabled = data?['webAdSenseEnabled'] != false;
        if (!enabled) return const SizedBox.shrink();

        final placeholder = AdSenseConfig.developmentPlaceholderMode ||
            !AdSenseConfig.hasValidPublisherId ||
            !AdSenseConfig.isValidSlot(_slot);

        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: placeholder
                  ? _DevelopmentPlaceholder(placement: placement)
                  : _LiveAdSenseView(
                      placement: placement,
                      publisherId: AdSenseConfig.publisherId,
                      slotId: _slot,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _DevelopmentPlaceholder extends StatelessWidget {
  const _DevelopmentPlaceholder({required this.placement});

  final String placement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 58, maxHeight: 78),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      alignment: Alignment.center,
      child: Text(
        placement == 'mining'
            ? 'Google AdSense 개발용 광고 자리'
            : 'Google AdSense 반응형 광고 자리',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(.45),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LiveAdSenseView extends StatefulWidget {
  const _LiveAdSenseView({
    required this.placement,
    required this.publisherId,
    required this.slotId,
  });

  final String placement;
  final String publisherId;
  final String slotId;

  @override
  State<_LiveAdSenseView> createState() => _LiveAdSenseViewState();
}

class _LiveAdSenseViewState extends State<_LiveAdSenseView> {
  late final String _viewType;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'orqube-adsense-${widget.placement}-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final wrapper = html.DivElement()
        ..style.width = '100%'
        ..style.minHeight = '90px'
        ..style.overflow = 'hidden';

      final ad = html.Element.tag('ins')
        ..classes.add('adsbygoogle')
        ..setAttribute('data-ad-client', widget.publisherId)
        ..setAttribute('data-ad-slot', widget.slotId)
        ..setAttribute('data-ad-format', 'auto')
        ..setAttribute('data-full-width-responsive', 'true')
        ..setAttribute('aria-label', 'Advertisement')
        ..style.display = 'block';
      wrapper.append(ad);

      _loadScriptAndRequestAd(ad, wrapper);
      return wrapper;
    });
  }

  Future<void> _loadScriptAndRequestAd(
    html.Element ad,
    html.DivElement wrapper,
  ) async {
    try {
      final scriptId = 'orqube-adsense-script';
      if (html.document.getElementById(scriptId) == null) {
        final script = html.ScriptElement()
          ..id = scriptId
          ..async = true
          ..src = 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${widget.publisherId}'
          ..crossOrigin = 'anonymous';
        html.document.head?.append(script);
        await script.onLoad.first.timeout(const Duration(seconds: 12));
      }

      js_util.callMethod(html.window, 'eval', [
        '(adsbygoogle = window.adsbygoogle || []).push({});',
      ]);

      await Future<void>.delayed(const Duration(seconds: 8));
      final status = ad.getAttribute('data-ad-status');
      if (status == 'unfilled' || wrapper.clientHeight < 20) {
        wrapper.style.minHeight = '0';
        wrapper.style.height = '0';
        if (mounted) setState(() => _collapsed = true);
      }
    } catch (_) {
      wrapper.style.minHeight = '0';
      wrapper.style.height = '0';
      if (mounted) setState(() => _collapsed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_collapsed) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: 110,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}

