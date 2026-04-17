import 'dart:async';
import 'package:flutter/material.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/tag_chip.dart';

/// Chip-based tag input with autocomplete dropdown
class TagInputWidget extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final Future<List<String>> Function(String query)? onSearch;

  const TagInputWidget({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    this.onSearch,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _suggestions = [];
  Timer? _debounce;
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();

    // Check for comma or space to create tag
    if (value.endsWith(',') || value.endsWith(' ')) {
      final tagName = value.substring(0, value.length - 1).trim();
      if (tagName.isNotEmpty) {
        _addTag(tagName);
      }
      return;
    }

    // Debounced search
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (value.trim().isEmpty) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
        return;
      }

      if (widget.onSearch != null) {
        final results = await widget.onSearch!(value.trim());
        if (mounted) {
          setState(() {
            _suggestions = results.where((s) => !widget.tags.contains(s)).toList();
            _showSuggestions = _suggestions.isNotEmpty;
          });
        }
      }
    });
  }

  void _addTag(String tag) {
    final cleanTag = tag.trim().toLowerCase().replaceAll('#', '');
    if (cleanTag.isEmpty || widget.tags.contains(cleanTag)) return;

    final newTags = [...widget.tags, cleanTag];
    widget.onTagsChanged(newTags);
    _controller.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  void _removeTag(String tag) {
    final newTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(newTags);
  }

  void _onSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      _addTag(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags display
        if (widget.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.tags
                  .map((tag) => TagChip(
                        tagName: tag,
                        onRemove: () => _removeTag(tag),
                      ))
                  .toList(),
            ),
          ),

        // Input field
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            onSubmitted: _onSubmitted,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              hintText: 'Thêm tag... (dấu phẩy hoặc Enter để tạo)',
              prefixIcon: Icon(Icons.tag, size: 18, color: AppColors.onSurfaceVariant),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Autocomplete suggestions
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, i) {
                final suggestion = _suggestions[i];
                return InkWell(
                  onTap: () => _addTag(suggestion),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.tag, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(suggestion, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
