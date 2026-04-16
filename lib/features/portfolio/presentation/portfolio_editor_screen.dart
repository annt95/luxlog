import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luxlog/app/theme.dart';

/// Module 3: Portfolio Editor — drag-reorder project blocks
class PortfolioEditorScreen extends StatefulWidget {
  final String projectId;
  const PortfolioEditorScreen({super.key, required this.projectId});

  @override
  State<PortfolioEditorScreen> createState() => _PortfolioEditorScreenState();
}

class _PortfolioEditorScreenState extends State<PortfolioEditorScreen> {
  final _titleCtrl = TextEditingController(text: 'Tokyo After Rain');
  final _descCtrl = TextEditingController(
      text: 'A documentary series capturing the streets of Tokyo on rainy nights.');
  bool _isPublic = true;
  bool _unsaved = false;

  // Blocks represent the portfolio sections
  final List<_Block> _blocks = [
    _Block(type: _BlockType.coverImage, content: 'https://picsum.photos/seed/cover/800/400'),
    _Block(type: _BlockType.text, content: 'The rain transforms the city into something otherworldly. Reflections multiply, neon smears, and strangers become silhouettes.'),
    _Block(type: _BlockType.photoGrid, content: '3'),
    _Block(type: _BlockType.text, content: 'Shot over 3 nights with the Sony α7 IV and the 35mm GM. ISO pushed to 3200 to keep the shutter fast enough to freeze the rain.'),
    _Block(type: _BlockType.photoGrid, content: '2'),
    _Block(type: _BlockType.divider, content: ''),
    _Block(type: _BlockType.contactForm, content: 'Hire Me'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addBlock(_BlockType type) {
    setState(() {
      _blocks.add(_Block(type: type, content: type == _BlockType.photoGrid ? '3' : ''));
      _unsaved = true;
    });
    Navigator.of(context).pop(); // close bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Editor AppBar ────────────────────────────────
          _EditorAppBar(
            title: _titleCtrl.text,
            isPublic: _isPublic,
            unsaved: _unsaved,
            onPublicToggle: () => setState(() => _isPublic = !_isPublic),
            onSave: _save,
            onPreview: _preview,
          ),

          // ── Two-panel layout ──────────────────────────────
          Expanded(
            child: Row(
              children: [
                // Left: blocks toolbar
                _BlocksToolbar(onAdd: _showAddMenu),

                // Main canvas
                Expanded(
                  child: _EditorCanvas(
                    titleCtrl: _titleCtrl,
                    descCtrl: _descCtrl,
                    blocks: _blocks,
                    onReorder: (oldIdx, newIdx) {
                      setState(() {
                        if (newIdx > oldIdx) newIdx--;
                        final item = _blocks.removeAt(oldIdx);
                        _blocks.insert(newIdx, item);
                        _unsaved = true;
                      });
                    },
                    onDelete: (idx) => setState(() {
                      _blocks.removeAt(idx);
                      _unsaved = true;
                    }),
                    onContentChange: (idx, val) => setState(() {
                      _blocks[idx] = _Block(type: _blocks[idx].type, content: val);
                      _unsaved = true;
                    }),
                  ),
                ),

                // Right: properties panel
                _PropertiesPanel(
                  titleCtrl: _titleCtrl,
                  descCtrl: _descCtrl,
                  isPublic: _isPublic,
                  onPublicToggle: () => setState(() => _isPublic = !_isPublic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (ctx) => _AddBlockSheet(onAdd: _addBlock),
    );
  }

  void _save() => setState(() => _unsaved = false);

  void _preview() {
    // TODO: navigate to public portfolio view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preview mode coming soon'),
        backgroundColor: AppColors.surfaceContainerHigh,
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

enum _BlockType { coverImage, text, photoGrid, divider, contactForm }

class _Block {
  final _BlockType type;
  final String content;
  const _Block({required this.type, required this.content});
}

// ── Editor AppBar ─────────────────────────────────────────────────────────────

class _EditorAppBar extends StatelessWidget {
  final String title;
  final bool isPublic;
  final bool unsaved;
  final VoidCallback onPublicToggle;
  final VoidCallback onSave;
  final VoidCallback onPreview;

  const _EditorAppBar({
    required this.title,
    required this.isPublic,
    required this.unsaved,
    required this.onPublicToggle,
    required this.onSave,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: AppColors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  if (unsaved)
                    Text('Unsaved changes',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        )),
                ],
              ),
            ),
            // Visibility chip
            GestureDetector(
              onTap: onPublicToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPublic
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPublic ? Icons.public : Icons.lock_outline,
                      size: 14,
                      color: isPublic ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPublic ? 'Public' : 'Draft',
                      style: AppTextStyles.exifData.copyWith(
                        color: isPublic ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onPreview,
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('Preview'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined, size: 14),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Blocks Toolbar ───────────────────────────────────────────────────────────

class _BlocksToolbar extends StatelessWidget {
  final VoidCallback onAdd;
  const _BlocksToolbar({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      color: AppColors.surfaceContainerLow,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _ToolbarBtn(
            icon: Icons.add,
            label: 'Add',
            onTap: onAdd,
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          _ToolbarBtn(icon: Icons.title, label: 'Text', onTap: onAdd),
          _ToolbarBtn(icon: Icons.image_outlined, label: 'Photo', onTap: onAdd),
          _ToolbarBtn(icon: Icons.grid_on_outlined, label: 'Grid', onTap: onAdd),
          _ToolbarBtn(icon: Icons.horizontal_rule, label: 'Divider', onTap: onAdd),
        ],
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ToolbarBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isPrimary ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Editor Canvas ─────────────────────────────────────────────────────────────

class _EditorCanvas extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final List<_Block> blocks;
  final Function(int, int) onReorder;
  final Function(int) onDelete;
  final Function(int, String) onContentChange;

  const _EditorCanvas({
    required this.titleCtrl,
    required this.descCtrl,
    required this.blocks,
    required this.onReorder,
    required this.onDelete,
    required this.onContentChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLowest,
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: blocks.length,
        onReorder: onReorder,
        itemBuilder: (context, i) {
          final block = blocks[i];
          return _BlockWidget(
            key: ValueKey('block_$i'),
            block: block,
            index: i,
            onDelete: () => onDelete(i),
            onContentChange: (val) => onContentChange(i, val),
          );
        },
      ),
    );
  }
}

class _BlockWidget extends StatelessWidget {
  final _Block block;
  final int index;
  final VoidCallback onDelete;
  final ValueChanged<String> onContentChange;

  const _BlockWidget({
    super.key,
    required this.block,
    required this.index,
    required this.onDelete,
    required this.onContentChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Block content
          _buildBlockContent(context),
          // Delete button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 30)).fadeIn();
  }

  Widget _buildBlockContent(BuildContext context) {
    switch (block.type) {
      case _BlockType.coverImage:
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AspectRatio(
            aspectRatio: 16 / 7,
            child: CachedNetworkImage(
              imageUrl: block.content,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceContainerHigh),
            ),
          ),
        );

      case _BlockType.text:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
            border: const Border(
              left: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          child: TextField(
            controller: TextEditingController(text: block.content),
            maxLines: null,
            style: AppTextStyles.body.copyWith(height: 1.6),
            onChanged: onContentChange,
            decoration: const InputDecoration(
              hintText: 'Write something...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        );

      case _BlockType.photoGrid:
        final cols = int.tryParse(block.content) ?? 3;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(Icons.grid_on_outlined,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Photo Grid · $cols columns',
                        style: AppTextStyles.exifLabel.copyWith(
                          color: AppColors.primary,
                        )),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: cols * 2,
                itemBuilder: (ctx, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: CachedNetworkImage(
                    imageUrl: 'https://picsum.photos/seed/grid_${block.content}_$i/300/300',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        );

      case _BlockType.divider:
        return Container(
          height: 40,
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(child: Container(height: 1, color: AppColors.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('§', style: AppTextStyles.exifData.copyWith(color: AppColors.primary)),
              ),
              Expanded(child: Container(height: 1, color: AppColors.outlineVariant)),
            ],
          ),
        );

      case _BlockType.contactForm:
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Text('Contact Form', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text('Clients can reach you through this block.',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Hire Me',
                    style: AppTextStyles.label.copyWith(color: AppColors.onPrimary)),
              ),
            ],
          ),
        );
    }
  }
}

// ── Properties Panel ──────────────────────────────────────────────────────────

class _PropertiesPanel extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final bool isPublic;
  final VoidCallback onPublicToggle;

  const _PropertiesPanel({
    required this.titleCtrl,
    required this.descCtrl,
    required this.isPublic,
    required this.onPublicToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Properties',
                style: AppTextStyles.label.copyWith(
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                )),
            const SizedBox(height: 16),

            Text('Project Title', style: AppTextStyles.exifLabel),
            const SizedBox(height: 6),
            TextField(
              controller: titleCtrl,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'Project name',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),

            Text('Description', style: AppTextStyles.exifLabel),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'Tell the story behind this project...',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),

            Text('Category', style: AppTextStyles.exifLabel),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: DropdownButton<String>(
                value: 'Street Documentary',
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.surfaceContainerHigh,
                style: AppTextStyles.body,
                items: const [
                  DropdownMenuItem(value: 'Street Documentary', child: Text('Street Documentary')),
                  DropdownMenuItem(value: 'Portrait Series', child: Text('Portrait Series')),
                  DropdownMenuItem(value: 'Landscape', child: Text('Landscape')),
                  DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
                ],
                onChanged: (_) {},
              ),
            ),

            const SizedBox(height: 20),
            const _Divider(),

            const SizedBox(height: 16),
            Text('Analytics', style: AppTextStyles.exifLabel),
            const SizedBox(height: 10),
            _StatsRow(label: 'Views', value: '2,847', icon: Icons.visibility_outlined),
            const SizedBox(height: 6),
            _StatsRow(label: 'Likes', value: '341', icon: Icons.favorite_border),
            const SizedBox(height: 6),
            _StatsRow(label: 'Inquiries', value: '12', icon: Icons.mail_outline),

            const SizedBox(height: 20),
            const _Divider(),

            const SizedBox(height: 16),
            Text('Danger Zone', style: AppTextStyles.exifLabel.copyWith(color: AppColors.error)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                label: const Text('Delete Project'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.outlineVariant);
}

class _StatsRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatsRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.exifLabel),
        const Spacer(),
        Text(value, style: AppTextStyles.exifData.copyWith(color: AppColors.onSurface)),
      ],
    );
  }
}

// ── Add Block Sheet ──────────────────────────────────────────────────────────

class _AddBlockSheet extends StatelessWidget {
  final void Function(_BlockType) onAdd;
  const _AddBlockSheet({required this.onAdd});

  static const _options = [
    (icon: Icons.title, label: 'Text Block', type: _BlockType.text),
    (icon: Icons.grid_on_outlined, label: 'Photo Grid', type: _BlockType.photoGrid),
    (icon: Icons.horizontal_rule, label: 'Section Divider', type: _BlockType.divider),
    (icon: Icons.mail_outline, label: 'Contact Form', type: _BlockType.contactForm),
    (icon: Icons.image_outlined, label: 'Cover Image', type: _BlockType.coverImage),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Add Block', style: AppTextStyles.titleMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._options.map((opt) => ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(opt.icon, color: AppColors.primary, size: 18),
            ),
            title: Text(opt.label, style: AppTextStyles.label),
            onTap: () => onAdd(opt.type),
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }
}
