import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/channel.dart';

class M3UService {
  static final Map<String, List<Channel>> _cache = {};

  static Future<List<Channel>> fetchPlaylist(String url, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.containsKey(url)) {
      return _cache[url]!;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception("Failed to load playlist.");

    final lines = const LineSplitter().convert(response.body);
    final List<Channel> channels = [];

    String? extinf;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith("#EXTINF")) {
        extinf = line;
      } else if (extinf != null && !line.startsWith("#")) {
        final name = extinf.split(",").last.trim();
        final idMatch = RegExp(r'tvg-id="(.*?)"').firstMatch(extinf);
        final logoMatch = RegExp(r'tvg-logo="(.*?)"').firstMatch(extinf);
        final groupMatch = RegExp(r'group-title="(.*?)"').firstMatch(extinf);

        final id = idMatch?.group(1) ?? "";
        final logo = logoMatch?.group(1) ?? "";

        var group = groupMatch?.group(1) ?? "Undefined";
        group = group.replaceAll(';', ', ');

        if (group.trim().isEmpty || group == "Undefined") {
          group = "Others";
        }

        String country = "Unknown";
        if (id.contains('.')) {
          final parts = id.split('.');
          if (parts.isNotEmpty) {
            final lastPart = parts.last;
            country = lastPart.split('@').first.toUpperCase();
          }
        }

        channels.add(Channel(
          name: name,
          url: line.trim(),
          logo: logo,
          group: group,
          id: id,
          country: country,
        ));

        extinf = null;
      }
    }

    _cache[url] = channels;

    return channels;
  }
}
