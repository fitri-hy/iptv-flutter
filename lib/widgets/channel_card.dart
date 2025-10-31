import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: channel.logo.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: channel.logo,
                httpHeaders: {
                  "User-Agent":
                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
                },
                width: 100,
                height: 60,
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(
                  width: 100,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.tv,
                      size: 50, color: Colors.white70),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.tv,
                      size: 50, color: Colors.white70),
                ),
              )
                  : Container(
                width: 100,
                height: 60,
                color: Colors.grey.shade300,
                child: const Icon(Icons.tv,
                    size: 50, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}
