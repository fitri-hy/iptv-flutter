import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static const String githubApiLatest =
      "https://api.github.com/repos/fitri-hy/iptv-flutter/releases/latest";

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion =
          "${packageInfo.version}+${packageInfo.buildNumber}";

      final response = await http.get(
        Uri.parse(githubApiLatest),
        headers: {'User-Agent': 'request'},
      );

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final latestTag = data['tag_name']?.toString().trim();
      final releaseUrl = data['html_url']?.toString();

      if (latestTag != null &&
          releaseUrl != null &&
          _isNewerVersion(latestTag, currentVersion)) {
        _showUpdateDialog(context, releaseUrl, latestTag, currentVersion);
      }
    } catch (_) {
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    String clean(String v) => v.split('(').first.split('+').first.trim();

    List<int> parseVersionParts(String v) =>
        clean(v).split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final latestParts = parseVersionParts(latest);
    final currentParts = parseVersionParts(current);

    for (int i = 0; i < 3; i++) {
      final latestNum = i < latestParts.length ? latestParts[i] : 0;
      final currentNum = i < currentParts.length ? currentParts[i] : 0;
      if (latestNum > currentNum) return true;
      if (latestNum < currentNum) return false;
    }

    int parseBuild(String v) {
      final match = RegExp(r'\((\d+)\)').firstMatch(v);
      if (match != null) return int.tryParse(match.group(1)!) ?? 0;
      return 0;
    }

    final latestBuild = parseBuild(latest);
    final currentBuild = parseBuild(current);

    return latestBuild > currentBuild;
  }

  static void _showUpdateDialog(
      BuildContext context, String url, String latest, String current) {
    if (!context.mounted) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.system_update, color: Colors.blueAccent),
            const SizedBox(width: 10),
            const Text('Update Available',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current version: $current',
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 4),
            Text('Latest version: $latest',
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('A new version of IPTV is available. Would you like to update now?'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
              foregroundColor: isDark ? Colors.white : Colors.black,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(url);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
