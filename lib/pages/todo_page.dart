import 'package:flutter/material.dart';
import 'package:todo_aeo/widgets/show_dialog.dart';
import 'package:todo_aeo/providers/todo_provider.dart';
import 'package:todo_aeo/utils/parse_color.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({
    super.key,
    this.todoId,
    required this.provider,
    required this.lastPageContext,
  });

  final int? todoId;
  bool get isEditMode => todoId != null;
  final TodoProvider provider;
  final BuildContext lastPageContext;

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  String todoName = '';
  String todoDescription = '';
  int? selectedCategoryId;
  DateTime? selectedFinishingDate;
  late int? todoId;
  late bool isEditMode;
  late TodoProvider provider;
  late BuildContext lastPageContext;

  @override
  void initState() {
    super.initState();

    todoId = widget.todoId;
    isEditMode = widget.isEditMode;
    provider = widget.provider;
    lastPageContext = widget.lastPageContext;

    // 如果是编辑模式，获取现有数据
    if (widget.isEditMode) {
      final existingTodo = widget.provider.todos?.firstWhere(
        (todo) => todo.id == widget.todoId,
      );
      if (existingTodo != null) {
        todoName = existingTodo.title;
        todoDescription = existingTodo.description ?? '';
        selectedCategoryId = existingTodo.categoryId;
        selectedFinishingDate = existingTodo.finishingAt;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> writeInTodoData() async {
    if (todoName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入待办事项名称'), duration: Duration(seconds: 3)),
      );
      return Future.value();
    }

    // 在异步操作前获取 Navigator 和 ScaffoldMessenger
    final navigator = Navigator.of(context);
    final lastPageScaffoldMessenger = ScaffoldMessenger.of(lastPageContext);

    try {
      // 准备数据
      final todoData = {
        'id': todoId,
        'title': todoName.trim(),
        'description': todoDescription.trim().isEmpty
            ? null
            : todoDescription.trim(),
        'categoryId': selectedCategoryId,
        'finishingAt': selectedFinishingDate?.toIso8601String(),
      };

      if (isEditMode) {
        // 编辑模式：更新现有待办事项
        await provider.updateTodo(todoData);
      } else {
        // 添加模式：创建新的待办事项
        todoData['isCompleted'] = 0;
        todoData['createdAt'] = DateTime.now().toIso8601String();
        await provider.addTodo(todoData);
      }

      // 检查当前页面和前一个页面是否仍然挂载
      if (!mounted || !lastPageContext.mounted) return;

      navigator.pop();

      await Future.delayed(const Duration(milliseconds: 200));

      if (lastPageContext.mounted) {
        lastPageScaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(isEditMode ? '待办事项更新成功' : '待办事项添加成功'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? '更新待办事项失败: $e' : '添加待办事项失败: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text(
          isEditMode ? "编辑 Todo" : "新增一个 Todo",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "todo_add_fab_to_todo_save_fab", // 使用相同的heroTag实现Hero动画
        tooltip: isEditMode ? "保存更改" : "保存 Todo",
        child: Icon(Icons.save_outlined),
        onPressed: () async {
          await writeInTodoData();
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 待办事项名称
              TextField(
                decoration: InputDecoration(
                  labelText: '待办事项名称',
                  border: OutlineInputBorder(),
                  hintText: '请输入待办事项名称',
                ),
                controller: TextEditingController(text: todoName),
                onChanged: (value) {
                  todoName = value;
                },
              ),
              SizedBox(height: 16),
              // 待办事项描述
              TextField(
                decoration: InputDecoration(
                  labelText: '待办事项描述(可选)',
                  border: OutlineInputBorder(),
                  hintText: '请输入待办事项描述',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                controller: TextEditingController(text: todoDescription),
                onChanged: (value) {
                  todoDescription = value;
                },
              ),
              SizedBox(height: 16),
              // 分类选择
              Text('选择分类', style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<int?>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    hintText: '选择分类（可选）',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('无分类'),
                        ],
                      ),
                    ),
                    // 添加现有分类
                    ...provider.categories?.map((category) {
                          return DropdownMenuItem<int?>(
                            value: category.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: parseColor(category.color, context),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          );
                        }) ??
                        [],
                    // 添加新分类选项
                    DropdownMenuItem<int?>(
                      value: -1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '新增分类',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == -1) {
                      // 用户选择了新增分类，显示新增分类对话框
                      final result = await ShowDialog.showCategoryDialog(
                        context,
                        provider,
                      );
                      // 如果成功创建了新分类，获取最新创建的分类ID并选中它
                      if (result == true) {
                        // 等待下一帧再更新状态，确保 provider 的分类列表已更新
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (provider.categories != null &&
                              provider.categories!.isNotEmpty) {
                            final latestCategory = provider.categories!.last;
                            setState(() {
                              selectedCategoryId = latestCategory.id;
                            });
                          }
                        });
                      }
                    } else {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              // 完成日期选择
              Text('完成日期', style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    helpText: "选择日期",
                    cancelText: "取消",
                    confirmText: "确定",
                    fieldLabelText: "请输入日期",
                    fieldHintText: "mm/dd/yyyy",
                    context: context,
                    initialDate: selectedFinishingDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                  );
                  if (date != null) {
                    setState(() {
                      selectedFinishingDate = date;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).hintColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20),
                      SizedBox(width: 8),
                      Text(
                        selectedFinishingDate != null
                            ? '${selectedFinishingDate!.year}-${selectedFinishingDate!.month.toString().padLeft(2, '0')}-${selectedFinishingDate!.day.toString().padLeft(2, '0')}'
                            : '选择完成日期（可选）',
                        style: TextStyle(
                          color: selectedFinishingDate != null
                              ? Theme.of(context).textTheme.bodyMedium?.color
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
