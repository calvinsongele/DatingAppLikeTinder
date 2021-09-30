import 'package:url_launcher/url_launcher.dart';
class UrlLauncher {

  String _url;

  UrlLauncher(this._url);

  launchUrl() async {
    if (await canLaunch(_url))
      await launch(_url);
    else 
      throw "Could not launch $_url";
  }

  
}