import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/project.dart';
import '../../models/asset.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimeRange = '7d';

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            value: _selectedTimeRange,
            onSelected: (value) {
              setState(() {
                _selectedTimeRange = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 days')),
              const PopupMenuItem(value: '1y', child: Text('Last year')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getTimeRangeText()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview cards
            _buildOverviewCards(firestoreService),
            const SizedBox(height: 24),
            
            // Project performance
            _buildProjectPerformance(firestoreService),
            const SizedBox(height: 24),
            
            // Asset statistics
            _buildAssetStatistics(firestoreService),
            const SizedBox(height: 24),
            
            // Recent activity
            _buildRecentActivity(firestoreService),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(FirestoreService firestoreService) {
    return StreamBuilder<List<Project>>(
      stream: firestoreService.getUserProjects(),
      builder: (context, snapshot) {
        final projects = snapshot.data ?? [];
        final totalProjects = projects.length;
        final activeProjects = projects.where((p) => p.status == 'active').length;
        final totalAssets = projects.fold<int>(0, (sum, p) => sum + p.assetCount);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.folder,
                    title: 'Total Projects',
                    value: totalProjects.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    title: 'Active Projects',
                    value: activeProjects.toString(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.photo_library,
                    title: 'Total Assets',
                    value: totalAssets.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.storage,
                    title: 'Storage Used',
                    value: '${(totalAssets * 2.5).toStringAsFixed(1)} MB',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectPerformance(FirestoreService firestoreService) {
    return StreamBuilder<List<Project>>(
      stream: firestoreService.getUserProjects(),
      builder: (context, snapshot) {
        final projects = snapshot.data ?? [];
        final topProjects = projects
            .where((p) => p.assetCount > 0)
            .toList()
          ..sort((a, b) => b.assetCount.compareTo(a.assetCount));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Projects',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (topProjects.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No project data yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create projects and upload assets to see analytics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topProjects.take(5).length,
                itemBuilder: (context, index) {
                  final project = topProjects[index];
                  final percentage = (project.assetCount / topProjects.first.assetCount * 100).round();
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getProjectColor(project),
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(project.name),
                      subtitle: Text('${project.assetCount} assets'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$percentage%',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProjectColor(project),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildAssetStatistics(FirestoreService firestoreService) {
    return StreamBuilder<List<Project>>(
      stream: firestoreService.getUserProjects(),
      builder: (context, snapshot) {
        final projects = snapshot.data ?? [];
        
        // Mock asset type distribution
        final assetTypes = {
          'Images': 45,
          'Videos': 25,
          'Audio': 15,
          'Documents': 15,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Distribution',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: assetTypes.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            _getAssetTypeIcon(entry.key),
                            color: _getAssetTypeColor(entry.key),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(entry.key),
                          ),
                          Text(
                            '${entry.value}%',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: LinearProgressIndicator(
                              value: entry.value / 100,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getAssetTypeColor(entry.key),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity(FirestoreService firestoreService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              final activities = [
                {'action': 'Created project', 'name': 'Summer Campaign', 'time': '2 hours ago'},
                {'action': 'Uploaded assets', 'name': 'Product Photos', 'time': '4 hours ago'},
                {'action': 'Updated project', 'name': 'Brand Guidelines', 'time': '1 day ago'},
                {'action': 'Shared project', 'name': 'Marketing Materials', 'time': '2 days ago'},
                {'action': 'Created project', 'name': 'Website Assets', 'time': '3 days ago'},
              ];
              
              final activity = activities[index];
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(activity['action']!),
                  child: Icon(
                    _getActivityIcon(activity['action']!),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text('${activity['action']} "${activity['name']}"'),
                subtitle: Text(activity['time']!),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getTimeRangeText() {
    switch (_selectedTimeRange) {
      case '7d':
        return 'Last 7 days';
      case '30d':
        return 'Last 30 days';
      case '90d':
        return 'Last 90 days';
      case '1y':
        return 'Last year';
      default:
        return 'Last 7 days';
    }
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

  IconData _getAssetTypeIcon(String type) {
    switch (type) {
      case 'Images':
        return Icons.photo;
      case 'Videos':
        return Icons.videocam;
      case 'Audio':
        return Icons.music_note;
      case 'Documents':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getAssetTypeColor(String type) {
    switch (type) {
      case 'Images':
        return Colors.blue;
      case 'Videos':
        return Colors.red;
      case 'Audio':
        return Colors.green;
      case 'Documents':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String action) {
    switch (action) {
      case 'Created project':
        return Icons.add;
      case 'Uploaded assets':
        return Icons.upload;
      case 'Updated project':
        return Icons.edit;
      case 'Shared project':
        return Icons.share;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String action) {
    switch (action) {
      case 'Created project':
        return Colors.green;
      case 'Uploaded assets':
        return Colors.blue;
      case 'Updated project':
        return Colors.orange;
      case 'Shared project':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 