// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

const kSVGTagEnd = '</svg>';
const kSVGTagStart = '<svg';
const heicISO8859 = ['ftypheic', 'ftyphevc', 'ftyphevx'];
const heifISO8859 = ['ftypmif1', 'ftypmsf1'];

class ImageFormatHelper {
  ImageFormatHelper._();

  /// 通过图片bytes 得到 图片格式
  ///
  static ImageFormat imageFormatForImageUnit8List(Uint8List data) {
    if (data.isEmpty || data.length < 4) {
      return ImageFormat.UNDEFINED;
    }
    if (data.length > 8 && matchRange(data.sublist(0, 8), ImageSignature.png)) {
      return ImageFormat.PNG;
    }
    if (matchRange(data.sublist(0, 3), ImageSignature.jpeg)) {
      return ImageFormat.JPEG;
    }

    if (matchRange(data.sublist(0, 2), ImageSignature.bmp)) {
      return ImageFormat.BMP;
    }
    if (data.length > 6 &&
            matchRange(data.sublist(0, 6), ImageSignature.gif89a) ||
        matchRange(data.sublist(0, 6), ImageSignature.gif87a)) {
      return ImageFormat.GIF;
    }
    if (matchRange(data.sublist(0, 3), ImageSignature.tiffII) ||
        matchRange(data.sublist(0, 3), ImageSignature.tiffMM)) {
      return ImageFormat.TIFF;
    }

    if (matchRange(
            data.sublist(
                0, data.length - min(100, ImageSignature.svgTagStart.length)),
            ImageSignature.svgTagStart) &&
        matchRange(
            data.sublist(
                data.length - max(100, ImageSignature.svgTagEnd.length)),
            ImageSignature.svgTagEnd)) {
      return ImageFormat.SVG;
    }

    if (data.length >= 4 &&
        matchRange(data.sublist(0, 20), ImageSignature.pdf)) {
      final testString = utf8.decode(data.sublist(1, 4));
      if (testString == ImageFormat.PDF.name.toUpperCase()) {
        return ImageFormat.PDF;
      }
    }
    if (data.length >= 12 &&
        matchRange(data.sublist(0, 20), ImageSignature.webp)) {
      final testString = utf8.decode(data.sublist(0, 12));
      if (testString.startsWith('RIFF') && testString.endsWith('WEBP')) {
        return ImageFormat.WEBP;
      }
    }

    if (data.length >= 12 &&
        matchRange(data.sublist(0, 20), ImageSignature.heicf)) {
      final testString = utf8.decode(data.sublist(4, 12));
      if (heicISO8859.contains(testString)) {
        return ImageFormat.HEIC;
      }

      if (heifISO8859.contains(testString)) {
        return ImageFormat.HEIF;
      }
    }
    return ImageFormat.UNDEFINED;
  }
}

/// 图片格式
///
enum ImageFormat {
  /// 未知格式
  UNDEFINED,
  JPEG,
  PNG,
  GIF,
  TIFF,
  WEBP,
  HEIC,
  HEIF,
  PDF,
  SVG,
  BMP,
}

/// Hex Signature or Magic numbers or Magic Bytes
/// 目前转换为十进制
///
extension ImageSignature on ImageFormat {
  static List<int> png = [137, 80, 78, 71, 13, 10, 26, 10];
  static List<int> jpeg = [255, 216, 255];
  static List<int> gif87a = [71, 73, 70, 56, 55, 97];
  static List<int> gif89a = [71, 73, 70, 56, 57, 97];
  static List<int> gif = [71, 73, 70, 56];
  static List<int> tiffII = [73, 73, 42];
  static List<int> tiffMM = [77, 77, 0];
  static List<int> svgTagStart = [60, 115, 118, 103];
  static List<int> svgTagEnd = [60, 47, 115, 118, 103, 62];
  static List<int> bmp = [66, 77];
  static List<int> webp = [82, 73, 70, 70];
  static List<int> heicf = [102, 116, 121, 112]; // offset 4 byte
  static List<int> pdf = [37, 80, 68, 70];

  List<int> get sign => switch (this) {
        ImageFormat.UNDEFINED => [-1],
        ImageFormat.BMP => ImageSignature.bmp,
        ImageFormat.SVG => ImageSignature.svgTagStart,
        ImageFormat.WEBP => ImageSignature.webp,
        ImageFormat.HEIC || ImageFormat.HEIF => ImageSignature.heicf,
        ImageFormat.PDF => ImageSignature.pdf,
        ImageFormat.TIFF => ImageSignature.tiffII,
        ImageFormat.GIF => ImageSignature.gif,
        ImageFormat.JPEG => ImageSignature.jpeg,
        ImageFormat.PNG => ImageSignature.png,
      };
}

/// src: 源数据
///
/// target: 匹配目标数组
///
bool matchRange(List<int> src, List<int> target) {
  if (src.isEmpty || target.isEmpty) {
    return false;
  }
  if (src.length < target.length) {
    return false;
  }
  for (int start = 0; start <= src.length - target.length; start++) {
    final sublist = src.sublist(start, target.length + start);
    if (listEquals(sublist, target)) {
      return true;
    }
  }
  return false;
}
