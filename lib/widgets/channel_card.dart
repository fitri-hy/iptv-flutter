import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  child: channel.logo.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: channel.logo,
                    httpHeaders: const {
                      "User-Agent":
                      "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
                    },
                    width: double.infinity,
                    height: 80,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(
                      width: double.infinity,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.tv,
                          size: 50, color: Colors.white70),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.tv,
                          size: 50, color: Colors.white70),
                    ),
                  )
                      : Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.tv,
                        size: 50, color: Colors.white70),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                channel.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
