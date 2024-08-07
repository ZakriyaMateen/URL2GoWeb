
class TextHasUrlAndExtractedUrl {
  final bool hasUrl;
  final String url;

  TextHasUrlAndExtractedUrl(this.hasUrl, this.url);
}

TextHasUrlAndExtractedUrl extractUrlInfo(String text) {
  RegExp urlRegex = RegExp(r'https?://\S+');
  RegExpMatch? match = urlRegex.firstMatch(text);

  if (match != null) {
    // URL found
    return TextHasUrlAndExtractedUrl(true, match.group(0)!);
  } else {
    // No URL found
    return TextHasUrlAndExtractedUrl(false, '');
  }
}