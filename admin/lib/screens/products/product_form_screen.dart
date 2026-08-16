import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// image_background_remover's real API:
//   await BackgroundRemover.instance.initializeOrt();   // once, before first use
//   ui.Image result = await BackgroundRemover.instance.removeBg(Uint8List imageBytes);
//   BackgroundRemover.instance.dispose();                // when the screen is done with it
import 'package:image_background_remover/image_background_remover.dart';

import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

/// Wraps a newly-picked image so we can track edits (crop / bg-removal)
/// without losing the original file, and so the user can always reset.
class _PendingImage {
  final XFile original;
  File current;
  _PendingImage(this.original) : current = File(original.path);

  bool get isEdited => current.path != original.path;
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _price;
  late TextEditingController _quantity;
  late TextEditingController _lowStockAt;
  int? _categoryId;
  late bool _isActive;

  // Images already on the product (remote URLs) vs newly picked local files.
  // Both are shown side by side; on submit, new files are uploaded and their
  // URLs are appended to whatever existing URLs weren't removed.
  late List<String> _existingImageUrls;
  final List<_PendingImage> _newImages = [];

  // Index into _newImages currently being background-processed, if any.
  int? _bgRemovingIndex;

  // Tracks whether the ONNX runtime has been initialized yet, so we only
  // pay that cost the first time the user actually asks to remove a background.
  bool _bgRemoverReady = false;

  bool _loadingCategories = true;
  String? _categoriesError;
  List<Category> _categories = [];

  bool _isSubmitting = false;
  bool _isDeleting = false;
  String? _errorText;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(0) : '',
    );
    _quantity = TextEditingController(
      text: p != null ? p.stockQuantity.toString() : '0',
    );
    _lowStockAt = TextEditingController(text: (p?.lowStockAt ?? 5).toString());
    _categoryId = p?.categoryId;
    _isActive = p?.isActive ?? true;
    _existingImageUrls = p?.imageUrl != null ? [p!.imageUrl!] : [];
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });
    try {
      final categories = await CategoryService.instance.getAll();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _categoryId ??= categories.isNotEmpty ? categories.first.id : null;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = e.toString();
        _loadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _quantity.dispose();
    _lowStockAt.dispose();
    if (_bgRemoverReady) {
      BackgroundRemover.instance.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      setState(() {
        _newImages.addAll(picked.map((x) => _PendingImage(x)));
      });
    } catch (e) {
      _showSnack('Could not open gallery: $e');
    }
  }

  void _removeExisting(int index) =>
      setState(() => _existingImageUrls.removeAt(index));
  void _removeNew(int index) => setState(() => _newImages.removeAt(index));

  /// Bottom sheet offering optional edits for a newly-picked image.
  /// Nothing here runs automatically — the user chooses crop, remove
  /// background, both, neither, or reset back to the original.
  Future<void> _openEditSheet(int index) async {
    final pending = _newImages[index];

    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Edit photo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSoft,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.crop_rounded),
              title: const Text('Crop'),
              onTap: () => Navigator.pop(context, 'crop'),
            ),
            ListTile(
              leading: const Icon(Icons.auto_fix_high_rounded),
              title: const Text('Remove background'),
              subtitle: const Text('Optional — you can leave the photo as-is'),
              onTap: () => Navigator.pop(context, 'remove_bg'),
            ),
            if (pending.isEdited)
              ListTile(
                leading: const Icon(Icons.undo_rounded),
                title: const Text('Reset to original'),
                onTap: () => Navigator.pop(context, 'reset'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action == null || !mounted) return;

    switch (action) {
      case 'crop':
        await _cropImage(index);
        break;
      case 'remove_bg':
        await _removeBackground(index);
        break;
      case 'reset':
        setState(() => pending.current = File(pending.original.path));
        break;
    }
  }

  Future<void> _cropImage(int index) async {
    if (index >= _newImages.length) return;
    final pending = _newImages[index];
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: pending.current.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop image'),
        ],
      );
      if (cropped == null || !mounted) return;
      setState(() {
        if (index < _newImages.length) {
          _newImages[index].current = File(cropped.path);
        }
      });
    } catch (e) {
      _showSnack('Crop failed: $e');
    }
  }

  /// Converts a ui.Image (as returned by removeBg) into PNG bytes so it
  /// can be written to disk and later uploaded.
  Future<Uint8List> _uiImageToPngBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Could not encode processed image');
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> _removeBackground(int index) async {
    if (index >= _newImages.length) return;
    final pending = _newImages[index];

    setState(() => _bgRemovingIndex = index);
    try {
      if (!_bgRemoverReady) {
        await BackgroundRemover.instance.initializeOrt();
        _bgRemoverReady = true;
      }

      // removeBg expects the raw image bytes, and returns a ui.Image with
      // the background made transparent — not a File and not Uint8List.
      final inputBytes = await pending.current.readAsBytes();
      final ui.Image resultImage = await BackgroundRemover.instance.removeBg(
        inputBytes,
      );
      final pngBytes = await _uiImageToPngBytes(resultImage);

      final outPath =
          '${pending.current.path}_nobg_${DateTime.now().millisecondsSinceEpoch}.png';
      final outFile = File(outPath)..writeAsBytesSync(pngBytes);

      if (!mounted) return;
      setState(() {
        if (index < _newImages.length) {
          _newImages[index].current = outFile;
        }
      });
    } catch (e) {
      if (mounted) _showSnack('Background removal failed: $e');
    } finally {
      if (mounted) setState(() => _bgRemovingIndex = null);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      _showSnack('Add at least one image');
      return;
    }
    if (_categoryId == null) {
      _showSnack('Select a category');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final uploadedUrls = <String>[];
      for (final image in _newImages) {
        uploadedUrls.add(
          await ProductService.instance.uploadImage(image.current),
        );
      }
      final allImageUrls = [..._existingImageUrls, ...uploadedUrls];

      final product = _isEditing
          ? await ProductService.instance.update(
              id: widget.product!.id,
              name: _name.text.trim(),
              description: _description.text.trim(),
              price: double.parse(_price.text.trim()),
              categoryId: _categoryId!,
              imageUrl: allImageUrls,
              isActive: _isActive,
              initialQuantity: int.parse(_quantity.text.trim()),
              lowStockAt: int.parse(_lowStockAt.text.trim()),
            )
          : await ProductService.instance.create(
              name: _name.text.trim(),
              description: _description.text.trim(),
              price: double.parse(_price.text.trim()),
              categoryId: _categoryId!,
              imageUrl: allImageUrls,
              isActive: _isActive,
              initialQuantity: int.parse(_quantity.text.trim()),
              lowStockAt: int.parse(_lowStockAt.text.trim()),
            );

      if (!mounted) return;
      Navigator.of(context).pop(product);
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${widget.product!.name}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await ProductService.instance.delete(widget.product!.id);
      if (!mounted) return;
      Navigator.of(context).pop(widget.product!.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showSnack('Failed to delete: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final busy = _isSubmitting || _isDeleting;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit product' : 'Add product'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.danger,
                      ),
                    )
                  : const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
              onPressed: busy ? null : _confirmDelete,
            ),
        ],
      ),
      body: _loadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _Label('Images'),
                  _ImagePickerRow(
                    existingUrls: _existingImageUrls,
                    newImages: _newImages,
                    processingIndex: _bgRemovingIndex,
                    onAdd: _pickImages,
                    onRemoveExisting: _removeExisting,
                    onRemoveNew: _removeNew,
                    onEditNew: _openEditSheet,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a newly added photo to crop or remove its background — both optional.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.inkFaint),
                  ),
                  const SizedBox(height: 16),
                  if (_categoriesError != null) ...[
                    _ErrorBanner(
                      text: 'Could not load categories: $_categoriesError',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _loadCategories,
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_errorText != null) ...[
                    _ErrorBanner(text: _errorText!),
                    const SizedBox(height: 16),
                  ],
                  _Label('Product name'),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 3212 Ring',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Product name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _Label('Description'),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Short description shown to customers',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Price (₹)'),
                            TextFormField(
                              controller: _price,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(hintText: '0'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Required';
                                if (double.tryParse(v.trim()) == null)
                                  return 'Invalid';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Category'),
                            DropdownButtonFormField<int>(
                              value: _categoryId,
                              isExpanded: true,
                              decoration: const InputDecoration(),
                              items: _categories
                                  .where(
                                    (c) => c.isActive || c.id == _categoryId,
                                  )
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(
                                        c.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _categoryId = v),
                              validator: (v) => v == null ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Stock quantity'),
                            TextFormField(
                              controller: _quantity,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '0'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Required';
                                if (int.tryParse(v.trim()) == null)
                                  return 'Invalid';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Low stock alert at'),
                            TextFormField(
                              controller: _lowStockAt,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: '5'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Required';
                                if (int.tryParse(v.trim()) == null)
                                  return 'Invalid';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeColor: AppColors.primary,
                    title: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Visible to customers on the storefront',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: busy ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Add product'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12.5, color: AppColors.danger),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSoft,
        ),
      ),
    );
  }
}

