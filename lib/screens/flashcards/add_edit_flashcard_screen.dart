// lib/screens/flashcards/add_edit_flashcard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../models/flashcard_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/common/difficulty_badge.dart';
import '../../utils/extensions.dart';

class AddEditFlashcardScreen extends StatefulWidget {
  final FlashcardModel? card;
  final String? preselectedCategoryId;

  const AddEditFlashcardScreen({super.key, this.card, this.preselectedCategoryId});

  @override
  State<AddEditFlashcardScreen> createState() => _AddEditFlashcardScreenState();
}

class _AddEditFlashcardScreenState extends State<AddEditFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionCtrl;
  late TextEditingController _answerCtrl;
  late TextEditingController _tagsCtrl;

  String? _selectedCategoryId;
  Difficulty _difficulty = Difficulty.medium;
  bool _isFavorite = false;
  bool _isSaving = false;
  List<String> _tags = [];

  bool get _isEdit => widget.card != null;

  @override
  void initState() {
    super.initState();
    final card = widget.card;
    _questionCtrl = TextEditingController(text: card?.question ?? '');
    _answerCtrl = TextEditingController(text: card?.answer ?? '');
    _tagsCtrl = TextEditingController();
    _selectedCategoryId = card?.categoryId ?? widget.preselectedCategoryId;
    _difficulty = card?.difficulty ?? Difficulty.medium;
    _isFavorite = card?.isFavorite ?? false;
    _tags = List.from(card?.tags ?? []);
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Flashcard' : 'New Flashcard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(
                _isEdit ? 'Save' : 'Add',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            // Question
            _SectionLabel(label: 'Question *'),
            const SizedBox(height: AppSizes.xs),
            TextFormField(
              controller: _questionCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your question...',
                alignLabelWithHint: true,
              ),
              validator: Validators.questionValidator,
            ),
            const SizedBox(height: AppSizes.md),

            // Answer
            _SectionLabel(label: 'Answer *'),
            const SizedBox(height: AppSizes.xs),
            TextFormField(
              controller: _answerCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter the answer...',
                alignLabelWithHint: true,
              ),
              validator: Validators.answerValidator,
            ),
            const SizedBox(height: AppSizes.md),

            // Category
            _SectionLabel(label: 'Category *'),
            const SizedBox(height: AppSizes.xs),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              hint: const Text('Select a category'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: catProvider.categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 18, color: cat.color),
                      const SizedBox(width: 8),
                      Text(cat.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
              validator: (v) => v == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: AppSizes.md),

            // Difficulty
            _SectionLabel(label: 'Difficulty'),
            const SizedBox(height: AppSizes.xs),
            Row(
              children: Difficulty.values.map((d) {
                final selected = _difficulty == d;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _difficulty = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? d.bgColor
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(
                            color: selected ? d.color : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(child: DifficultyBadge(difficulty: d)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.md),

            // Tags
            _SectionLabel(label: 'Tags'),
            const SizedBox(height: AppSizes.xs),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagsCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag...',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                    onFieldSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _addTag(_tagsCtrl.text),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    labelStyle: GoogleFonts.inter(fontSize: 12),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: AppSizes.md),

            // Favorite toggle
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md, vertical: AppSizes.sm),
              decoration: BoxDecoration(
                color: _isFavorite
                    ? Colors.red.withOpacity(0.06)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(
                  color: _isFavorite
                      ? Colors.red.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Add to Favorites',
                  style:
                      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                secondary: Icon(
                  _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFavorite ? Colors.red : null,
                ),
                value: _isFavorite,
                onChanged: (v) => setState(() => _isFavorite = v),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Save button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: Icon(_isEdit ? Icons.save_rounded : Icons.add_rounded),
                label: Text(_isEdit ? 'Save Changes' : 'Add Flashcard'),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  void _addTag(String value) {
    final tag = value.trim().toLowerCase().replaceAll(' ', '-');
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagsCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<FlashcardProvider>();
      final now = DateTime.now();

      final card = FlashcardModel(
        id: widget.card?.id ?? const Uuid().v4(),
        question: _questionCtrl.text.trim(),
        answer: _answerCtrl.text.trim(),
        categoryId: _selectedCategoryId!,
        difficulty: _difficulty,
        tags: _tags,
        isFavorite: _isFavorite,
        createdAt: widget.card?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEdit) {
        await provider.updateFlashcard(card);
        if (mounted) CustomSnackbar.success(context, 'Flashcard updated!');
      } else {
        await provider.addFlashcard(card);
        if (mounted) CustomSnackbar.success(context, 'Flashcard added!');
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) CustomSnackbar.error(context, 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        letterSpacing: 0.3,
      ),
    );
  }
}
