//
// Copyright 2022 Appcheap.io All rights reserved
//
// App Name:          Cirilla - Multipurpose Flutter App For Wordpress & Woocommerce
// Source:            https://codecanyon.net/item/cirilla-multipurpose-flutter-wordpress-app/31940668
// Docs:              https://appcheap.io/docs/cirilla-developers-docs/
// Since:             2.5.0
// Author:            Appcheap.io
// Author URI:        https://appcheap.io

import 'package:cirilla/models/models.dart';
import 'package:cirilla/themes/default/chat/chat_button.dart';
import 'package:flutter/material.dart';
import 'package:cirilla/themes/themes.dart';

import 'services/chat_status_service.dart';

class VendorInfo extends StatefulWidget {
  final bool enableCenterTitle;
  final Vendor vendor;
  final String viewAppbar;

  const VendorInfo({
    Key? key,
    required this.enableCenterTitle,
    required this.vendor,
    required this.viewAppbar,
  }) : super(key: key);

  @override
  _VendorInfoState createState() => _VendorInfoState();
}

class _VendorInfoState extends State<VendorInfo> with ChatStatusService {
  bool _chatStatus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.vendor.id != null) {
      subscribeVendorStatus(widget.vendor.id!, _setChatStatus);
    }
  }

  void _setChatStatus(bool value) {
    setState(() {
      _chatStatus = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VendorAppBar(
      viewAppbar: widget.viewAppbar,
      vendor: widget.vendor,
      enableCenterTitle: widget.enableCenterTitle,
      enableChat: true,
      enableFollow: false,
      chatButton: _buildChatButton(),
    );
  }

  Widget _buildChatButton() {
    return ChatButton(
      initChat: initUserChat,
      chatStatus: _chatStatus,
      vendor: widget.vendor,
    );
  }
}
