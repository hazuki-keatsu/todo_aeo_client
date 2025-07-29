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
    this.priority = 0, // 新增优先级参数
    this.dragIndex, // 拖动索引
    this.enableDrag = false, // 是否启用拖动
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
  final int priority; // 新增优先级字段
  final int? dragIndex; // 拖动索引
  final bool enableDrag; // 是否启用拖动

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
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(8, 4, 8, 4),
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 主要内容区域
              Expanded(
                child: Material(
                  color: isCompleted
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {}, // 添加空的onTap以启用涟漪效果
                    onLongPress: () => ShowDialog.showOptionsBottomSheet(
                      widget.id,
                      widget.todoProvider,
                      context,
                      OperationMode.todo,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(0, 4, 0, 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isCompleted,
                              onChanged: (value) =>
                                  checkboxClick(value ?? false),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      _buildCategoryChip(12, 8, 24),
                                      SizedBox(width: 8), // 添加一些右边距
                                    ],
                                  ),
                                  Text(
                                    widget.description,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7)
                                          : Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer
                                                .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                  _buildTimeRow(16, false, true),
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
              // 拖动手柄 - 只在启用拖动时显示
              if (widget.enableDrag && widget.dragIndex != null)
                SizedBox(
                  width: 48,
                  child: ReorderableDragStartListener(
                    index: widget.dragIndex!,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {},
                        child: SizedBox(
                          width: 48,
                          height: double.infinity, // 填充整个可用高度
                          child: Center(
                            child: Icon(
                              Icons.drag_handle,
                              color: Theme.of(context).colorScheme.outline,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
        Text(
          isMini
              ? "${widget.createdAt.month}-${widget.createdAt.day}" // 迷你模式简化显示
              : "创建：${widget.createdAt.year}-${widget.createdAt.month}-${widget.createdAt.day} ${widget.createdAt.hour}:${widget.createdAt.minute.toString().padLeft(2, '0')}",
          style: TextStyle(
            color: isCompleted
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                : Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            fontSize: fontSize,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Spacer(),
        if (widget.finishingAt != null && !isMini) // 在迷你模式下隐藏完成时间
          Text(
            isCompact
                ? "完成：${widget.finishingAt!.month}-${widget.finishingAt!.day}"
                : "完成：${widget.finishingAt!.year}-${widget.finishingAt!.month}-${widget.finishingAt!.day} ${widget.finishingAt!.hour}:${widget.finishingAt!.minute.toString().padLeft(2, '0')}",
            style: TextStyle(
              color: isCompleted
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6)
                  : Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              fontSize: fontSize,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        SizedBox(width: isMini ? 8 : 16),
      ],
    );
  }
}
