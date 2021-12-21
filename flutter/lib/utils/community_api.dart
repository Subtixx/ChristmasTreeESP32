/// Class to communicate with the community API to get community made content.
class CommunityApi {

  String _communityApiUrl;

  CommunityApi(this._communityApiUrl);

  void setUrl(String url) {
    var validUrl = Uri.tryParse("http://" + url) != null ? true : false;
    if (!validUrl) {
      throw Exception('Invalid URL address');
    }

    _communityApiUrl = url;
  }

  String getUrl() {
    return _communityApiUrl;
  }
}