import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthCalendar extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? initialDate;
  final List<DateTime>? markedDates;
  final Color? selectedDateColor;
  final Color? todayColor;
  final Color? markedDateColor;

  const MonthCalendar({
    super.key,
    this.onDateSelected,
    this.initialDate,
    this.markedDates,
    this.selectedDateColor,
    this.todayColor,
    this.markedDateColor,
  });

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late DateTime _today;
  late List<DateTime> _markedDates;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentDate = widget.initialDate ?? DateTime(_today.year, _today.month);
    _selectedDate = widget.initialDate ?? _today;
    _markedDates = widget.markedDates ?? [];
  }

  @override
  void didUpdateWidget(MonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当父组件传入的 initialDate 发生变化时，更新内部状态
    if (widget.initialDate != oldWidget.initialDate &&
        widget.initialDate != null) {
      setState(() {
        _selectedDate = widget.initialDate!;
        // 如果选中的日期不在当前显示的月份，切换到对应月份
        if (_selectedDate.month != _currentDate.month ||
            _selectedDate.year != _currentDate.year) {
          _currentDate = DateTime(_selectedDate.year, _selectedDate.month);
        }
      });
    }
    // 更新标记的日期
    if (widget.markedDates != oldWidget.markedDates) {
      _markedDates = widget.markedDates ?? [];
    }
  }

  // 获取当月第一天是星期几 (0=Sunday, 1=Monday, ..., 6=Saturday)
  int _getFirstDayOfMonth() {
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    // 将 DateTime.weekday (1=Monday, 7=Sunday) 转换为 (0=Sunday, 1=Monday, ..., 6=Saturday)
    return firstDay.weekday == 7 ? 0 : firstDay.weekday;
  }

  // 获取当月的总天数
  int _getDaysInMonth() {
    return DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
  }

  // 生成日历数据
  List<DateTime> _generateCalendarData() {
    List<DateTime> calendarData = [];
    final int firstDayOfMonth = _getFirstDayOfMonth(); // 0=Sunday, 1=Monday, ..., 6=Saturday
    final int daysInMonth = _getDaysInMonth();

    // 添加上个月的末尾几天
    for (int i = firstDayOfMonth - 1; i >= 0; i--) {
      calendarData.add(DateTime(_currentDate.year, _currentDate.month, -i));
    }

    // 添加当月的所有天
    for (int i = 1; i <= daysInMonth; i++) {
      calendarData.add(DateTime(_currentDate.year, _currentDate.month, i));
    }

    // 添加下个月的开头几天，使总天数达到42天（6行7列）
    final int remainingDays = 42 - calendarData.length;
    for (int i = 1; i <= remainingDays; i++) {
      calendarData.add(DateTime(_currentDate.year, _currentDate.month + 1, i));
    }

    return calendarData;
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

  // 检查日期是否属于当前月份
  bool _isCurrentMonth(DateTime date) {
    return date.month == _currentDate.month;
  }

  // 处理日期点击
  void _onDateTap(DateTime date) {
    if (_isCurrentMonth(date)) {
      setState(() {
        _selectedDate = date;
      });
      widget.onDateSelected?.call(date);
    }
  }

  // 切换到上一个月
  void _prevMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  // 切换到下一个月
  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> calendarData = _generateCalendarData();
    final Color selectedColor =
        widget.selectedDateColor ?? Theme.of(context).primaryColor;
    final Color todayHighlightColor =
        widget.todayColor ?? Theme.of(context).colorScheme.secondary;

    // 根据屏幕方向调整宽高比
    final double aspectRatio = 12 / 13;

    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(8, 8, 8, 4),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 动态计算尺寸
            final double basePadding = constraints.maxWidth * 0.02;
            final double headerHeight = constraints.maxWidth * 0.15;
            final double weekHeaderHeight = constraints.maxWidth * 0.05;
            final cellSize = (constraints.maxWidth - basePadding * 2) / 7;
            final double fontSize = constraints.maxWidth * 0.04;
            final double iconSize = constraints.maxWidth * 0.06;
            final double titleFontSize = constraints.maxWidth * 0.04;

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
                children: [
                  // 月份导航栏
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
                          onPressed: _prevMonth,
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
                                DateFormat('MMMM yyyy').format(_currentDate),
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
                          onPressed: _nextMonth,
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
                                    fontSize: fontSize * 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 日历网格
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(basePadding * 0.5),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                        itemCount: calendarData.length,
                        itemBuilder: (context, index) {
                          final DateTime date = calendarData[index];
                          final bool isCurrentMonth = _isCurrentMonth(date);
                          final bool isToday = _isToday(date);
                          final bool isSelected = _isDateSelected(date);
                          final bool isMarked = _isDateMarked(date);

                          return GestureDetector(
                            onTap: () => _onDateTap(date),
                            child: Container(
                              margin: EdgeInsets.all(cellSize * 0.05),
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
                                  clipBehavior: Clip.none, // 允许子组件超出边界
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                          color: isCurrentMonth
                                              ? isSelected
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color
                                              : Colors.grey.shade400,
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
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
