import 'package:flutter/material.dart';
import '../models/channel.dart';
import 'player_screen.dart';
import '../widgets/channel_card.dart';

class FavoriteScreen extends StatefulWidget {
  final List<Channel> favorites;
  final List<String> favoriteIds;
  final Function(Channel) onFavoriteToggle;

  const FavoriteScreen({
    super.key,
    required this.favorites,
    required this.onFavoriteToggle,
    required this.favoriteIds,
  });

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late List<Channel> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = List.from(widget.favorites);
  }

  void _handleFavoriteToggle(Channel ch) {
    widget.onFavoriteToggle(ch);
    setState(() {
      _favorites.removeWhere((item) => item.url == ch.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor =
        Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Favorite",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reload Favorites",
            onPressed: () {
              setState(() {
                _favorites = List.from(widget.favorites);
              });
            },
          ),
        ],
      ),
      body: _favorites.isEmpty
          ? const Center(
              child: Text(
                "No favorite channels yet.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: _favorites.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, i) {
                  final ch = _favorites[i];
                  final isFav = widget.favoriteIds.contains(ch.url);
                  return ChannelCard(
                    channel: ch,
                    isFavorite: isFav,
                    onFavoriteToggle: () => _handleFavoriteToggle(ch),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(channelId: ch.url),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
