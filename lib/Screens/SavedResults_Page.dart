import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Services/results_repository.dart';
import '../models/bmi_result.dart';
import '../constants.dart';
import '../Widgets/app_ui.dart';
import 'Results_Page.dart';

class SavedResultsPage extends StatefulWidget {
  const SavedResultsPage({super.key});

  @override
  State<SavedResultsPage> createState() => _SavedResultsPageState();
}

class _SavedResultsPageState extends State<SavedResultsPage> with SingleTickerProviderStateMixin {
  List<BMIResult> _results = [];
  bool _loading = true;
  bool _showDeletedMessage = false;
  late final AnimationController _popupShakeController;
  late final Animation<double> _popupShakeAnimation;

  @override
  void initState() {
    super.initState();
    _popupShakeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _popupShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _popupShakeController, curve: Curves.easeInOut));
    _loadResults();
  }

  @override
  void dispose() {
    _popupShakeController.dispose();
    super.dispose();
  }

  void _showDeletedPopup() {
    HapticFeedback.lightImpact();
    setState(() => _showDeletedMessage = true);
    _popupShakeController.forward(from: 0);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showDeletedMessage = false);
        _popupShakeController.reset();
      }
    });
  }

  Future<void> _loadResults() async {
    final local = await ResultsRepository.instance.getLocalResults();
    if (!mounted) return;
    setState(() {
      _results = local;
      _loading = false;
    });

    final synced = await ResultsRepository.instance.trySyncFromRemote();
    if (!mounted || synced == null) return;
    setState(() => _results = synced);
  }

  Future<void> _deleteResult(BMIResult result) async {
    final previous = List<BMIResult>.from(_results);
    setState(() {
      _results.removeWhere((r) => ResultsRepository.instance.matches(r, result));
    });

    // Show the deleted notification immediately so the UI feels responsive.
    if (mounted) {
      _showDeletedPopup();
    }

    try {
      await ResultsRepository.instance.deleteResult(result);
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
      await ResultsRepository.instance.clearResults();
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
    final colors = context.colors;

    return AppScaffold(
      title: 'History',
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_results.isNotEmpty)
          IconButton(
            tooltip: 'Clear all',
            icon: Icon(Icons.delete_sweep_outlined, color: colors.textPrimary),
            onPressed: _showClearDialog,
          ),
        IconButton(
          tooltip: 'Home',
          icon: Icon(Icons.home_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        AppSpacing.gapH(context, 4),
      ],
      body: _loading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : Stack(
              clipBehavior: Clip.none,
              children: [
                _results.isEmpty ? _buildEmptyState(padding) : _buildList(padding),
                if (_showDeletedMessage)
                  Positioned(
                    top: 0,
                    left: padding,
                    right: padding,
                    child: AnimatedBuilder(
                      animation: _popupShakeAnimation,
                      builder: (context, _) => AppToastBanner(
                        message: 'Deleted',
                        shakeOffset: _popupShakeAnimation.value,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(double padding) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: AppSpacing.icon(context, 72),
              color: colors.textMuted.withValues(alpha: 0.5),
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
    final colors = context.colors;
    final items = [..._results.reversed];

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppSpacing.contentMaxWidth(context)),
        child: ListView.separated(
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
            padding: EdgeInsets.only(right: AppSpacing.scale(context, 20)),
            decoration: BoxDecoration(
              color: colors.danger.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppSpacing.radius(context, 20)),
            ),
            child: Icon(Icons.delete_outline, color: colors.onPrimary),
          ),
          onDismissed: (_) => _deleteResult(result),
          child: _HistoryTile(
            result: result,
            onTap: () => _openResult(result),
            onDelete: () => _deleteResult(result),
          ),
        );
      },
        ),
      ),
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
            child: Text('Clear all', style: TextStyle(color: context.colors.danger)),
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
    final colors = context.colors;
    final color = result.status == 'NORMAL'
        ? colors.success
        : result.status == 'UNDERWEIGHT'
            ? colors.warning
            : colors.danger;
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
                borderRadius: BorderRadius.circular(AppSpacing.radius(context, 12)),
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
                                  color: colors.primaryDark,
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
            color: colors.textOnCardMuted,
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
