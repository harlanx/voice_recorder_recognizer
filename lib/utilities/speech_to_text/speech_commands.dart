import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class SpeechCommands {
  static final commands = [email, sms, map, launcher, search];
  static final email = 'write email';
  static final sms = 'compose message';
  static final map = 'view map of';
  static final launcher = 'open';
  static final search = 'search';

  static void scanText(String rawText) {
    final text = rawText.toLowerCase();

    if (text.contains(email)) {
      final bodyText = _commandContext(command: email, text: text);
      writeEmail(content: bodyText);
    } else if (text.contains(sms)) {
      final bodyText = _commandContext(command: sms, text: text);
      composeSMS(content: bodyText);
    } else if (text.contains(map)) {
      final bodyText = _commandContext(command: map, text: text);
      openLink(content: bodyText);
    } else if (text.contains(launcher)) {
      final bodyText = _commandContext(command: launcher, text: text);
      openLink(content: bodyText);
    } else if (text.contains(search)) {
      final bodyText = _commandContext(command: search, text: text);
      searchItem(content: bodyText);
    }
  }

  static String _commandContext({
    required String command,
    required String text,
  }) {
    final commandIndex = text.indexOf(command);
    final indexAfter = commandIndex + command.length;

    if (commandIndex == -1) {
      return '';
    } else {
      return text.substring(indexAfter).trim();
    }
  }

  static Future _launchUrl(String url) async {
    if (await urlLauncher.canLaunch(url)) {
      await urlLauncher.launch(url);
    }
  }

  static Future writeEmail({required String content}) async {
    final url = 'mailto:?body=${Uri.encodeFull(content)}';
    await _launchUrl(url);
  }

  static Future composeSMS({required String content}) async {
    final url = 'sms:?body=${Uri.encodeFull(content)}';
    await _launchUrl(url);
  }

  static Future openMap({required String content}) async {
    if (content.isEmpty) {
      await _launchUrl('https://google.com/maps');
    } else {
      final query = Uri.encodeFull(content);
      await _launchUrl('https://google.com/maps/search/$query');
    }
  }

  static Future openLink({required String content}) async {
    if (content.isEmpty) {
      await _launchUrl('https://google.com');
    } else {
      await _launchUrl('https://$content');
    }
  }

  static Future searchItem({required String content}) async {
    if (content.isEmpty) {
      await _launchUrl('https://google.com');
    } else {
      final query = Uri.encodeFull(content);
      await _launchUrl('https://www.google.com/search?q=$query');
    }
  }
}
