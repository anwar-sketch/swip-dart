import 'package:flutter/material.dart';
import '../controller/swip_controller.dart';

class SwipPage extends StatefulWidget {
  final SwipController controller;
  final VoidCallback? onMenuPressed;

  const SwipPage({
    super.key,
    required this.controller,
    this.onMenuPressed,
  });

  @override
  State<SwipPage> createState() => _SwipPageState();
}

class _SwipPageState extends State<SwipPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: widget.onMenuPressed ??
                  () {
                    Scaffold.of(context).openDrawer();
                  },
            ),
            title: const Text('SWIP SDK'),
            actions: [
              if (widget.controller.isSessionActive)
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: widget.controller.stopSession,
                  tooltip: 'Stop Session',
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SDK Status Card
                Card(
                  color: widget.controller.isInitialized
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              widget.controller.isInitialized
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              color: widget.controller.isInitialized
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SWIP SDK Status',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.controller.status,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  if (widget.controller.isSessionActive) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timer,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDuration(
                                              widget.controller.elapsedTime),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (widget.controller.error.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.controller.error,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Current Session - Real-time Score Display
                if (widget.controller.isSessionActive) ...[
                  // SWIP Score Card (Large Display)
                  if (widget.controller.currentScore != null) ...[
                    Card(
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getScoreColor(
                                      widget.controller.currentScore!.swipScore)
                                  .withOpacity(0.1),
                              _getScoreColor(
                                      widget.controller.currentScore!.swipScore)
                                  .withOpacity(0.05),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              'Current SWIP Score',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.controller.currentScore!.swipScore
                                  .toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(widget
                                        .controller.currentScore!.swipScore),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getScoreLabel(
                                  widget.controller.currentScore!.swipScore),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 16),
                            // Score Breakdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildEmotionMetric(
                                  widget
                                      .controller.currentScore!.dominantEmotion,
                                  widget.controller.currentScore!.emoSubscore,
                                ),
                                _buildScoreMetric(
                                  'Confidence',
                                  widget.controller.currentScore!.confidence,
                                  Icons.verified,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Current Emotion Display
                  if (widget.controller.currentEmotion != null) ...[
                    Card(
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getEmotionColor(
                                      widget.controller.currentEmotion!.emotion)
                                  .withOpacity(0.1),
                              _getEmotionColor(
                                      widget.controller.currentEmotion!.emotion)
                                  .withOpacity(0.05),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getEmotionIcon(
                                  widget.controller.currentEmotion!.emotion),
                              size: 32,
                              color: _getEmotionColor(
                                  widget.controller.currentEmotion!.emotion),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.controller.currentEmotion!.emotion,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _getEmotionColor(widget
                                            .controller
                                            .currentEmotion!
                                            .emotion),
                                      ),
                                ),
                                Text(
                                  '${(widget.controller.currentEmotion!.confidence * 100).toStringAsFixed(1)}% confidence',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Session Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Session',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (widget.controller.sessionStartTime != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Duration: ${_formatDuration(DateTime.now().difference(widget.controller.sessionStartTime!))}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (widget.controller.activeSessionId != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.tag, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Session ID: ${widget.controller.activeSessionId}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: widget.controller.stopSession,
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop Session'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  // No Active Session
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Active Session',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a SWIP session to measure wellness impact in real-time',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: widget.controller.isInitialized
                                ? widget.controller.startSession
                                : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Session'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Session History
                Row(
                  children: [
                    Text(
                      'Session History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: widget.controller.loadSessionHistory,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.controller.sessionHistory.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No session history',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start sessions to see your wellness impact over time',
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...widget.controller.sessionHistory.map((session) {
                    final summary = session.getSummary();
                    final avgScore =
                        summary['average_swip_score'] as double? ?? 0.0;
                    final duration = summary['duration_seconds'] as int? ?? 0;
                    final dominantEmotion =
                        summary['dominant_emotion'] as String? ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getScoreColor(avgScore).withOpacity(0.2),
                          child: Text(
                            avgScore.toStringAsFixed(0),
                            style: TextStyle(
                              color: _getScoreColor(avgScore),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'Session ${session.sessionId.substring(0, 8)}...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.startTime
                                  .toLocal()
                                  .toString()
                                  .substring(0, 19),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _getEmotionIcon(dominantEmotion),
                                  size: 14,
                                  color: _getEmotionColor(dominantEmotion),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dominantEmotion,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.timer, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(Duration(seconds: duration)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreMetric(String label, double value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          (value * 100).toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionMetric(String emotion, double? emoSubscore) {
    return Column(
      children: [
        Icon(
          _getEmotionIcon(emotion),
          size: 24,
          color: _getEmotionColor(emotion),
        ),
        const SizedBox(height: 4),
        Text(
          emotion,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getEmotionColor(emotion),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Emotion',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) {
      return Colors.green;
    } else if (score >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getScoreLabel(double score) {
    if (score >= 80) {
      return 'Excellent Wellness';
    } else if (score >= 70) {
      return 'Good Wellness';
    } else if (score >= 60) {
      return 'Neutral';
    } else if (score >= 40) {
      return 'Mild Stress';
    } else {
      return 'High Stress';
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'calm':
      case 'baseline':
        return Colors.green;
      case 'stressed':
      case 'stress':
        return Colors.red;
      case 'amused':
      case 'amusement':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'calm':
      case 'baseline':
        return Icons.spa;
      case 'stressed':
      case 'stress':
        return Icons.warning;
      case 'amused':
      case 'amusement':
        return Icons.mood;
      default:
        return Icons.favorite;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

