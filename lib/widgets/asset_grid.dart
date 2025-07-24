import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/asset.dart';

class AssetGrid extends StatelessWidget {
  final List<Asset> assets;
  final Function(Asset) onAssetTap;

  const AssetGrid({
    Key? key,
    required this.assets,
    required this.onAssetTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return _AssetCard(
          asset: asset,
          onTap: () => onAssetTap(asset),
        );
      },
    );
  }
}

class _AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const _AssetCard({
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset thumbnail
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: _getAssetColor(),
                ),
                child: asset.isImage
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: asset.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Icon(
                              _getAssetIcon(),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              _getAssetIcon(),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          _getAssetIcon(),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
              ),
            ),
            
            // Asset info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getAssetTypeIcon(),
                        size: 12,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          asset.type.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset.fileSizeFormatted,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAssetColor() {
    if (asset.isImage) return Colors.blue;
    if (asset.isVideo) return Colors.red;
    if (asset.isAudio) return Colors.green;
    if (asset.isDocument) return Colors.orange;
    return Colors.grey;
  }

  IconData _getAssetIcon() {
    if (asset.isImage) return Icons.image;
    if (asset.isVideo) return Icons.videocam;
    if (asset.isAudio) return Icons.music_note;
    if (asset.isDocument) return Icons.description;
    return Icons.insert_drive_file;
  }

  IconData _getAssetTypeIcon() {
    if (asset.isImage) return Icons.photo;
    if (asset.isVideo) return Icons.video_library;
    if (asset.isAudio) return Icons.audiotrack;
    if (asset.isDocument) return Icons.article;
    return Icons.file_present;
  }
} 