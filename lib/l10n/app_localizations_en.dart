// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homePage => 'Home';

  @override
  String get calendarPage => 'Calendar';

  @override
  String get settingsPage => 'Settings';

  @override
  String get statistics => 'Statistics';

  @override
  String get serverConfiguration => 'Server Configuration';

  @override
  String get configureSyncSettings => 'Configure Sync Settings';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get aboutApp => 'About App';

  @override
  String get themeSwitch => 'Theme Switch';

  @override
  String get languageSwitch => 'Switch Language';

  @override
  String get settings => 'Settings';

  @override
  String get all => 'All';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get categories => 'Categories';

  @override
  String get about => 'About';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get loadFailed => 'Load Failed';

  @override
  String get addTodo => 'Add a Todo';

  @override
  String get total => 'Total';

  @override
  String get completed => 'Completed';

  @override
  String get categoryCount => 'Categories';

  @override
  String get appInfo => 'App Info';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get syncImmediately => 'Sync immediately with your configured method';

  @override
  String get chooseTheme => 'Choose your favorite theme';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get todoName => 'Todo Name';

  @override
  String get todoDescription => 'Todo Description';

  @override
  String get pleaseEnterTodoName => 'Please enter todo name';

  @override
  String get category => 'Category';

  @override
  String get dueDate => 'Due Date';

  @override
  String get noDueDate => 'No Due Date';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm => 'Confirm Delete';

  @override
  String get deleteMessage => 'Are you sure you want to delete this todo?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get created => 'Created';

  @override
  String get finished => 'Finished';

  @override
  String get createdAt => 'Created at';

  @override
  String get finishedAt => 'Finished at';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get markCompleted => 'Mark Completed';

  @override
  String get markIncomplete => 'Mark Incomplete';

  @override
  String selectedCount(int count) {
    return 'Selected $count items';
  }

  @override
  String get showCompleted => 'Show Completed';

  @override
  String get hideCompleted => 'Hide Completed';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortByCreated => 'By Created Time';

  @override
  String get sortByDueDate => 'By Due Date';

  @override
  String get sortByName => 'By Name';

  @override
  String get sortByCategory => 'By Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryColor => 'Category Color';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get pleaseEnterCategoryName => 'Please enter category name';

  @override
  String get categoryDeleteConfirm =>
      'Are you sure you want to delete this category? All todos in this category will become uncategorized.';

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get connectionSuccess => 'Connection Successful';

  @override
  String get connectionFailed => 'Connection Failed';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get syncType => 'Sync Type';

  @override
  String get webdav => 'WebDAV';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get systemTheme => 'Follow System';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get searchTodos => 'Search Todos';

  @override
  String get noTodosFound => 'No todos found';

  @override
  String get noTodosNow => 'No todos now';

  @override
  String get noTodosInCategory => 'No todos in this category';

  @override
  String get createFirstTodo => 'Create your first todo';

  @override
  String get todayTodos => 'Today\'s Todos';

  @override
  String get overdueTodos => 'Overdue Todos';

  @override
  String get upcomingTodos => 'Upcoming Todos';

  @override
  String get syncSuccess => 'Sync Successful';

  @override
  String get syncFailed => 'Sync Failed';

  @override
  String get lastSyncTime => 'Last Sync Time';

  @override
  String get neverSynced => 'Never Synced';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get exportSuccess => 'Export Successful';

  @override
  String get importSuccess => 'Import Successful';

  @override
  String get exportFailed => 'Export Failed';

  @override
  String get importFailed => 'Import Failed';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearDataConfirm =>
      'Are you sure you want to clear all data? This action cannot be undone.';

  @override
  String get dataCleared => 'Data Cleared';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get developer => 'Developer';

  @override
  String get license => 'License';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get networkError => 'Network Error';

  @override
  String get serverError => 'Server Error';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get finish => 'Finish';

  @override
  String get todaySchedule => 'Today\'s Schedule';

  @override
  String get weekView => 'Week View';

  @override
  String get monthView => 'Month View';

  @override
  String get yearView => 'Year View';

  @override
  String get noDataToShow => 'No data to show';

  @override
  String get refresh => 'Refresh';

  @override
  String get releaseToRefresh => 'Release to refresh';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get refreshCompleted => 'Refresh completed';

  @override
  String uncompletedTodosOnDate(int day, int count) {
    return 'Uncompleted on ${day}th ($count)';
  }

  @override
  String completedTodosOnDate(int day, int count) {
    return 'Completed on ${day}th ($count)';
  }

  @override
  String get noTodosOnDate => 'No todos on this day';

  @override
  String get selectDate => 'Select Date';

  @override
  String get followSystem => 'Follow System';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get languageChanged => 'Language changed';
}
