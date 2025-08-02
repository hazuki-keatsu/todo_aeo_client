// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get comment0 => 'pages/calendar_page.dart';

  @override
  String get calendar => 'Calendar';

  @override
  String get refresh => 'Refresh';

  @override
  String get categories => 'Categories';

  @override
  String get noTodoHere => 'There is no todo here';

  @override
  String get noTodoToday => 'There is no todo today';

  @override
  String selectedDayHasUncompletedTodos(int day, int count) {
    return 'Uncompleted on day $day ($count)';
  }

  @override
  String selectedDayHasCompletedTodos(int day, int count) {
    return 'Completed on day $day ($count)';
  }

  @override
  String get comment1 => 'pages/home_page.dart';

  @override
  String get all => 'All';

  @override
  String get uncompleted => 'Uncompleted';

  @override
  String get completed => 'Completed';

  @override
  String get loadFailed => 'Failed to load';

  @override
  String get retry => 'Retry';

  @override
  String get quitMultiselectionMode => 'Quit multiselection mode';

  @override
  String selectedTodos(int count) {
    return '$count todos are selected';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get cancelSelectAll => 'Cancel';

  @override
  String get deleteAllTodosSelected => 'Delete all the selected todos';

  @override
  String get noTodoToComplete => 'No todo to complete';

  @override
  String get noTodoCompleted => 'No todo completed';

  @override
  String get confirmToDelete => 'Confirm To Delete';

  @override
  String areYouShouldDelete(int count) {
    return 'Are you should delete the $count todos you have selected?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get comment2 => 'pages/language_settings_page.dart';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get followSystem => 'Follow System';

  @override
  String get languageSwitch => 'Language Switch';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get comment3 => 'page/settings_page.dart';

  @override
  String get settings => 'Settings';

  @override
  String get statistics => 'Statistics';

  @override
  String get total => 'Total';

  @override
  String get categoryCount => 'Category Count';

  @override
  String get serverConfiguration => 'Server Configuration';

  @override
  String get configureSyncSettings => 'Configure sync settings.';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncImmediately => 'Sync immediately.';

  @override
  String get themeSwitch => 'Theme Switch';

  @override
  String get chooseTheme => 'Choose the theme you like.';

  @override
  String get chooseLanguage => 'Choose the language you use.';

  @override
  String get aboutApp => 'About App';

  @override
  String get loading => 'Loading';

  @override
  String get appInfo => 'App Info';

  @override
  String get framework => 'Framework';

  @override
  String get design => 'Design';

  @override
  String get settingProviderState => 'Setting Provider State';

  @override
  String get error => 'Error';

  @override
  String get todoProviderState => 'Todo Provider State';

  @override
  String get comment4 => 'page/sync_settings_page.dart';

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get webDAVSyncSettings => 'WebDAV Sync Settings';

  @override
  String get enableSync => 'Enable Sync';

  @override
  String get haveEnabledSync => 'Enable sync successfully';

  @override
  String get syncUnenabled => 'Unable to enable sync';

  @override
  String get host => 'Host';

  @override
  String get plsInputHost => 'Please input host address';

  @override
  String get plsInputValidURL => 'Please input valid URL (http:// or https://)';

  @override
  String get userName => 'User Name';

  @override
  String get plsInputUserName => 'Please input your user name';

  @override
  String get password => 'Password';

  @override
  String get plsInputPassword => 'Please input your password';

  @override
  String get testing => 'Testing...';

  @override
  String get connectionTest => 'Connection test';

  @override
  String get connectionSuccess => 'Connection test succeeded.';

  @override
  String get connectionFailure =>
      'Connection test failed. Please check your configuration.';

  @override
  String get comment5 => 'page/theme_settings_page.dart';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get enableDarkMode => 'Enable dark mode';

  @override
  String get dynamicColor => 'Dynamic Color';

  @override
  String get dynamicColorHint =>
      'Select the main color based on wallpaper (Android 12 and above)';

  @override
  String get mainColor => 'Main Color';

  @override
  String get currentColorDC => 'Current color is generated by Dynamic Color';

  @override
  String currentColor(String color) {
    return 'Current color is $color';
  }

  @override
  String get comment6 => 'page/todo_page.dart';

  @override
  String get pleaseEnterTodoName => 'Please enter todo name';

  @override
  String get editTodo => 'Edit Todo';

  @override
  String get addNewTodo => 'Add New Todo';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveTodo => 'Save Todo';

  @override
  String get todoName => 'Todo Name';

  @override
  String get pleaseEnterTodoNameHint => 'Please enter todo name';

  @override
  String get todoDescriptionOptional => 'Todo Description (Optional)';

  @override
  String get pleaseEnterTodoDescription => 'Please enter todo description';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get selectCategoryOptional => 'Select category (optional)';

  @override
  String get noCategory => 'No Category';

  @override
  String get finishingDate => 'Finishing Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectFinishingDateOptional => 'Select finishing date (optional)';

  @override
  String get todoUpdatedSuccessfully => 'Todo updated successfully';

  @override
  String get todoAddedSuccessfully => 'Todo added successfully';

  @override
  String updateTodoFailed(String error) {
    return 'Update todo failed: $error';
  }

  @override
  String addTodoFailed(String error) {
    return 'Add todo failed: $error';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get enterDate => 'Enter date';

  @override
  String get comment7 => 'providers/settings_provider.dart';

  @override
  String get unknownApp => 'Unknown application';

  @override
  String get unknownPackageName => 'Unknown package name';

  @override
  String get unknownVersion => 'Unknown version';

  @override
  String get unknownBuildNum => 'Unknown build number';

  @override
  String get version => 'Version';

  @override
  String get packageName => 'Package Name';

  @override
  String get comment8 => 'providers/sync_settings_provider.dart';

  @override
  String loadSyncSettingsFailed(String error) {
    return 'Failed to load sync settings: $error';
  }

  @override
  String saveSyncSettingsFailed(String error) {
    return 'Failed to save sync settings: $error';
  }

  @override
  String get pleaseCompleteConnectionInfo =>
      'Please complete the connection information';

  @override
  String connectionTestFailed(String error) {
    return 'Connection test failed: $error';
  }

  @override
  String get comment9 => 'providers/theme_provider.dart';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Red';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorBlueGray => 'Blue Gray';

  @override
  String get colorCustom => 'Custom';

  @override
  String get comment10 => 'providers/todo_provider.dart';

  @override
  String get initDataFailed => 'Failed to initialize data';

  @override
  String get deleteTodoFailed => 'Failed to delete todo item';

  @override
  String get batchDeleteTodoFailed => 'Failed to batch delete todo items';

  @override
  String get updatePriorityFailed => 'Failed to update priority';

  @override
  String get reorderFailed => 'Failed to reorder';

  @override
  String get updateCompletionStatusFailed =>
      'Failed to update completion status';

  @override
  String get updateCategoryFailed => 'Failed to update category';

  @override
  String get addCategoryFailed => 'Failed to add category';

  @override
  String get todoTitle => 'Title';

  @override
  String get deleteCategoryFailed => 'Failed to delete category';

  @override
  String get silentSortFailed => 'Silent sort failed';

  @override
  String get comment11 => 'services/sync/data_refresh.dart';

  @override
  String get syncCompletedWithConflicts =>
      'Sync completed, but data conflicts found';

  @override
  String todoConflictsCount(int count) {
    return 'Todo conflicts: $count items';
  }

  @override
  String categoryConflictsCount(int count) {
    return 'Category conflicts: $count items';
  }

  @override
  String get autoSelectedLatestVersion =>
      'Latest version automatically selected, please check data';

  @override
  String get viewDetails => 'View Details';

  @override
  String get dataSyncSuccess => 'Data sync successful';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String webdavConnectionFailed(String message) {
    return 'WebDAV connection failed: $message';
  }

  @override
  String dataSyncFailedWithMessage(String message) {
    return 'Data sync failed: $message';
  }

  @override
  String syncFailedWithError(String error) {
    return 'Sync failed: $error';
  }

  @override
  String localDataRefreshFailed(String error) {
    return 'Local data refresh also failed: $error';
  }

  @override
  String get dataConflictDetails => 'Data Conflict Details';

  @override
  String get todoConflictsLabel => 'Todo Conflicts:';

  @override
  String get categoryConflictsLabel => 'Category Conflicts:';

  @override
  String get selectedLatestVersionSuffix => ' (latest version selected)';

  @override
  String get conflictResolutionStrategy =>
      'Conflict resolution strategy: automatically select the version with the latest modification time. If the data is incorrect, please adjust manually.';

  @override
  String get localDataRefreshSuccess => 'Local data refresh successful';

  @override
  String get syncConfigIncorrectLocalOnly =>
      'Sync configuration is incorrect, using local data refresh only';

  @override
  String get syncingData => 'Syncing data...';

  @override
  String get comment12 => 'widget/shared_end_drawer.dart';

  @override
  String get todoAppName => 'Todo';

  @override
  String get niceDay => 'A nice day meets you!';

  @override
  String get uncategorize => 'Uncategorize';

  @override
  String get addCategory => 'Add a category';

  @override
  String get comment13 => 'widget/show_dialog.dart';

  @override
  String get introduction1 =>
      'A todo manager software aiming at brief and safe experience.';

  @override
  String get introduction2 => 'Powered by Flutter and Material You.';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get comment14 => 'widget/todo_tile.dart';

  @override
  String get createAt => 'Create at';

  @override
  String get finishAt => 'Finish at';

  @override
  String get categoryNotFound => 'Category not found';

  @override
  String get comment15 => 'main.dart';

  @override
  String get home => 'Home';

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get comment16 => 'main.dart';

  @override
  String get appTitle => 'ToDo Aeo';

  @override
  String get webdavStartedSuccessfully => 'WebDAV service started successfully';

  @override
  String get webdavInitializationFailed => 'WebDAV initialization failed';

  @override
  String get comment_show_dialog => 'widgets/show_dialog.dart';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryNameRequired => 'Please enter category name';

  @override
  String get selectColor => 'Select Color';

  @override
  String get categoryUpdateSuccess => 'Category updated successfully';

  @override
  String get categoryAddSuccess => 'Category added successfully';

  @override
  String get confirmDeleteTodo => 'Are you sure you want to delete this todo?';

  @override
  String get confirmDeleteCategory =>
      'Are you sure you want to delete this category?';

  @override
  String get todoNotFound => 'Todo not found';

  @override
  String get description => 'Description';

  @override
  String get createTime => 'Create Time';

  @override
  String get finishTime => 'Finish Time';

  @override
  String get edit => 'Edit';

  @override
  String get todoCountInCategory => 'Number of todos in this category';
}
