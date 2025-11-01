import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/m3u_service.dart';
import '../services/constants.dart';
import '../services/update_checker.dart';
import '../models/channel.dart';
import 'player_screen.dart';
import 'favorite_screen.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/channel_card.dart';
import '../widgets/theme_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Channel> _channels = [];
  List<String> _groups = [];
  String _selectedGroup = "All";
  bool _loading = true;
  String _searchQuery = "";
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _setPortraitOrientation();
    _loadChannels();
    _loadFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker.checkForUpdate(context);
    });
  }

  void _setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _loadChannels() async {
    try {
      final data = await M3UService.fetchPlaylist(AppConstants.playlistUrl);
      final groups = data.map((c) => c.group.trim()).toSet().toList()..sort();

      setState(() {
        _channels = data;
        _groups = ["All", "Favorites", ...groups];
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading channels: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _reloadChannels() async {
    setState(() => _loading = true);

    for (var ch in _channels) {
      if (ch.logo.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(ch.logo);
      }
    }

    await _loadChannels();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _toggleFavorite(Channel ch) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(ch.url)) {
        _favoriteIds.remove(ch.url);
      } else {
        _favoriteIds.add(ch.url);
      }
      prefs.setStringList('favorites', _favoriteIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _channels.where((c) {
      final matchGroup = _selectedGroup == "All"
          ? true
          : _selectedGroup == "Favorites"
          ? _favoriteIds.contains(c.url)
          : c.group == _selectedGroup;
      final matchSearch =
      c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchGroup && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "IPTV",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadChannels,
            tooltip: "Reload Channels",
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: "Favorites",
            onPressed: () async {
              final favChannels =
              _channels.where((ch) => _favoriteIds.contains(ch.url)).toList();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoriteScreen(
                    favorites: favChannels,
                    onFavoriteToggle: _toggleFavorite,
                    favoriteIds: _favoriteIds,
                  ),
                ),
              );
              _loadFavorites();
            },
          ),
          const ThemeSelector(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "About Developer",
            onPressed: () async {
              final Uri url = Uri.parse('https://github.com/fitri-hy');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch URL')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SearchFilterBar(
                searchQuery: _searchQuery,
                onSearchChanged: (val) => setState(() => _searchQuery = val),
                selectedGroup: _selectedGroup,
                groups: _groups,
                onGroupChanged: (val) => setState(() => _selectedGroup = val),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: filtered.isEmpty
                      ? const Center(child: Text("Channel Not Found."))
                      : GridView.builder(
                    itemCount: filtered.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, i) {
                      final ch = filtered[i];
                      final isFav = _favoriteIds.contains(ch.url);
                      return ChannelCard(
                        channel: ch,
                        isFavorite: isFav,
                        onFavoriteToggle: () => _toggleFavorite(ch),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(channel: ch),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
