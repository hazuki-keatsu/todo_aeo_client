// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get homePage => '主页';

  @override
  String get calendarPage => '日历';

  @override
  String get settingsPage => '设置';

  @override
  String get statistics => '统计信息';

  @override
  String get serverConfiguration => '服务器配置';

  @override
  String get configureSyncSettings => '配置同步设置';

  @override
  String get syncNow => '立即同步';

  @override
  String get aboutApp => '关于应用';

  @override
  String get themeSwitch => '主题切换';

  @override
  String get languageSwitch => '切换语言';

  @override
  String get settings => '设置';

  @override
  String get all => '全部';

  @override
  String get uncategorized => '未分类';

  @override
  String get categories => '分类';

  @override
  String get about => '关于';

  @override
  String get loading => '加载中...';

  @override
  String get retry => '重试';

  @override
  String get loadFailed => '加载失败';

  @override
  String get addTodo => '添加一个Todo';

  @override
  String get total => '总待办';

  @override
  String get completed => '已完成';

  @override
  String get categoryCount => '分类数';

  @override
  String get appInfo => '应用信息';

  @override
  String get dataManagement => '数据管理';

  @override
  String get syncImmediately => '立即通过您配置的方式同步';

  @override
  String get chooseTheme => '选择你喜欢的主题';

  @override
  String get chooseLanguage => '选择你的语言';

  @override
  String get todoName => '待办事项名称';

  @override
  String get todoDescription => '待办事项描述';

  @override
  String get pleaseEnterTodoName => '请输入待办事项名称';

  @override
  String get category => '分类';

  @override
  String get dueDate => '截止日期';

  @override
  String get noDueDate => '无截止日期';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get deleteConfirm => '确认删除';

  @override
  String get deleteMessage => '确定要删除这个待办事项吗？';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get created => '创建';

  @override
  String get finished => '完成';

  @override
  String get createdAt => '创建于';

  @override
  String get finishedAt => '完成于';

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String get deleteSelected => '删除选中';

  @override
  String get markCompleted => '标记完成';

  @override
  String get markIncomplete => '标记未完成';

  @override
  String selectedCount(int count) {
    return '已选择 $count 项';
  }

  @override
  String get showCompleted => '显示已完成';

  @override
  String get hideCompleted => '隐藏已完成';

  @override
  String get sortBy => '排序方式';

  @override
  String get sortByCreated => '按创建时间';

  @override
  String get sortByDueDate => '按截止时间';

  @override
  String get sortByName => '按名称';

  @override
  String get sortByCategory => '按分类';

  @override
  String get categoryName => '分类名称';

  @override
  String get categoryColor => '分类颜色';

  @override
  String get addCategory => '添加分类';

  @override
  String get editCategory => '编辑分类';

  @override
  String get deleteCategory => '删除分类';

  @override
  String get pleaseEnterCategoryName => '请输入分类名称';

  @override
  String get categoryDeleteConfirm => '确定要删除这个分类吗？删除后该分类下的所有待办事项将变为未分类。';

  @override
  String get syncSettings => '同步设置';

  @override
  String get serverUrl => '服务器地址';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get testConnection => '测试连接';

  @override
  String get connectionSuccess => '连接成功';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get saveSettings => '保存设置';

  @override
  String get syncType => '同步类型';

  @override
  String get webdav => 'WebDAV';

  @override
  String get themeSettings => '主题设置';

  @override
  String get lightTheme => '浅色主题';

  @override
  String get darkTheme => '深色主题';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get accentColor => '主题色';

  @override
  String get searchTodos => '搜索待办事项';

  @override
  String get noTodosFound => '未找到待办事项';

  @override
  String get noTodosNow => '暂无待办事项';

  @override
  String get noTodosInCategory => '该分类下暂无待办事项';

  @override
  String get createFirstTodo => '创建你的第一个待办事项';

  @override
  String get todayTodos => '今日待办';

  @override
  String get overdueTodos => '逾期待办';

  @override
  String get upcomingTodos => '即将到期';

  @override
  String get syncSuccess => '同步成功';

  @override
  String get syncFailed => '同步失败';

  @override
  String get lastSyncTime => '上次同步时间';

  @override
  String get neverSynced => '从未同步';

  @override
  String get exportData => '导出数据';

  @override
  String get importData => '导入数据';

  @override
  String get exportSuccess => '导出成功';

  @override
  String get importSuccess => '导入成功';

  @override
  String get exportFailed => '导出失败';

  @override
  String get importFailed => '导入失败';

  @override
  String get clearAllData => '清空所有数据';

  @override
  String get clearDataConfirm => '确定要清空所有数据吗？此操作不可撤销。';

  @override
  String get dataCleared => '数据已清空';

  @override
  String get version => '版本';

  @override
  String get buildNumber => '构建号';

  @override
  String get developer => '开发者';

  @override
  String get license => '许可证';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get networkError => '网络错误';

  @override
  String get serverError => '服务器错误';

  @override
  String get unknownError => '未知错误';

  @override
  String get confirm => '确认';

  @override
  String get ok => '确定';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get previous => '上一步';

  @override
  String get finish => '完成';

  @override
  String get todaySchedule => '今日日程';

  @override
  String get weekView => '周视图';

  @override
  String get monthView => '月视图';

  @override
  String get yearView => '年视图';

  @override
  String get noDataToShow => 'No data to show';

  @override
  String get refresh => '刷新';

  @override
  String get releaseToRefresh => 'Release to refresh';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get refreshCompleted => 'Refresh completed';

  @override
  String uncompletedTodosOnDate(int day, int count) {
    return '$day日未完成 ($count)';
  }

  @override
  String completedTodosOnDate(int day, int count) {
    return '$day日已完成 ($count)';
  }

  @override
  String get noTodosOnDate => '这一天没有待办事项';

  @override
  String get selectDate => '选择日期';

  @override
  String get followSystem => '跟随系统';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get languageChanged => '语言已切换';
}
