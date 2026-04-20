import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final String photoId;
  const CommentBottomSheet({super.key, required this.photoId});

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final _textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _sending = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final repo = ref.read(photoRepositoryProvider);
      await repo.addComment(widget.photoId, text);
      _textCtrl.clear();
      _focusNode.unfocus();
      // Refresh photo detail to get new comments
      ref.invalidate(photoDetailProvider(widget.photoId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final photoAsync = ref.watch(photoDetailProvider(widget.photoId));
    final comments = photoAsync.whenData<List<dynamic>>((photo) {
      return (photo['comments'] as List<dynamic>?) ?? [];
    });

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Comments', style: AppTextStyles.titleMedium),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: comments.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, __) => const Center(child: Text('Failed to load comments')),
              data: (commentList) {
                if (commentList.isEmpty) {
                  return const Center(
                    child: Text('No comments yet. Be the first!', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: commentList.length,
                  itemBuilder: (context, i) {
                    final c = commentList[i] as Map<String, dynamic>;
                    final cProfile = c['profiles'] as Map<String, dynamic>?;
                    final name = cProfile?['full_name'] as String? ?? cProfile?['username'] as String? ?? 'User';
                    final text = c['text'] as String? ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            child: Text(name.isNotEmpty ? name[0] : 'U', style: AppTextStyles.exifData),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: AppTextStyles.label),
                                const SizedBox(height: 2),
                                Text(text, style: AppTextStyles.body),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text('U', style: AppTextStyles.exifData.copyWith(color: AppColors.primary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    focusNode: _focusNode,
                    style: AppTextStyles.body,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: AppTextStyles.bodySmall,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerHigh,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _sending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      : const Icon(Icons.send),
                  color: AppColors.primary,
                  onPressed: _sendComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
