import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class SputnikRenderWrap extends RenderBox with ContainerRenderObjectMixin<RenderBox, WrapParentData>, RenderBoxContainerDefaultsMixin<RenderBox, WrapParentData> {
  SputnikRenderWrap({
    List<RenderBox>? children,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
    required this.onShowCount,
  })  : _direction = direction,
        _alignment = alignment,
        _spacing = spacing,
        _runAlignment = runAlignment,
        _runSpacing = runSpacing,
        _crossAxisAlignment = crossAxisAlignment,
        _textDirection = textDirection,
        _verticalDirection = verticalDirection,
        _clipBehavior = clipBehavior {
    addAll(children);
  }
  final Function(int) onShowCount;
  Axis get direction => _direction;
  Axis _direction;

  set direction(Axis value) {
    if (_direction == value) {
      return;
    }
    _direction = value;
    markNeedsLayout();
  }

  WrapAlignment get alignment => _alignment;
  WrapAlignment _alignment;

  set alignment(WrapAlignment value) {
    if (_alignment == value) {
      return;
    }
    _alignment = value;
    markNeedsLayout();
  }

  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    if (_spacing == value) {
      return;
    }
    _spacing = value;
    markNeedsLayout();
  }

  WrapAlignment get runAlignment => _runAlignment;
  WrapAlignment _runAlignment;

  set runAlignment(WrapAlignment value) {
    if (_runAlignment == value) {
      return;
    }
    _runAlignment = value;
    markNeedsLayout();
  }

  double get runSpacing => _runSpacing;
  double _runSpacing;

  set runSpacing(double value) {
    if (_runSpacing == value) {
      return;
    }
    _runSpacing = value;
    markNeedsLayout();
  }

  WrapCrossAlignment get crossAxisAlignment => _crossAxisAlignment;
  WrapCrossAlignment _crossAxisAlignment;

  set crossAxisAlignment(WrapCrossAlignment value) {
    if (_crossAxisAlignment == value) {
      return;
    }
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;

  set textDirection(TextDirection? value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  VerticalDirection get verticalDirection => _verticalDirection;
  VerticalDirection _verticalDirection;

  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection != value) {
      _verticalDirection = value;
      markNeedsLayout();
    }
  }

  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.none;

  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WrapParentData) {
      child.parentData = WrapParentData();
    }
  }

  double _getMainAxisExtent(Size childSize) {
    return childSize.width;
  }

  double _getCrossAxisExtent(Size childSize) {
    return childSize.height;
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    return Offset(mainAxisOffset, crossAxisOffset);
  }

  double _getChildCrossAxisOffset(bool flipCrossAxis, double runCrossAxisExtent, double childCrossAxisExtent) {
    final double freeSpace = runCrossAxisExtent - childCrossAxisExtent;
    return flipCrossAxis ? freeSpace : 0.0;
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    RenderBox? child = firstChild;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final BoxConstraints childConstraints;
    double mainAxisLimit = 0.0;
    bool flipMainAxis = false;
    bool flipCrossAxis = false;
    childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
    mainAxisLimit = constraints.maxWidth;
    if (textDirection == TextDirection.rtl) {
      flipMainAxis = true;
    }
    if (verticalDirection == VerticalDirection.up) {
      flipCrossAxis = true;
    }

    final double spacing = this.spacing;
    final double runSpacing = this.runSpacing;
    final List<_RunMetrics> runMetrics = <_RunMetrics>[];
    double mainAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    int childCount = 0;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final double childMainAxisExtent = _getMainAxisExtent(child.size);
      final double childCrossAxisExtent = _getCrossAxisExtent(child.size);
      if (childCount > 0 && runMainAxisExtent + spacing + childMainAxisExtent > mainAxisLimit) {
        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        if (runMetrics.isNotEmpty) {
        }
        runMetrics.add(_RunMetrics(runMainAxisExtent, runCrossAxisExtent, childCount));
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        childCount = 0;
      }
      runMainAxisExtent += childMainAxisExtent;
      if (childCount > 0) {
        runMainAxisExtent += spacing;
      }
      runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      childCount += 1;
      final WrapParentData childParentData = child.parentData! as WrapParentData;
      childParentData._runIndex = runMetrics.length;
      child = childParentData.nextSibling;
    }
    if (childCount > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      if (runMetrics.isNotEmpty) {
      }
      runMetrics.add(_RunMetrics(runMainAxisExtent, runCrossAxisExtent, childCount));
    }

    final int runCount = runMetrics.length;
    assert(runCount > 0);

    double containerMainAxisExtent = 0.0;
    double containerCrossAxisExtent = 0.0;

    size = constraints.constrain(Size(mainAxisExtent, runMetrics[0].crossAxisExtent));
    containerMainAxisExtent = size.width;
    containerCrossAxisExtent = size.height;

    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;

    runBetweenSpace += runSpacing;
    double crossAxisOffset = flipCrossAxis ? containerCrossAxisExtent - runLeadingSpace : runLeadingSpace;

    child = firstChild;
    for (int i = 0; i < runCount; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final int childCount = metrics.childCount;

      final double mainAxisFreeSpace = math.max(0.0, containerMainAxisExtent - runMainAxisExtent);
      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      switch (alignment) {
        case WrapAlignment.start:
          break;
        case WrapAlignment.end:
          childLeadingSpace = mainAxisFreeSpace;
        case WrapAlignment.center:
          childLeadingSpace = mainAxisFreeSpace / 2.0;
        case WrapAlignment.spaceBetween:
          childBetweenSpace = childCount > 1 ? mainAxisFreeSpace / (childCount - 1) : 0.0;
        case WrapAlignment.spaceAround:
          childBetweenSpace = mainAxisFreeSpace / childCount;
          childLeadingSpace = childBetweenSpace / 2.0;
        case WrapAlignment.spaceEvenly:
          childBetweenSpace = mainAxisFreeSpace / (childCount + 1);
          childLeadingSpace = childBetweenSpace;
      }

      childBetweenSpace += spacing;
      double childMainPosition = flipMainAxis ? containerMainAxisExtent - childLeadingSpace : childLeadingSpace;

      if (flipCrossAxis) {
        crossAxisOffset -= runCrossAxisExtent;
      }

      while (child != null) {
        final WrapParentData childParentData = child.parentData! as WrapParentData;
        if (childParentData._runIndex != i) {
          break;
        }
        if (childParentData._runIndex == 0) {
          final double childMainAxisExtent = _getMainAxisExtent(child.size);
          final double childCrossAxisExtent = _getCrossAxisExtent(child.size);
          final double childCrossAxisOffset = _getChildCrossAxisOffset(flipCrossAxis, runCrossAxisExtent, childCrossAxisExtent);
          if (flipMainAxis) {
            childMainPosition -= childMainAxisExtent;
          }
          childParentData.offset = _getOffset(childMainPosition, crossAxisOffset + childCrossAxisOffset);
          if (flipMainAxis) {
            childMainPosition -= childBetweenSpace;
          } else {
            childMainPosition += childMainAxisExtent + childBetweenSpace;
          }
        } else {
          child.layout(const BoxConstraints.tightFor(width: 0, height: 0), parentUsesSize: true);
        }
        child = childParentData.nextSibling;
      }
      onShowCount(runMetrics[0].childCount);
      crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _clipRectLayer.layer = null;
    defaultPaint(context, offset);
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Axis>('direction', direction));
    properties.add(EnumProperty<WrapAlignment>('alignment', alignment));
    properties.add(DoubleProperty('spacing', spacing));
    properties.add(EnumProperty<WrapAlignment>('runAlignment', runAlignment));
    properties.add(DoubleProperty('runSpacing', runSpacing));
    properties.add(DoubleProperty('crossAxisAlignment', runSpacing));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
    properties.add(EnumProperty<VerticalDirection>('verticalDirection', verticalDirection, defaultValue: VerticalDirection.down));
  }
}

class _RunMetrics {
  _RunMetrics(this.mainAxisExtent, this.crossAxisExtent, this.childCount);

  final double mainAxisExtent;
  final double crossAxisExtent;
  final int childCount;
}

class WrapParentData extends ContainerBoxParentData<RenderBox> {
  int _runIndex = 0;
}