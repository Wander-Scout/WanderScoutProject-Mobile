import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:url_launcher/url_launcher.dart';  // Import url_launcher

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Map<String, String>> headlines = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  // Fetch data from RSS feed
  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse('https://jogja.antaranews.com/rss/pariwisata-budaya.xml'));

    if (response.statusCode == 200) {
      var document = xml.XmlDocument.parse(response.body);
      var items = document.findAllElements('item');

      setState(() {
        headlines = items.map((node) {
          return {
            'title': node.findElements('title').single.text,
            'link': node.findElements('link').single.text
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News - Pariwisata Budaya'),
        backgroundColor: const Color(0xFF3B82F6), // Blue color
      ),
      body: headlines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: headlines.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      headlines[index]['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Tap to read more...',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    onTap: () {
                      // Open the full news article in a browser or webview
                      _launchURL(headlines[index]['link']!);
                    },
                  ),
                );
              },
            ),
    );
  }

  // Open URL in a browser
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
