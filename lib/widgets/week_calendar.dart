import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekCalendar extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? initialDate;
  final List<DateTime>? markedDates;
  final Color? selectedDateColor;
  final Color? todayColor;
  final Color? markedDateColor;

  const WeekCalendar({
    super.key,
    this.onDateSelected,
    this.initialDate,
    this.markedDates,
    this.selectedDateColor,
    this.todayColor,
    this.markedDateColor,
  });

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  late DateTime _currentWeekStart;
  late DateTime _selectedDate;
  late DateTime _today;
  late List<DateTime> _markedDates;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    final initialDate = widget.initialDate ?? _today;
    _selectedDate = initialDate;
    _currentWeekStart = _getWeekStart(initialDate);
    _markedDates = widget.markedDates ?? [];
  }

  @override
  void didUpdateWidget(WeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当父组件传入的 initialDate 发生变化时，更新内部状态
    if (widget.initialDate != oldWidget.initialDate &&
        widget.initialDate != null) {
      setState(() {
        _selectedDate = widget.initialDate!;
        _currentWeekStart = _getWeekStart(widget.initialDate!);
      });
    }
    // 更新标记的日期
    if (widget.markedDates != oldWidget.markedDates) {
      _markedDates = widget.markedDates ?? [];
    }
  }

  // 获取一周的开始日期（周日）
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    // 将 DateTime.weekday (1=Monday, 7=Sunday) 转换为从周日开始
    // 如果是周日(weekday=7)，则不需要减去天数；否则减去对应天数
    final daysToSubtract = weekday == 7 ? 0 : weekday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  // 生成当前周的日期列表
  List<DateTime> _generateWeekData() {
    List<DateTime> weekData = [];
    for (int i = 0; i < 7; i++) {
      weekData.add(_currentWeekStart.add(Duration(days: i)));
    }
    return weekData;
  }

  // 检查日期是否被标记
  bool _isDateMarked(DateTime date) {
    return _markedDates.any(
      (markedDate) =>
          date.year == markedDate.year &&
          date.month == markedDate.month &&
          date.day == markedDate.day,
    );
  }

  // 检查日期是否是今天
  bool _isToday(DateTime date) {
    return date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;
  }

  // 检查日期是否被选中
  bool _isDateSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  // 处理日期点击
  void _onDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  // 切换到上一周
  void _prevWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(Duration(days: 7));
    });
  }

  // 切换到下一周
  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekData = _generateWeekData();
    final Color selectedColor =
        widget.selectedDateColor ?? Theme.of(context).primaryColor;
    final Color todayHighlightColor =
        widget.todayColor ?? Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 动态计算尺寸
          final double basePadding = constraints.maxWidth * 0.02;
          final double headerHeight = constraints.maxWidth * 0.12;
          final double weekHeaderHeight = constraints.maxWidth * 0.04;
          final cellSize = (constraints.maxWidth - basePadding * 2) / 8;
          final double fontSize = constraints.maxWidth * 0.04;
          final double iconSize = constraints.maxWidth * 0.06;
          final double titleFontSize = constraints.maxWidth * 0.04;

          // 获取当前周的月份和年份信息
          final startMonth = DateFormat('MMM').format(weekData.first);
          final endMonth = DateFormat('MMM').format(weekData.last);
          final year = weekData.first.year;

          String headerTitle;
          if (startMonth == endMonth) {
            headerTitle = '$startMonth $year';
          } else {
            headerTitle = '$startMonth - $endMonth $year';
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(basePadding),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.1),
                  offset: Offset(0, basePadding * 0.1),
                  blurRadius: basePadding * 0.2,
                  spreadRadius: basePadding * 0.05,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 周导航栏
                Container(
                  height: headerHeight,
                  padding: EdgeInsets.symmetric(
                    vertical: basePadding * 0.5,
                    horizontal: basePadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, size: iconSize),
                        onPressed: _prevWeek,
                        padding: EdgeInsets.all(basePadding * 0.5),
                        constraints: BoxConstraints(
                          minWidth: iconSize,
                          minHeight: iconSize,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              headerTitle,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, size: iconSize),
                        onPressed: _nextWeek,
                        padding: EdgeInsets.all(basePadding * 0.5),
                        constraints: BoxConstraints(
                          minWidth: iconSize,
                          minHeight: iconSize,
                        ),
                      ),
                    ],
                  ),
                ),

                // 星期标题
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  height: weekHeaderHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 1; i <= 7; i++)
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                DateFormat.E().format(DateTime(2023, 1, i)),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryFixedVariant,
                                  fontSize: fontSize * 0.7,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 日期行
                Container(
                  height: cellSize + basePadding,
                  padding: EdgeInsets.all(basePadding * 0.5),
                  child: Row(
                    children: weekData.map((date) {
                      final bool isToday = _isToday(date);
                      final bool isSelected = _isDateSelected(date);
                      final bool isMarked = _isDateMarked(date);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onDateTap(date),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? selectedColor
                                  : isToday
                                  ? todayHighlightColor.withValues(alpha: 0.2)
                                  : null,
                              border: isToday && !isSelected
                                  ? Border.all(
                                      color: todayHighlightColor,
                                      width: cellSize * 0.025,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                        fontWeight: isToday || isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                  // 手写椭圆标记 - 框住整个日期
                                  if (isMarked)
                                    Positioned(
                                      top: -1,
                                      right: -4,
                                      child: Badge(
                                        backgroundColor: Colors.red[400],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
