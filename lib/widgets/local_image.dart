import 'dart:io';
import 'package:flutter/material.dart';
import '../services/resource_service.dart';

/// Widget ที่ใช้แสดงรูปภาพจาก local storage
/// ถ้าไม่พบรูปในเครื่องจะแสดงรูปจาก assets แทน
class LocalImage extends StatefulWidget {
  final String fileName; // ชื่อไฟล์รูปภาพ
  final String assetFallback; // path ของรูปใน assets หากไม่พบไฟล์ local
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LocalImage({
    Key? key,
    required this.fileName,
    required this.assetFallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<LocalImage> createState() => _LocalImageState();
}

class _LocalImageState extends State<LocalImage> {
  final ResourceService _resourceService = ResourceService();
  String? _localPath;
  bool _isLoading = true;
  bool _loadFromAssets = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(LocalImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileName != widget.fileName) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final exists =
          await _resourceService.fileExists(widget.fileName, 'image');

      if (exists) {
        final path = await _resourceService.getLocalImagePath(widget.fileName);
        if (mounted) {
          setState(() {
            _localPath = path;
            _loadFromAssets = false;
            _isLoading = false;
          });
        }
      } else {
        // ไม่พบไฟล์ใน local storage ใช้ assets แทน
        if (mounted) {
          setState(() {
            _loadFromAssets = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // เกิดข้อผิดพลาด ใช้ assets แทน
      if (mounted) {
        setState(() {
          _loadFromAssets = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    Widget imageWidget;

    if (_loadFromAssets) {
      // แสดงรูปจาก assets
      imageWidget = Image.asset(
        widget.assetFallback,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // แสดงรูปจาก local storage
      imageWidget = Image.file(
        File(_localPath!),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    // ถ้ามีการกำหนด borderRadius ให้ครอบด้วย ClipRRect
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.white60,
        ),
      ),
    );
  }
}
