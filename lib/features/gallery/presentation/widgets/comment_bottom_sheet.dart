import 'package:flutter/material.dart';
import 'package:luxlog/app/theme.dart';

class CommentBottomSheet extends StatefulWidget {
  final String photoId;
  const CommentBottomSheet({super.key, required this.photoId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final _textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static final _mockComments = [
    ('Sarah K.', 'Absolutely stunning! The bokeh is silky smooth 😍', '2h', true),
    ('Alex M.', 'Which filter did you use? The colors are incredible.', '3h', false),
    ('Rio P.', 'The 35GM is such a phenomenal lens, great shot!', '5h', false),
    ('David J.', 'Is this in Kyoto? Getting huge Japan vibes.', '6h', false),
    ('Lina R.', 'Your tones never miss 🔥', '1d', false),
    ('Mark T.', 'Teach me master!', '2d', false),
  ];

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine bottom padding for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(width: double.infinity),
                Column(
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
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: _mockComments.length,
              itemBuilder: (context, i) {
                final c = _mockComments[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: Text(c.$1[0], style: AppTextStyles.exifData),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(c.$1, style: AppTextStyles.label),
                                const SizedBox(width: 8),
                                Text(c.$3, style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(c.$2, style: AppTextStyles.body),
                            const SizedBox(height: 8),
                            Text('Reply', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          c.$4 ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: c.$4 ? AppColors.error : AppColors.onSurfaceVariant,
                        ),
                        onPressed: () {},
                      )
                    ],
                  ),
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
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: AppTextStyles.bodySmall,
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
                  icon: const Icon(Icons.send),
                  color: AppColors.primary,
                  onPressed: () {
                    if (_textCtrl.text.isNotEmpty) {
                      _textCtrl.clear();
                      _focusNode.unfocus();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
