import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Only relative filenames are persisted: the iOS app container can move.
class PhotoStore {
  final Future<Directory> Function() directoryProvider;
  PhotoStore({Future<Directory> Function()? directoryProvider})
    : directoryProvider = directoryProvider ?? getApplicationDocumentsDirectory;
  static final instance = PhotoStore();

  Future<File> file(String filename) async {
    if (!RegExp(r'^photo_[a-zA-Z0-9_]+\.[a-zA-Z0-9]+$').hasMatch(filename)) {
      throw const FormatException('Invalid photo filename');
    }
    return File('${(await directoryProvider()).path}/photos/$filename');
  }

  Future<String> importPhoto(XFile image) async {
    final suffix = image.path.split('.').last.toLowerCase();
    final extension = ['jpg', 'jpeg', 'png', 'heic', 'webp'].contains(suffix)
        ? suffix
        : 'jpg';
    final filename =
        'photo_${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}.$extension';
    final target = await file(filename);
    await target.parent.create(recursive: true);
    try {
      await image.saveTo(target.path);
      return filename;
    } catch (_) {
      await remove(filename);
      rethrow;
    }
  }

  Future<void> remove(String? filename) async {
    if (filename == null) return;
    try {
      final target = await file(filename);
      if (await target.exists()) await target.delete();
    } on FileSystemException {
      // A failed cleanup must not undo an already saved record.
    } on FormatException {
      // Never delete a path outside our own photo directory.
    }
  }
}

class SavedPhoto extends StatelessWidget {
  final String filename;
  final double height;
  const SavedPhoto(this.filename, {super.key, this.height = 180});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: FutureBuilder<File>(
        future: PhotoStore.instance.file(filename),
        builder: (context, snapshot) {
          final fallback = ColoredBox(
            color: Colors.white10,
            child: Center(
              child: Icon(
                snapshot.hasError
                    ? Icons.broken_image_outlined
                    : Icons.photo_outlined,
              ),
            ),
          );
          if (!snapshot.hasData) return fallback;
          return Image.file(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stack) => const ColoredBox(
              color: Colors.white10,
              child: Center(child: Text('Photo unavailable')),
            ),
          );
        },
      ),
    ),
  );
}

class PhotoEditor extends StatefulWidget {
  final String? filename;
  final String label;
  final Future<void> Function(String?) onChanged;
  final ValueChanged<bool>? onBusyChanged;
  const PhotoEditor({
    super.key,
    required this.filename,
    required this.label,
    required this.onChanged,
    this.onBusyChanged,
  });
  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  bool busy = false;
  Future<void> change({bool remove = false}) async {
    setState(() => busy = true);
    widget.onBusyChanged?.call(true);
    String? imported;
    var committed = false;
    try {
      if (!remove) {
        final source = await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from library'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
        if (source == null || !mounted) return;
        final picked = await ImagePicker().pickImage(
          source: source,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85,
          requestFullMetadata: false,
        );
        if (picked == null || !mounted) return;
        imported = await PhotoStore.instance.importPhoto(picked);
        if (!mounted) return;
      }
      final old = widget.filename;
      await widget.onChanged(imported);
      committed = true;
      await PhotoStore.instance.remove(old);
    } catch (error) {
      if (mounted) {
        final denied =
            error is PlatformException &&
            error.code.toLowerCase().contains('access');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              denied
                  ? 'Allow photo or camera access in Settings, then try again.'
                  : 'Could not save the photo. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (!committed) await PhotoStore.instance.remove(imported);
      if (mounted) {
        setState(() => busy = false);
        widget.onBusyChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.filename != null) SavedPhoto(widget.filename!),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: busy ? null : () => change(),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(
              busy
                  ? 'Saving photo…'
                  : '${widget.filename == null ? 'Add' : 'Change'} ${widget.label}',
            ),
          ),
          if (widget.filename != null)
            TextButton(
              onPressed: busy ? null : () => change(remove: true),
              child: const Text('Remove photo'),
            ),
        ],
      ),
    ],
  );
}
