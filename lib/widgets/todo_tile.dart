import 'package:flutter/material.dart';
import 'package:todo_aeo/functions/show_dialog.dart';
import 'package:todo_aeo/providers/todo_provider.dart';

class TodoTile extends StatefulWidget {
  const TodoTile({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.finishingAt,
    required this.updateCompetedFunction,
    this.categoryName,
    this.categoryColor,
    required this.todoProvider,
  });

  final int id;
  final String title;
  final String description;
  final int isCompleted;
  final DateTime createdAt;
  final DateTime? finishingAt;
  final Function(bool, int?) updateCompetedFunction;
  final String? categoryName;
  final Color? categoryColor;
  final TodoProvider todoProvider;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  late bool isCompleted;

  @override
  void initState() {
    isCompleted = widget.isCompleted == 1 ? true : false;
    super.initState();
  }

  void checkboxClick(bool value) {
    setState(() {
      isCompleted = value;
      widget.updateCompetedFunction(value, widget.id);
    });
  }

  // 根据背景颜色获取对比文字颜色
  Color _getContrastColor(Color backgroundColor) {
    // 计算亮度，选择合适的文字颜色
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据可用宽度计算响应式尺寸
        final double availableWidth = constraints.maxWidth;
        final bool isCompact = availableWidth < 400; // 紧凑模式阈值
        final bool isMini = availableWidth < 300; // 迷你模式阈值

        // 响应式尺寸配置
        final double horizontalPadding = isMini
            ? 8
            : isCompact
            ? 10
            : 12;
        final double verticalPadding = isMini ? 2 : 4;
        final double borderRadius = isMini
            ? 8
            : isCompact
            ? 10
            : 12;
        final double titleFontSize = isMini
            ? 16
            : isCompact
            ? 18
            : 20;
        final double descriptionFontSize = isMini
            ? 13
            : isCompact
            ? 14
            : 16;
        final double metaFontSize = isMini
            ? 10
            : isCompact
            ? 11
            : 12;
        final double categoryFontSize = isMini
            ? 10
            : isCompact
            ? 11
            : 12;
        final double categoryPadding = isMini
            ? 4
            : isCompact
            ? 6
            : 8;
        final double spacingSize = isMini
            ? 4
            : isCompact
            ? 6
            : 8;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.2),
                  offset: Offset(0, 1),
                  blurRadius: 1,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Material(
              color: isCompleted
                  ? Theme.of(context).colorScheme.surfaceContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(borderRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: () {}, // 添加空的onTap以启用涟漪效果
                onLongPress: () => ShowDialog.showOptionsBottomSheet(
                  widget.id,
                  widget.todoProvider,
                  context,
                  DelMode.todo,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      verticalPadding,
                      0,
                      verticalPadding,
                    ),
                    child: Row(
                      children: [
                        // Checkbox - 在紧凑模式下调整大小
                        Transform.scale(
                          scale: isMini
                              ? 0.8
                              : isCompact
                              ? 0.9
                              : 1.0,
                          child: Checkbox(
                            value: isCompleted,
                            onChanged: (value) => checkboxClick(value ?? false),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题和分类标签行
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.title,
                                      style: TextStyle(
                                        color: isCompleted
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onSurface
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w700,
                                        fontSize: titleFontSize,
                                      ),
                                      maxLines: isMini ? 1 : 2, // 在迷你模式下限制行数
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _buildCategoryChip(
                                    categoryFontSize,
                                    categoryPadding,
                                    borderRadius * 0.75,
                                  ),
                                  SizedBox(width: spacingSize),
                                ],
                              ),

                              // 描述文本
                              if (!isMini ||
                                  widget
                                      .description
                                      .isNotEmpty) // 在迷你模式下可选择隐藏描述
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: spacingSize * 0.5,
                                  ),
                                  child: Text(
                                    widget.description,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: isMini ? 1 : 2,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryFixed,
                                      fontWeight: FontWeight.w400,
                                      fontSize: descriptionFontSize,
                                    ),
                                  ),
                                ),

                              // 时间信息行
                              Padding(
                                padding: EdgeInsets.only(
                                  top: spacingSize * 0.5,
                                ),
                                child: _buildTimeRow(
                                  metaFontSize,
                                  isMini,
                                  isCompact,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建响应式分类胶囊标签
  Widget _buildCategoryChip(
    double fontSize,
    double padding,
    double borderRadius,
  ) {
    if (widget.categoryName == null || widget.categoryName!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.5,
      ),
      decoration: BoxDecoration(
        color: widget.categoryColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        widget.categoryName!,
        style: TextStyle(
          color: _getContrastColor(
            widget.categoryColor ?? Theme.of(context).colorScheme.primary,
          ),
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 构建响应式时间信息行
  Widget _buildTimeRow(double fontSize, bool isMini, bool isCompact) {
    return Row(
      children: [
        Expanded(
          child: Text(
            isMini
                ? "${widget.createdAt.month}-${widget.createdAt.day}" // 迷你模式简化显示
                : "创建：${widget.createdAt.year}-${widget.createdAt.month}-${widget.createdAt.day} ${widget.createdAt.hour}:${widget.createdAt.minute.toString().padLeft(2, '0')}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
              fontSize: fontSize,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.finishingAt != null && !isMini) // 在迷你模式下隐藏完成时间
          Expanded(
            child: Text(
              isCompact
                  ? "完成：${widget.finishingAt!.month}-${widget.finishingAt!.day}"
                  : "完成：${widget.finishingAt!.year}-${widget.finishingAt!.month}-${widget.finishingAt!.day} ${widget.finishingAt!.hour}:${widget.finishingAt!.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        SizedBox(width: isMini ? 8 : 16),
      ],
    );
  }
}
