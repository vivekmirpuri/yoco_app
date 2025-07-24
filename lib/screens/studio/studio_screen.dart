import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../models/project.dart';
import '../../models/asset.dart';
import '../../widgets/asset_grid.dart';
import '../../widgets/upload_progress_dialog.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({Key? key}) : super(key: key);

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Project? _selectedProject;
  String _selectedAssetType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Studio'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateProjectDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              _showUploadDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Projects'),
            Tab(text: 'Assets'),
            Tab(text: 'Tools'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectsTab(firestoreService),
          _buildAssetsTab(firestoreService),
          _buildToolsTab(),
        ],
      ),
    );
  }

  Widget _buildProjectsTab(FirestoreService firestoreService) {
    return StreamBuilder<List<Project>>(
      stream: firestoreService.getUserProjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading projects',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        final projects = snapshot.data ?? [];

        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No projects yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first project to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _showCreateProjectDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Project'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getProjectColor(project),
                  child: Icon(
                    _getProjectIcon(project),
                    color: Colors.white,
                  ),
                ),
                title: Text(project.name),
                subtitle: Text(project.description),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    _handleProjectAction(value, project);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'upload',
                      child: Row(
                        children: [
                          Icon(Icons.upload),
                          SizedBox(width: 8),
                          Text('Upload Assets'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _selectedProject = project;
                  });
                  _tabController.animateTo(1); // Switch to assets tab
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAssetsTab(FirestoreService firestoreService) {
    if (_selectedProject == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 64,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a project',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a project to view its assets',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Asset type filter
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Assets in ${_selectedProject!.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedAssetType,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'image', child: Text('Images')),
                  DropdownMenuItem(value: 'video', child: Text('Videos')),
                  DropdownMenuItem(value: 'audio', child: Text('Audio')),
                  DropdownMenuItem(value: 'document', child: Text('Documents')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAssetType = value!;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Assets grid
        Expanded(
          child: StreamBuilder<List<Asset>>(
            stream: firestoreService.getProjectAssets(_selectedProject!.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading assets',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              }

              final assets = snapshot.data ?? [];
              final filteredAssets = _selectedAssetType == 'all'
                  ? assets
                  : assets.where((asset) => asset.type.toLowerCase().contains(_selectedAssetType)).toList();

              if (filteredAssets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No assets yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload some assets to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showUploadDialog(context);
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Assets'),
                      ),
                    ],
                  ),
                );
              }

              return AssetGrid(
                assets: filteredAssets,
                onAssetTap: (asset) {
                  _showAssetDetails(context, asset);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolCard(
          icon: Icons.photo_camera,
          title: 'Photo Editor',
          subtitle: 'Edit and enhance your photos',
          color: Colors.blue,
          onTap: () {
            // Navigate to photo editor
          },
        ),
        _buildToolCard(
          icon: Icons.videocam,
          title: 'Video Editor',
          subtitle: 'Create and edit videos',
          color: Colors.red,
          onTap: () {
            // Navigate to video editor
          },
        ),
        _buildToolCard(
          icon: Icons.music_note,
          title: 'Audio Editor',
          subtitle: 'Edit and mix audio files',
          color: Colors.green,
          onTap: () {
            // Navigate to audio editor
          },
        ),
        _buildToolCard(
          icon: Icons.design_services,
          title: 'Design Tools',
          subtitle: 'Create graphics and designs',
          color: Colors.purple,
          onTap: () {
            // Navigate to design tools
          },
        ),
        _buildToolCard(
          icon: Icons.analytics,
          title: 'Analytics',
          subtitle: 'View project statistics',
          color: Colors.orange,
          onTap: () {
            // Navigate to analytics
          },
        ),
        _buildToolCard(
          icon: Icons.settings,
          title: 'Studio Settings',
          subtitle: 'Configure your studio',
          color: Colors.grey,
          onTap: () {
            // Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Color _getProjectColor(Project project) {
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

  IconData _getProjectIcon(Project project) {
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

  void _handleProjectAction(String action, Project project) {
    switch (action) {
      case 'edit':
        // Navigate to edit project
        break;
      case 'upload':
        _showUploadDialog(context);
        break;
      case 'share':
        // Share project
        break;
      case 'delete':
        _showDeleteConfirmation(context, project);
        break;
    }
  }

  void _showCreateProjectDialog(BuildContext context) {
    // Implementation similar to home screen
  }

  void _showUploadDialog(BuildContext context) {
    // Implementation for upload dialog
  }

  void _showAssetDetails(BuildContext context, Asset asset) {
    // Show asset details modal
  }

  void _showDeleteConfirmation(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
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