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

  // 构建分类胶囊标签
  Widget _buildCategoryChip() {
    if (widget.categoryName == null || widget.categoryName!.isEmpty) {
      return SizedBox.shrink(); // 如果没有分类信息，返回空组件
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.categoryColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12), // 胶囊形状
      ),
      child: Text(
        widget.categoryName!,
        style: TextStyle(
          color: _getContrastColor(
            widget.categoryColor ?? Theme.of(context).colorScheme.primary,
          ),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
          color: Theme.of(context).colorScheme.primaryContainer,
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
        child: Material(
          color: isCompleted
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {}, // 添加空的onTap以启用涟漪效果
            onLongPress: () => ShowDialog.showOptionsBottomSheet(widget.id, widget.todoProvider, context, DelMode.todo),
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
                      onChanged: (value) => checkboxClick(value ?? false),
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
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              _buildCategoryChip(),
                              SizedBox(width: 8), // 添加一些右边距
                            ],
                          ),
                          Text(
                            widget.description,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryFixed,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "创建：${widget.createdAt.year}-${widget.createdAt.month}-${widget.createdAt.day} ${widget.createdAt.hour}:${widget.createdAt.minute}",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryFixedVariant,
                                ),
                              ),
                              Spacer(flex: 3),
                              if (widget.finishingAt != null)
                                Text(
                                  "完成：${widget.finishingAt!.year}-${widget.finishingAt!.month}-${widget.finishingAt!.day} ${widget.finishingAt!.hour}:${widget.finishingAt!.minute}",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryFixedVariant,
                                  ),
                                ),
                              Spacer(flex: 1),
                            ],
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
  }
}
