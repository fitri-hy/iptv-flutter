import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/constants.dart';
import '../models/github_user.dart';

class AboutDeveloperScreen extends StatefulWidget {
  const AboutDeveloperScreen({super.key});

  @override
  State<AboutDeveloperScreen> createState() => _AboutDeveloperScreenState();
}

class _AboutDeveloperScreenState extends State<AboutDeveloperScreen> {
  GitHubUser? _user;
  bool _loading = true;

  String _appName = "";
  String _version = "";
  String _buildNumber = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appName = info.appName;
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(AppConstants.githubCacheKey);

    if (cachedData != null) {
      setState(() {
        _user = GitHubUser.fromJson(json.decode(cachedData));
        _loading = false;
      });
    }

    _fetchGitHubUser();
  }

  Future<void> _fetchGitHubUser() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.githubProfileUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final user = GitHubUser.fromJson(jsonData);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString(AppConstants.githubCacheKey, json.encode(user.toJson()));

        setState(() {
          _user = user;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching GitHub user: $e");
      if (_user == null) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarColor = theme.appBarTheme.backgroundColor ?? theme.primaryColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text("About Developer"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text("Failed to load data"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_user!.avatarUrl),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _user!.name.isNotEmpty ? _user!.name : _user!.login,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _user!.bio,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoCard("Followers", _user!.followers.toString(), textColor),
                          _buildInfoCard("Following", _user!.following.toString(), textColor),
                          _buildInfoCard("Repos", _user!.publicRepos.toString(), textColor),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appBarColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final Uri url = Uri.parse(_user!.htmlUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.link),
                        label: const Text("Visit GitHub"),
                      ),
                      const SizedBox(height: 24),

					  Card(
					    shape: RoundedRectangleBorder(
						  borderRadius: BorderRadius.circular(8),
					    ),
					    elevation: 0,
					    child: Padding(
						  padding: const EdgeInsets.all(16.0),
						  child: Column(
						    crossAxisAlignment: CrossAxisAlignment.start,
						    children: [
							  Text(
							    "App Information",
							    style: TextStyle(
								  fontSize: 18,
								  fontWeight: FontWeight.bold,
								  color: textColor,
							    ),
							  ),
							  const SizedBox(height: 8),
							  Text(
							    "Name: $_appName",
							    style: TextStyle(color: textColor),
							  ),
							  const SizedBox(height: 4),
							  Text(
							    "Version: $_version ($_buildNumber)",
							    style: TextStyle(color: textColor),
							  ),
							  const SizedBox(height: 4),
							  Text(
							    "Description: IPTV is a Flutter-based application designed to watch television broadcasts from around the world using M3U playlists.",
							    style: TextStyle(color: textColor),
							  ),
						    ],
						  ),
					    ),
					  ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: textColor)),
      ],
    );
  }
}
