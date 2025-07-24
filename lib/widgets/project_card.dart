import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.onTap,
  }) : super(key: key);

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Project thumbnail or icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getProjectColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: project.thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          project.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getProjectIcon(),
                              color: Colors.white,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : Icon(
                        _getProjectIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),

              // Project details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (project.description.isNotEmpty) ...[
                      Text(
                        project.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${project.assetCount} assets',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd').format(project.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status indicator and menu
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showProjectOptions(context);
                    },
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProjectColor() {
    // Generate a consistent color based on project name
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = project.name.hashCode % colors.length;
    return colors[index];
  }

  IconData _getProjectIcon() {
    // Return different icons based on project type or name
    final name = project.name.toLowerCase();
    if (name.contains('video') || name.contains('film')) {
      return Icons.videocam;
    } else if (name.contains('photo') || name.contains('image')) {
      return Icons.photo_camera;
    } else if (name.contains('audio') || name.contains('music')) {
      return Icons.music_note;
    } else if (name.contains('design') || name.contains('graphic')) {
      return Icons.design_services;
    } else {
      return Icons.folder;
    }
  }

  Color _getStatusColor() {
    switch (project.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'archived':
        return Colors.grey;
      case 'draft':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showProjectOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Project'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to edit project
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Upload Assets'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to upload assets
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Project'),
              onTap: () {
                Navigator.of(context).pop();
                // Share project
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Project'),
              onTap: () {
                Navigator.of(context).pop();
                // Archive project
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Project', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete project
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 