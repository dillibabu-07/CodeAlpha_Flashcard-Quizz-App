// lib/screens/categories/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/gradient_header.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../providers/auth_provider.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final isAdmin = user?.role == 'Admin';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientHeader(
              colors: const [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFF5B21B6)],
              child: Stack(
                children: [
                  Positioned.fill(child: const HeaderDecoration()),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      MediaQuery.of(context).padding.top + AppSizes.lg,
                      AppSizes.lg,
                      AppSizes.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.count} categories · Organize your learning',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          provider.categories.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.category_rounded,
                    title: 'No Categories Yet',
                    description: isAdmin
                        ? 'Create your first category to start organizing your flashcards'
                        : 'No categories available at the moment.',
                    buttonLabel: isAdmin ? 'Add Category' : null,
                    iconColor: const Color(0xFF7C3AED),
                    onButtonPressed: isAdmin
                        ? () => _showAddCategorySheet(context, provider)
                        : null,
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSizes.md,
                      mainAxisSpacing: AppSizes.md,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = provider.categories[index];
                        return _CategoryCard(
                          category: cat,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CategoryDetailScreen(category: cat),
                            ),
                          ),
                          onEdit: () =>
                              _showAddCategorySheet(context, provider, existing: cat),
                          onDelete: () async {
                            final confirm = await _confirmDelete(context, cat.name);
                            if (confirm == true) {
                              await provider.deleteCategory(cat.id);
                              if (context.mounted) {
                                CustomSnackbar.success(context, '${cat.name} deleted');
                              }
                            }
                          },
                        );
                      },
                      childCount: provider.categories.length,
                    ),
                  ),
                ),

          const SliverPadding(
              padding: EdgeInsets.only(bottom: AppSizes.xxl + AppSizes.lg)),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddCategorySheet(context, provider),
              child: const Icon(Icons.add_rounded),
              tooltip: 'Add Category',
            )
          : null,
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Category',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
            'Delete "$name"? All flashcards in this category will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context, CategoryProvider provider,
      {CategoryModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddCategorySheet(existing: existing, provider: provider),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().currentUser?.isAdmin ?? false;
    final gradientIdx = AppColors.categoryGradients.length;
    final colors = AppColors.categoryGradients[
        category.name.hashCode.abs() % AppColors.categoryGradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        child: Icon(category.icon,
                            color: Colors.white, size: 22),
                      ),
                      if (isAdmin)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: Colors.white, size: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMD),
                          ),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [
                                  Icon(Icons.edit_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ])),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outline_rounded,
                                      size: 16, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: AppColors.error)),
                                ])),
                          ],
                          onSelected: (v) {
                            if (v == 'edit') onEdit();
                            if (v == 'delete') onDelete();
                          },
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.cardCount} card${category.cardCount != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  final CategoryModel? existing;
  final CategoryProvider provider;

  const _AddCategorySheet({this.existing, required this.provider});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  late TextEditingController _nameController;
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existing?.name ?? '');
    if (widget.existing != null) {
      // Try to match icon
      final iconCode = widget.existing!.iconCode;
      final iconIdx = CategoryIcons.options.indexWhere(
          (o) => (o['icon'] as IconData).codePoint == iconCode);
      if (iconIdx != -1) _selectedIconIndex = iconIdx;

      // Try to match color
      final colorHex = widget.existing!.colorHex.toUpperCase();
      final colorIdx = AppColors.categoryColors.indexWhere(
          (c) => c.toHex.toUpperCase() == colorHex);
      if (colorIdx != -1) _selectedColorIndex = colorIdx;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSizes.lg, AppSizes.lg, AppSizes.lg,
          MediaQuery.of(context).viewInsets.bottom + AppSizes.lg),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              isEdit ? 'Edit Category' : 'New Category',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Java, Python, Math...',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Category name is required'
                  : null,
              autofocus: true,
            ),
            const SizedBox(height: AppSizes.md),
            Text('Icon', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSizes.xs),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CategoryIcons.options.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final opt = CategoryIcons.options[i];
                  final selected = i == _selectedIconIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Icon(
                        opt['icon'] as IconData,
                        color: selected ? Colors.white : null,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Color', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSizes.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.categoryColors.asMap().entries.map((e) {
                final selected = e.key == _selectedColorIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: e.value, width: 3)
                          : Border.all(color: Colors.transparent, width: 3),
                      boxShadow: selected
                          ? [BoxShadow(color: e.value.withOpacity(0.5), blurRadius: 8)]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Save Changes' : 'Create Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final icon = CategoryIcons.options[_selectedIconIndex]['icon'] as IconData;
    final color = AppColors.categoryColors[_selectedColorIndex];

    final category = CategoryModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      iconCode: icon.codePoint,
      colorHex: color.toHex,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing != null) {
      await widget.provider.updateCategory(category);
    } else {
      await widget.provider.addCategory(category);
    }

    if (mounted) Navigator.pop(context);
  }
}

extension _ColorHex on Color {
  String get toHex =>
      '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
}
