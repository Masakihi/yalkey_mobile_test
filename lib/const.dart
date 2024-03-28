class Const {
  bool debugAPI;

  Const({this.debugAPI = false});

  String getUrl() {
    if (debugAPI) {
      return 'http://127.0.0.1:8000/';
    } else {
      return 'https://yalkey.com/';
    }
  }
}