class _ImagePickerRow extends StatelessWidget {
  final List<String> existingUrls;
  final List<_PendingImage> newImages;
  final int? processingIndex;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveExisting;
  final ValueChanged<int> onRemoveNew;
  final ValueChanged<int> onEditNew;

  const _ImagePickerRow({
    required this.existingUrls,
    required this.newImages,
    required this.onAdd,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.onEditNew,
    this.processingIndex,
  });

  @override
  Widget build(BuildContext context) {
    final total = existingUrls.length + newImages.length;
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: total + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == total) return _AddImageTile(onTap: onAdd);

          if (index < existingUrls.length) {
            return _NetworkImageThumb(
              url: existingUrls[index],
              onRemove: () => onRemoveExisting(index),
            );
          }

          final newIndex = index - existingUrls.length;
          return _FileImageThumb(
            file: newImages[newIndex].current,
            onRemove: () => onRemoveNew(newIndex),
            onTap: () => onEditNew(newIndex),
            isProcessing: processingIndex == newIndex,
          );
        },
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.inkFaint,
                size: 22,
              ),
              SizedBox(height: 4),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.inkFaint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkImageThumb extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;
  const _NetworkImageThumb({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _RemovableThumb(
      onRemove: onRemove,
      child: Image.network(
        url,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 92,
          height: 92,
          color: AppColors.surface,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.inkFaint,
          ),
        ),
      ),
    );
  }
}

/// Thumbnail for a newly-picked local file. Tapping it opens the edit sheet
/// (crop / remove background — both optional). Shows a spinner overlay
/// while background removal is in progress for this image.
class _FileImageThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final bool isProcessing;

  const _FileImageThumb({
    required this.file,
    required this.onRemove,
    required this.onTap,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return _RemovableThumb(
      onRemove: onRemove,
      child: GestureDetector(
        onTap: isProcessing ? null : onTap,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image.file(
              file,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
              // If the file was just replaced (e.g. after crop / bg-removal)
              // this avoids stale caching by keying on the path.
              key: ValueKey(file.path),
            ),
            if (isProcessing)
              Container(
                width: 92,
                height: 92,
                color: Colors.black45,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RemovableThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  const _RemovableThumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: AppColors.ink,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
