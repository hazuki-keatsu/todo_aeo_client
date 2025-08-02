import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @comment0.
  ///
  /// In en, this message translates to:
  /// **'pages/calendar_page.dart'**
  String get comment0;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @noTodoHere.
  ///
  /// In en, this message translates to:
  /// **'There is no todo here'**
  String get noTodoHere;

  /// No description provided for @noTodoToday.
  ///
  /// In en, this message translates to:
  /// **'There is no todo today'**
  String get noTodoToday;

  /// No description provided for @selectedDayHasUncompletedTodos.
  ///
  /// In en, this message translates to:
  /// **'Uncompleted on day {day} ({count})'**
  String selectedDayHasUncompletedTodos(int day, int count);

  /// No description provided for @selectedDayHasCompletedTodos.
  ///
  /// In en, this message translates to:
  /// **'Completed on day {day} ({count})'**
  String selectedDayHasCompletedTodos(int day, int count);

  /// No description provided for @comment1.
  ///
  /// In en, this message translates to:
  /// **'pages/home_page.dart'**
  String get comment1;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @uncompleted.
  ///
  /// In en, this message translates to:
  /// **'Uncompleted'**
  String get uncompleted;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @quitMultiselectionMode.
  ///
  /// In en, this message translates to:
  /// **'Quit multiselection mode'**
  String get quitMultiselectionMode;

  /// No description provided for @selectedTodos.
  ///
  /// In en, this message translates to:
  /// **'{count} todos are selected'**
  String selectedTodos(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @cancelSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelSelectAll;

  /// No description provided for @deleteAllTodosSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete all the selected todos'**
  String get deleteAllTodosSelected;

  /// No description provided for @noTodoToComplete.
  ///
  /// In en, this message translates to:
  /// **'No todo to complete'**
  String get noTodoToComplete;

  /// No description provided for @noTodoCompleted.
  ///
  /// In en, this message translates to:
  /// **'No todo completed'**
  String get noTodoCompleted;

  /// No description provided for @confirmToDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm To Delete'**
  String get confirmToDelete;

  /// No description provided for @areYouShouldDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you should delete the {count} todos you have selected?'**
  String areYouShouldDelete(int count);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @comment2.
  ///
  /// In en, this message translates to:
  /// **'pages/language_settings_page.dart'**
  String get comment2;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @languageSwitch.
  ///
  /// In en, this message translates to:
  /// **'Language Switch'**
  String get languageSwitch;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @comment3.
  ///
  /// In en, this message translates to:
  /// **'page/settings_page.dart'**
  String get comment3;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @categoryCount.
  ///
  /// In en, this message translates to:
  /// **'Category Count'**
  String get categoryCount;

  /// No description provided for @serverConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get serverConfiguration;

  /// No description provided for @configureSyncSettings.
  ///
  /// In en, this message translates to:
  /// **'Configure sync settings.'**
  String get configureSyncSettings;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @syncImmediately.
  ///
  /// In en, this message translates to:
  /// **'Sync immediately.'**
  String get syncImmediately;

  /// No description provided for @themeSwitch.
  ///
  /// In en, this message translates to:
  /// **'Theme Switch'**
  String get themeSwitch;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose the theme you like.'**
  String get chooseTheme;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you use.'**
  String get chooseLanguage;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @framework.
  ///
  /// In en, this message translates to:
  /// **'Framework'**
  String get framework;

  /// No description provided for @design.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get design;

  /// No description provided for @settingProviderState.
  ///
  /// In en, this message translates to:
  /// **'Setting Provider State'**
  String get settingProviderState;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @todoProviderState.
  ///
  /// In en, this message translates to:
  /// **'Todo Provider State'**
  String get todoProviderState;

  /// No description provided for @comment4.
  ///
  /// In en, this message translates to:
  /// **'page/sync_settings_page.dart'**
  String get comment4;

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Sync Settings'**
  String get syncSettings;

  /// No description provided for @webDAVSyncSettings.
  ///
  /// In en, this message translates to:
  /// **'WebDAV Sync Settings'**
  String get webDAVSyncSettings;

  /// No description provided for @enableSync.
  ///
  /// In en, this message translates to:
  /// **'Enable Sync'**
  String get enableSync;

  /// No description provided for @haveEnabledSync.
  ///
  /// In en, this message translates to:
  /// **'Enable sync successfully'**
  String get haveEnabledSync;

  /// No description provided for @syncUnenabled.
  ///
  /// In en, this message translates to:
  /// **'Unable to enable sync'**
  String get syncUnenabled;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @plsInputHost.
  ///
  /// In en, this message translates to:
  /// **'Please input host address'**
  String get plsInputHost;

  /// No description provided for @plsInputValidURL.
  ///
  /// In en, this message translates to:
  /// **'Please input valid URL (http:// or https://)'**
  String get plsInputValidURL;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @plsInputUserName.
  ///
  /// In en, this message translates to:
  /// **'Please input your user name'**
  String get plsInputUserName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @plsInputPassword.
  ///
  /// In en, this message translates to:
  /// **'Please input your password'**
  String get plsInputPassword;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testing;

  /// No description provided for @connectionTest.
  ///
  /// In en, this message translates to:
  /// **'Connection test'**
  String get connectionTest;

  /// No description provided for @connectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection test succeeded.'**
  String get connectionSuccess;

  /// No description provided for @connectionFailure.
  ///
  /// In en, this message translates to:
  /// **'Connection test failed. Please check your configuration.'**
  String get connectionFailure;

  /// No description provided for @comment5.
  ///
  /// In en, this message translates to:
  /// **'page/theme_settings_page.dart'**
  String get comment5;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enableDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Enable dark mode'**
  String get enableDarkMode;

  /// No description provided for @dynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Color'**
  String get dynamicColor;

  /// No description provided for @dynamicColorHint.
  ///
  /// In en, this message translates to:
  /// **'Select the main color based on wallpaper (Android 12 and above)'**
  String get dynamicColorHint;

  /// No description provided for @mainColor.
  ///
  /// In en, this message translates to:
  /// **'Main Color'**
  String get mainColor;

  /// No description provided for @currentColorDC.
  ///
  /// In en, this message translates to:
  /// **'Current color is generated by Dynamic Color'**
  String get currentColorDC;

  /// No description provided for @currentColor.
  ///
  /// In en, this message translates to:
  /// **'Current color is {color}'**
  String currentColor(String color);

  /// No description provided for @comment6.
  ///
  /// In en, this message translates to:
  /// **'page/todo_page.dart'**
  String get comment6;

  /// No description provided for @pleaseEnterTodoName.
  ///
  /// In en, this message translates to:
  /// **'Please enter todo name'**
  String get pleaseEnterTodoName;

  /// No description provided for @editTodo.
  ///
  /// In en, this message translates to:
  /// **'Edit Todo'**
  String get editTodo;

  /// No description provided for @addNewTodo.
  ///
  /// In en, this message translates to:
  /// **'Add New Todo'**
  String get addNewTodo;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveTodo.
  ///
  /// In en, this message translates to:
  /// **'Save Todo'**
  String get saveTodo;

  /// No description provided for @todoName.
  ///
  /// In en, this message translates to:
  /// **'Todo Name'**
  String get todoName;

  /// No description provided for @pleaseEnterTodoNameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter todo name'**
  String get pleaseEnterTodoNameHint;

  /// No description provided for @todoDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Todo Description (Optional)'**
  String get todoDescriptionOptional;

  /// No description provided for @pleaseEnterTodoDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter todo description'**
  String get pleaseEnterTodoDescription;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @selectCategoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Select category (optional)'**
  String get selectCategoryOptional;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No Category'**
  String get noCategory;

  /// No description provided for @finishingDate.
  ///
  /// In en, this message translates to:
  /// **'Finishing Date'**
  String get finishingDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectFinishingDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Select finishing date (optional)'**
  String get selectFinishingDateOptional;

  /// No description provided for @todoUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Todo updated successfully'**
  String get todoUpdatedSuccessfully;

  /// No description provided for @todoAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Todo added successfully'**
  String get todoAddedSuccessfully;

  /// No description provided for @updateTodoFailed.
  ///
  /// In en, this message translates to:
  /// **'Update todo failed: {error}'**
  String updateTodoFailed(String error);

  /// No description provided for @addTodoFailed.
  ///
  /// In en, this message translates to:
  /// **'Add todo failed: {error}'**
  String addTodoFailed(String error);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @enterDate.
  ///
  /// In en, this message translates to:
  /// **'Enter date'**
  String get enterDate;

  /// No description provided for @comment7.
  ///
  /// In en, this message translates to:
  /// **'providers/settings_provider.dart'**
  String get comment7;

  /// No description provided for @unknownApp.
  ///
  /// In en, this message translates to:
  /// **'Unknown application'**
  String get unknownApp;

  /// No description provided for @unknownPackageName.
  ///
  /// In en, this message translates to:
  /// **'Unknown package name'**
  String get unknownPackageName;

  /// No description provided for @unknownVersion.
  ///
  /// In en, this message translates to:
  /// **'Unknown version'**
  String get unknownVersion;

  /// No description provided for @unknownBuildNum.
  ///
  /// In en, this message translates to:
  /// **'Unknown build number'**
  String get unknownBuildNum;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @packageName.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get packageName;

  /// No description provided for @comment8.
  ///
  /// In en, this message translates to:
  /// **'providers/sync_settings_provider.dart'**
  String get comment8;

  /// No description provided for @loadSyncSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load sync settings: {error}'**
  String loadSyncSettingsFailed(String error);

  /// No description provided for @saveSyncSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save sync settings: {error}'**
  String saveSyncSettingsFailed(String error);

  /// No description provided for @pleaseCompleteConnectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Please complete the connection information'**
  String get pleaseCompleteConnectionInfo;

  /// No description provided for @connectionTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection test failed: {error}'**
  String connectionTestFailed(String error);

  /// No description provided for @comment9.
  ///
  /// In en, this message translates to:
  /// **'providers/theme_provider.dart'**
  String get comment9;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get colorCyan;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @colorBlueGray.
  ///
  /// In en, this message translates to:
  /// **'Blue Gray'**
  String get colorBlueGray;

  /// No description provided for @colorCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get colorCustom;

  /// No description provided for @comment10.
  ///
  /// In en, this message translates to:
  /// **'providers/todo_provider.dart'**
  String get comment10;

  /// No description provided for @initDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize data'**
  String get initDataFailed;

  /// No description provided for @deleteTodoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete todo item'**
  String get deleteTodoFailed;

  /// No description provided for @batchDeleteTodoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to batch delete todo items'**
  String get batchDeleteTodoFailed;

  /// No description provided for @updatePriorityFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update priority'**
  String get updatePriorityFailed;

  /// No description provided for @reorderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reorder'**
  String get reorderFailed;

  /// No description provided for @updateCompletionStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update completion status'**
  String get updateCompletionStatusFailed;

  /// No description provided for @updateCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update category'**
  String get updateCategoryFailed;

  /// No description provided for @addCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add category'**
  String get addCategoryFailed;

  /// No description provided for @todoTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get todoTitle;

  /// No description provided for @deleteCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category'**
  String get deleteCategoryFailed;

  /// No description provided for @silentSortFailed.
  ///
  /// In en, this message translates to:
  /// **'Silent sort failed'**
  String get silentSortFailed;

  /// No description provided for @comment11.
  ///
  /// In en, this message translates to:
  /// **'services/sync/data_refresh.dart'**
  String get comment11;

  /// No description provided for @syncCompletedWithConflicts.
  ///
  /// In en, this message translates to:
  /// **'Sync completed, but data conflicts found'**
  String get syncCompletedWithConflicts;

  /// No description provided for @todoConflictsCount.
  ///
  /// In en, this message translates to:
  /// **'Todo conflicts: {count} items'**
  String todoConflictsCount(int count);

  /// No description provided for @categoryConflictsCount.
  ///
  /// In en, this message translates to:
  /// **'Category conflicts: {count} items'**
  String categoryConflictsCount(int count);

  /// No description provided for @autoSelectedLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest version automatically selected, please check data'**
  String get autoSelectedLatestVersion;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @dataSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data sync successful'**
  String get dataSyncSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @webdavConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'WebDAV connection failed: {message}'**
  String webdavConnectionFailed(String message);

  /// No description provided for @dataSyncFailedWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Data sync failed: {message}'**
  String dataSyncFailedWithMessage(String message);

  /// No description provided for @syncFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailedWithError(String error);

  /// No description provided for @localDataRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Local data refresh also failed: {error}'**
  String localDataRefreshFailed(String error);

  /// No description provided for @dataConflictDetails.
  ///
  /// In en, this message translates to:
  /// **'Data Conflict Details'**
  String get dataConflictDetails;

  /// No description provided for @todoConflictsLabel.
  ///
  /// In en, this message translates to:
  /// **'Todo Conflicts:'**
  String get todoConflictsLabel;

  /// No description provided for @categoryConflictsLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Conflicts:'**
  String get categoryConflictsLabel;

  /// No description provided for @selectedLatestVersionSuffix.
  ///
  /// In en, this message translates to:
  /// **' (latest version selected)'**
  String get selectedLatestVersionSuffix;

  /// No description provided for @conflictResolutionStrategy.
  ///
  /// In en, this message translates to:
  /// **'Conflict resolution strategy: automatically select the version with the latest modification time. If the data is incorrect, please adjust manually.'**
  String get conflictResolutionStrategy;

  /// No description provided for @localDataRefreshSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local data refresh successful'**
  String get localDataRefreshSuccess;

  /// No description provided for @syncConfigIncorrectLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Sync configuration is incorrect, using local data refresh only'**
  String get syncConfigIncorrectLocalOnly;

  /// No description provided for @syncingData.
  ///
  /// In en, this message translates to:
  /// **'Syncing data...'**
  String get syncingData;

  /// No description provided for @comment12.
  ///
  /// In en, this message translates to:
  /// **'widget/shared_end_drawer.dart'**
  String get comment12;

  /// No description provided for @todoAppName.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get todoAppName;

  /// No description provided for @niceDay.
  ///
  /// In en, this message translates to:
  /// **'A nice day meets you!'**
  String get niceDay;

  /// No description provided for @uncategorize.
  ///
  /// In en, this message translates to:
  /// **'Uncategorize'**
  String get uncategorize;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add a category'**
  String get addCategory;

  /// No description provided for @comment13.
  ///
  /// In en, this message translates to:
  /// **'widget/show_dialog.dart'**
  String get comment13;

  /// No description provided for @introduction1.
  ///
  /// In en, this message translates to:
  /// **'A todo manager software aiming at brief and safe experience.'**
  String get introduction1;

  /// No description provided for @introduction2.
  ///
  /// In en, this message translates to:
  /// **'Powered by Flutter and Material You.'**
  String get introduction2;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @comment14.
  ///
  /// In en, this message translates to:
  /// **'widget/todo_tile.dart'**
  String get comment14;

  /// No description provided for @createAt.
  ///
  /// In en, this message translates to:
  /// **'Create at'**
  String get createAt;

  /// No description provided for @finishAt.
  ///
  /// In en, this message translates to:
  /// **'Finish at'**
  String get finishAt;

  /// No description provided for @categoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get categoryNotFound;

  /// No description provided for @comment15.
  ///
  /// In en, this message translates to:
  /// **'main.dart'**
  String get comment15;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryNameLabel;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @comment16.
  ///
  /// In en, this message translates to:
  /// **'main.dart'**
  String get comment16;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ToDo Aeo'**
  String get appTitle;

  /// No description provided for @webdavStartedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'WebDAV service started successfully'**
  String get webdavStartedSuccessfully;

  /// No description provided for @webdavInitializationFailed.
  ///
  /// In en, this message translates to:
  /// **'WebDAV initialization failed'**
  String get webdavInitializationFailed;

  /// No description provided for @comment_show_dialog.
  ///
  /// In en, this message translates to:
  /// **'widgets/show_dialog.dart'**
  String get comment_show_dialog;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter category name'**
  String get categoryNameRequired;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @categoryUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdateSuccess;

  /// No description provided for @categoryAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryAddSuccess;

  /// No description provided for @confirmDeleteTodo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this todo?'**
  String get confirmDeleteTodo;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get confirmDeleteCategory;

  /// No description provided for @todoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Todo not found'**
  String get todoNotFound;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @createTime.
  ///
  /// In en, this message translates to:
  /// **'Create Time'**
  String get createTime;

  /// No description provided for @finishTime.
  ///
  /// In en, this message translates to:
  /// **'Finish Time'**
  String get finishTime;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @todoCountInCategory.
  ///
  /// In en, this message translates to:
  /// **'Number of todos in this category'**
  String get todoCountInCategory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
