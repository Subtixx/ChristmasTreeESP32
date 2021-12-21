// TODO: Keep page in memory

import 'dart:convert';

import 'package:esp_christmas_tree/data/Creation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../main.dart';

class CommunityWidget extends StatefulWidget {
  const CommunityWidget({Key? key}) : super(key: key);

  @override
  _CommunityWidgetState createState() => _CommunityWidgetState();
}

class _CommunityWidgetState extends State<CommunityWidget> {
  List<Creation> items = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  bool isLoading = false;

  int page = 1;

  @override
  void initState() {
    super.initState();
  }

  void _onRefresh() async {
    page = 1;

    var response =
        await http.get(Uri.parse("http://" + key.currentState!.communityApi.getUrl() + "/api/creations/" + page.toString()));
    if (response.statusCode != 200) {
      showSnackBar("Failed to load");
      _refreshController.refreshFailed();
      return;
    }

    if(!mounted) return;
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    List<dynamic> result = responseJson['data'];
    if(!mounted) return;
    setState(() {
      items.clear();
    });

    if (result.isEmpty) {
      _refreshController.refreshFailed();
      return;
    }

    for (Map<String, dynamic> creation in result) {
      items.add(Creation(creation["title"], creation["description"],
          creation["created"], creation["poster"], creation["json_data"]));
    }

    _refreshController.refreshCompleted(resetFooterState: true);
  }

  void _onLoading() async {
    page++;

    var response =
        await http.get(Uri.parse("http://" + key.currentState!.communityApi.getUrl() + "/api/creations/" + page.toString()));
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("Failed to query more objects!"),
      ));

      if (mounted) setState(() {});
      _refreshController.loadFailed();
      return;
    }

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    if (responseJson['last_page'] < responseJson['current_page']) {
      if (mounted) setState(() {});
      _refreshController.loadNoData();
      return;
    }

    List<dynamic> result = responseJson['data'];
    for (Map<String, dynamic> creation in result) {
      items.add(Creation(creation["title"], creation["description"],
          creation["created"], creation["poster"], creation["json_data"]));
    }

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: Text("Loading.."),
            )
          : SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: const MaterialClassicHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.separated(
                itemBuilder: (c, i) => items[i].getWidget(),
                itemCount: items.length,
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: .5,
                    color: Color(0xFFDDDDDD),
                  );
                },
              ),
            ),
    );
  }

  void showSnackBar(String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(title),
    ));
  }
}
