import 'dart:io';

import 'package:flutter/material.dart';
import '../Services/results_storage.dart';
import '../constants.dart';
import '../Widgets/app_ui.dart';
import 'Results_Page.dart';

class SavedResultsPage extends StatefulWidget {
  const SavedResultsPage({Key? key}) : super(key: key);

  @override
  State<SavedResultsPage> createState() => _SavedResultsPageState();
}

class _SavedResultsPageState extends State<SavedResultsPage> {
  List<BMIResult> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final results = await ResultsStorage.getResults();
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  Future<void> _deleteResult(BMIResult result) async {
    final previous = List<BMIResult>.from(_results);
    setState(() {
      _results.removeWhere((r) => ResultsStorage.matches(r, result));
    });

    try {
      await ResultsStorage.deleteResult(result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _results = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete. Please try again.')),
      );
    }
  }

  Future<void> _clearAll() async {
    final previous = List<BMIResult>.from(_results);
    setState(() => _results = []);

    try {
      await ResultsStorage.clearResults();
    } catch (_) {
      if (!mounted) return;
      setState(() => _results = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not clear history. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.page(context);

    return AppScaffold(
      title: 'History',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_results.isNotEmpty)
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textPrimary),
            onPressed: _showClearDialog,
          ),
        IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        const SizedBox(width: 4),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _results.isEmpty
              ? _buildEmptyState(padding)
              : _buildList(padding),
    );
  }

  Widget _buildEmptyState(double padding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: AppSpacing.icon(context, 72),
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            AppSpacing.gap(context, 20),
            Text('No history yet', style: AppText.headline(context)),
            AppSpacing.gap(context, 8),
            Text(
              'Save a BMI result to see it here.',
              style: AppText.body(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(double padding) {
    final items = [..._results.reversed];

    return ListView.separated(
      padding: EdgeInsets.all(padding),
      itemCount: items.length,
      separatorBuilder: (_, __) => AppSpacing.gap(context, 12),
      itemBuilder: (context, index) {
        final result = items[index];
        return Dismissible(
          key: ValueKey(result.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => _deleteResult(result),
          child: _HistoryTile(
            result: result,
            onTap: () => _openResult(result),
            onDelete: () => _deleteResult(result),
          ),
        );
      },
    );
  }

  void _openResult(BMIResult result) {
    File? profileImage;
    if (result.profileImagePath.isNotEmpty && File(result.profileImagePath).existsSync()) {
      profileImage = File(result.profileImagePath);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          bmi: result.bmi,
          name: result.name,
          age: result.age,
          resultText: result.status,
          advise: result.advice,
          height: result.height,
          weight: result.weight,
          bmiValue: result.bmiBmi,
          normalWeightRange: result.normalWeightRange,
          isSavedResult: true,
          profileImage: profileImage,
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all history?'),
        content: Text('This cannot be undone.', style: AppText.cardBody(context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _clearAll();
            },
            child: const Text('Clear all', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.result,
    required this.onTap,
    required this.onDelete,
  });

  final BMIResult result;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = result.status == 'NORMAL'
        ? AppColors.success
        : result.status == 'UNDERWEIGHT'
            ? AppColors.warning
            : AppColors.danger;
    final hasImage = result.profileImagePath.isNotEmpty && File(result.profileImagePath).existsSync();

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(AppSpacing.scale(context, 16)),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    if (hasImage) ...[
                      CircleAvatar(
                        radius: AppSpacing.scale(context, 24),
                        backgroundImage: FileImage(File(result.profileImagePath)),
                      ),
                      AppSpacing.gapH(context, 14),
                    ] else
                      Container(
                        width: AppSpacing.scale(context, 48),
                        height: AppSpacing.scale(context, 48),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radius(context, 14)),
                        ),
                        child: Icon(
                          Icons.monitor_weight_outlined,
                          color: color,
                          size: AppSpacing.icon(context, 24),
                        ),
                      ),
                    AppSpacing.gapH(context, 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (result.name.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: AppSpacing.icon(context, 18),
                                  color: AppColors.primaryDark,
                                ),
                                AppSpacing.gapH(context, 6),
                                Expanded(
                                  child: Text(
                                    result.name,
                                    style: AppText.cardHeadline(context).copyWith(
                                      fontSize: AppText.scale(context, 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gap(context, 6),
                          ],
                          Text('BMI ${result.bmi}', style: AppText.cardHeadline(context)),
                          AppSpacing.gap(context, 4),
                          StatusBadge(label: result.status, color: color),
                          AppSpacing.gap(context, 6),
                          Text(_formatDate(result.savedDate), style: AppText.cardLabel(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: Icon(Icons.close_rounded, size: AppSpacing.icon(context, 20)),
            color: AppColors.textOnCardMuted,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'am' : 'pm';

    return '${date.day} ${months[date.month - 1]} ${date.year} $hour:$minute $period';
  }
}
