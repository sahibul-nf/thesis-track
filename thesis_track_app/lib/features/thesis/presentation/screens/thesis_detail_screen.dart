import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:thesis_track_app/features/thesis/domain/models/thesis_model.dart';

class ThesisDetailScreen extends StatelessWidget {
  final ThesisModel thesis;
  const ThesisDetailScreen({super.key, required this.thesis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thesis Details'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.pencilSimple),
            onPressed: () {
              // TODO: Implement edit thesis functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thesis.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: PhosphorIconsRegular.user,
                      label: 'Student',
                      value: thesis.student.name,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      icon: PhosphorIconsRegular.graduationCap,
                      label: 'Supervisors',
                      value: thesis.supervisors.isNotEmpty ? 
                             thesis.supervisors.map((s) => s.name).join(', ') : 'Not assigned',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      icon: PhosphorIconsRegular.userList,
                      label: 'Examiners',
                      value: thesis.examiners.isNotEmpty ? 
                             thesis.examiners.map((e) => e.name).join(', ') : 'Not assigned',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      icon: PhosphorIconsRegular.books,
                      label: 'Research Field',
                      value: thesis.researchField,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      icon: PhosphorIconsRegular.clock,
                      label: 'Status',
                      value: thesis.status,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      icon: PhosphorIconsRegular.calendar,
                      label: 'Submission Date',
                      value: _formatDate(thesis.submissionDate),
                    ),
                    if (thesis.status == 'Completed') ...[  
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        icon: PhosphorIconsRegular.checkCircle,
                        label: 'Completion Date',
                        value: _formatDate(thesis.updatedAt),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall Progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${_calculateProgress(thesis)}%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _calculateProgress(thesis) / 100,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Abstract',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      thesis.abstract,
                      style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildInfoRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateProgress(ThesisModel thesis) {
    // Calculate progress based on thesis status and other factors
    switch(thesis.status) {
      case 'Pending':
        return 0;
      case 'In Progress':
        return 25;
      case 'Under Review':
        return 75;
      case 'Completed':
        return 100;
      default:
        return 0;
    }
  }
}