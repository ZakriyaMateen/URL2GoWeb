import 'dart:convert';

import 'package:http/http.dart'as http;
class UrlMetadata {
  final String title;
  final String description;
  final List<String> imageUrls;
  final int duration;
  final String domain;
  final String url;

  UrlMetadata({
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.duration,
    required this.domain,
    required this.url,
  });
}

Future<UrlMetadata> fetchUrlMetadata(String url) async {
  final apiKey = 'pk_fa5d64d54d914bfc53fed909a7cdcea0b4fe2747';
  final apiUrl = Uri.parse('https://jsonlink.io/api/extract?url=$url&api_key=$apiKey');
  try{
    print('inside fetchUrlMetadata');
    final response = await http.get(apiUrl);
    if (response.statusCode == 200) {
      print('statusCode = 200');
      print(json.decode(response.body));
      final Map<String, dynamic> data = json.decode(response.body);
      print(data);
      return UrlMetadata(
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        imageUrls: List<String>.from(data['images'] ?? []),
        duration: data['duration'] ?? 0,
        domain: data['domain'] ?? '',
        url: data['url'] ?? '',
      );
    }
    else{
      throw Exception('Failed to load URL metadata');
    }
  }
  catch(e){
    print(e.toString());
    throw Exception('Failed to load URL metadata');
  }


}