import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get navJourney;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @journeyContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get journeyContents;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get startJourney;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @startUpper.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get startUpper;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @resumeUpper.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resumeUpper;

  /// No description provided for @completedUpper.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completedUpper;

  /// No description provided for @viewAgain.
  ///
  /// In en, this message translates to:
  /// **'VIEW AGAIN'**
  String get viewAgain;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @seeAllJourneys.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllJourneys;

  /// No description provided for @seeAllGroups.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllGroups;

  /// No description provided for @journeys.
  ///
  /// In en, this message translates to:
  /// **'Journeys'**
  String get journeys;

  /// No description provided for @myJourneys.
  ///
  /// In en, this message translates to:
  /// **'My Journeys'**
  String get myJourneys;

  /// No description provided for @otherJourneys.
  ///
  /// In en, this message translates to:
  /// **'Other Journeys'**
  String get otherJourneys;

  /// No description provided for @untitledJourney.
  ///
  /// In en, this message translates to:
  /// **'Untitled Journey'**
  String get untitledJourney;

  /// No description provided for @noJourneysStarted.
  ///
  /// In en, this message translates to:
  /// **'No journeys started yet'**
  String get noJourneysStarted;

  /// No description provided for @noJourneysStartedYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t started any journeys yet'**
  String get noJourneysStartedYet;

  /// No description provided for @noOtherJourneys.
  ///
  /// In en, this message translates to:
  /// **'No other journeys available'**
  String get noOtherJourneys;

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String stepsCount(int count);

  /// No description provided for @stepsProgress.
  ///
  /// In en, this message translates to:
  /// **'Completed {completed} of {total} steps'**
  String stepsProgress(int completed, int total);

  /// No description provided for @publicLabel.
  ///
  /// In en, this message translates to:
  /// **'public'**
  String get publicLabel;

  /// No description provided for @privateLabel.
  ///
  /// In en, this message translates to:
  /// **'private'**
  String get privateLabel;

  /// No description provided for @groupPrivacyPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get groupPrivacyPublic;

  /// No description provided for @groupPrivacyPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get groupPrivacyPrivate;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @lastPostJustNow.
  ///
  /// In en, this message translates to:
  /// **'Last post just now'**
  String get lastPostJustNow;

  /// No description provided for @lastPostMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Last post {minutes} min ago'**
  String lastPostMinutesAgo(int minutes);

  /// No description provided for @lastPostHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Last post {hours} h ago'**
  String lastPostHoursAgo(int hours);

  /// No description provided for @lastPostDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Last post 1 day ago} other{Last post {count} days ago}}'**
  String lastPostDaysAgo(int count);

  /// No description provided for @lastPostOn.
  ///
  /// In en, this message translates to:
  /// **'Last post {date}'**
  String lastPostOn(String date);

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String memberCount(int count);

  /// No description provided for @groupMetaLine.
  ///
  /// In en, this message translates to:
  /// **'{privacy} - {members}'**
  String groupMetaLine(String privacy, String members);

  /// No description provided for @groupMetaDetails.
  ///
  /// In en, this message translates to:
  /// **'{privacy} group - {members}'**
  String groupMetaDetails(String privacy, String members);

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @confirmDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion of group named {name}'**
  String confirmDeleteGroup(String name);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted with success'**
  String get groupDeleted;

  /// No description provided for @welcomeComma.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcomeComma;

  /// No description provided for @communityTagline.
  ///
  /// In en, this message translates to:
  /// **'A community that shares good wishes\nto create a new world'**
  String get communityTagline;

  /// No description provided for @splashWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Good Wishes'**
  String get splashWelcomeTitle;

  /// No description provided for @splashWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A community that shares good wishes to create a new world'**
  String get splashWelcomeSubtitle;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @otherGroups.
  ///
  /// In en, this message translates to:
  /// **'Other Groups'**
  String get otherGroups;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @setNotifications.
  ///
  /// In en, this message translates to:
  /// **'Set Notifications'**
  String get setNotifications;

  /// No description provided for @editGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Edit Guidelines'**
  String get editGuidelines;

  /// No description provided for @viewAsUser.
  ///
  /// In en, this message translates to:
  /// **'View as user'**
  String get viewAsUser;

  /// No description provided for @viewAsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name or email'**
  String get viewAsSearchHint;

  /// No description provided for @viewAsSearchMin.
  ///
  /// In en, this message translates to:
  /// **'Type at least 3 characters.'**
  String get viewAsSearchMin;

  /// No description provided for @viewAsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get viewAsNoResults;

  /// No description provided for @viewAsReadOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'You can look at this member\'s groups and journeys. Nothing will be created or changed.'**
  String get viewAsReadOnlyNote;

  /// No description provided for @viewingAs.
  ///
  /// In en, this message translates to:
  /// **'Viewing as {name}'**
  String viewingAs(String name);

  /// No description provided for @exitViewAs.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitViewAs;

  /// No description provided for @resetTips.
  ///
  /// In en, this message translates to:
  /// **'Reset Tips'**
  String get resetTips;

  /// No description provided for @tipsReset.
  ///
  /// In en, this message translates to:
  /// **'Tips reset — switching tabs will show them again.'**
  String get tipsReset;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @myJournal.
  ///
  /// In en, this message translates to:
  /// **'My Journal'**
  String get myJournal;

  /// No description provided for @myExperiences.
  ///
  /// In en, this message translates to:
  /// **'My Experiences'**
  String get myExperiences;

  /// No description provided for @askAQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a Question'**
  String get askAQuestion;

  /// No description provided for @communityGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Community Guidelines'**
  String get communityGuidelines;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get yourEmail;

  /// No description provided for @yourPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get yourPassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field is required'**
  String get fieldRequired;

  /// No description provided for @accessAccountBelow.
  ///
  /// In en, this message translates to:
  /// **'Access your account below.'**
  String get accessAccountBelow;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendAccessLink.
  ///
  /// In en, this message translates to:
  /// **'Send Access Link'**
  String get sendAccessLink;

  /// No description provided for @magicLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a secure access link.'**
  String get magicLinkHint;

  /// No description provided for @emailNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Email not registered. Contact your administrator.'**
  String get emailNotRegistered;

  /// No description provided for @errorSendingLink.
  ///
  /// In en, this message translates to:
  /// **'Error sending link. Please try again.'**
  String get errorSendingLink;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email!'**
  String get checkYourEmail;

  /// No description provided for @magicLinkSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent an access link to {email}. Tap it to sign in.'**
  String magicLinkSentTo(String email);

  /// No description provided for @linkSentAgain.
  ///
  /// In en, this message translates to:
  /// **'Link sent again. Check your inbox.'**
  String get linkSentAgain;

  /// No description provided for @resendLink.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get resendLink;

  /// No description provided for @signInWithPassword.
  ///
  /// In en, this message translates to:
  /// **'Sign in with password →'**
  String get signInWithPassword;

  /// No description provided for @signInWithoutPassword.
  ///
  /// In en, this message translates to:
  /// **'← Sign in without password'**
  String get signInWithoutPassword;

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

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @deleteRead.
  ///
  /// In en, this message translates to:
  /// **'Delete read'**
  String get deleteRead;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @notificationsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsNew;

  /// No description provided for @notificationsRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationsRead;

  /// No description provided for @deleteReadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Delete read notifications'**
  String get deleteReadNotifications;

  /// No description provided for @confirmDeleteReadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all read notifications?'**
  String get confirmDeleteReadNotifications;

  /// No description provided for @deleteAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications'**
  String get deleteAllNotifications;

  /// No description provided for @confirmDeleteAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all system notifications? This cannot be undone.'**
  String get confirmDeleteAllNotifications;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgoShort(int minutes);

  /// No description provided for @hoursAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgoShort(int hours);

  /// No description provided for @daysAgoShort.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgoShort(int days);

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @hideMyLastName.
  ///
  /// In en, this message translates to:
  /// **'Hide my last name'**
  String get hideMyLastName;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @nameFallback.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameFallback;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @hideLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'You can hide your last name in your profile if you like.'**
  String get hideLastNameHint;

  /// No description provided for @agreeToTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you are agreeing to our '**
  String get agreeToTermsPrefix;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions '**
  String get termsAndConditions;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **'and '**
  String get andWord;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy.'**
  String get privacyPolicy;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @resetOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset onboarding experience'**
  String get resetOnboardingTitle;

  /// No description provided for @resetOnboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'We will clear your onboarding progress so you can go through the introduction again.'**
  String get resetOnboardingDescription;

  /// No description provided for @resetOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Reset Onboarding'**
  String get resetOnboarding;

  /// No description provided for @onboardingResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Onboarding reset successfully.'**
  String get onboardingResetSuccess;

  /// No description provided for @errorResettingOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Error resetting onboarding: {error}'**
  String errorResettingOnboarding(String error);

  /// No description provided for @errorLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Error logging out: {error}'**
  String errorLoggingOut(String error);

  /// No description provided for @yourJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Your Journal Entry'**
  String get yourJournalEntry;

  /// No description provided for @journalEntriesPrivate.
  ///
  /// In en, this message translates to:
  /// **'Your journal entries are private and secure.'**
  String get journalEntriesPrivate;

  /// No description provided for @noJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'No journal entries found.'**
  String get noJournalEntries;

  /// No description provided for @journalEntryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Journal entry not found.'**
  String get journalEntryNotFound;

  /// No description provided for @journeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get journeyLabel;

  /// No description provided for @journalSaved.
  ///
  /// In en, this message translates to:
  /// **'Journal saved'**
  String get journalSaved;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deletionOfJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Deletion of journal entry'**
  String get deletionOfJournalEntry;

  /// No description provided for @confirmDeleteJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion of this entry?'**
  String get confirmDeleteJournalEntry;

  /// No description provided for @clearing.
  ///
  /// In en, this message translates to:
  /// **'Clearing...'**
  String get clearing;

  /// No description provided for @clearEntry.
  ///
  /// In en, this message translates to:
  /// **'Clear entry'**
  String get clearEntry;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noExperiencesYet.
  ///
  /// In en, this message translates to:
  /// **'No experiences yet'**
  String get noExperiencesYet;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @allGroups.
  ///
  /// In en, this message translates to:
  /// **'All Groups'**
  String get allGroups;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get allStatus;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @inReflection.
  ///
  /// In en, this message translates to:
  /// **'In Reflection'**
  String get inReflection;

  /// No description provided for @awaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Approval'**
  String get awaitingApproval;

  /// No description provided for @notPublished.
  ///
  /// In en, this message translates to:
  /// **'Not Published'**
  String get notPublished;

  /// No description provided for @refinementSuggested.
  ///
  /// In en, this message translates to:
  /// **'Refinement Suggested'**
  String get refinementSuggested;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @deleteExperience.
  ///
  /// In en, this message translates to:
  /// **'Delete Experience'**
  String get deleteExperience;

  /// No description provided for @confirmDeleteExperience.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this experience? This action cannot be undone.'**
  String get confirmDeleteExperience;

  /// No description provided for @experienceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Experience deleted successfully'**
  String get experienceDeleted;

  /// No description provided for @publishExperience.
  ///
  /// In en, this message translates to:
  /// **'Publish Experience'**
  String get publishExperience;

  /// No description provided for @confirmPublishExperience.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to publish this experience? It will be sent for moderation review.'**
  String get confirmPublishExperience;

  /// No description provided for @experiencePublished.
  ///
  /// In en, this message translates to:
  /// **'Experience published successfully'**
  String get experiencePublished;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @revise.
  ///
  /// In en, this message translates to:
  /// **'Revise'**
  String get revise;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @visibleForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Visible for everyone'**
  String get visibleForEveryone;

  /// No description provided for @groupOnly.
  ///
  /// In en, this message translates to:
  /// **'Group only'**
  String get groupOnly;

  /// No description provided for @userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallback;

  /// No description provided for @enterNewPasswordBelow.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below.'**
  String get enterNewPasswordBelow;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts on your device even when the app is closed.'**
  String get pushNotificationsSubtitle;

  /// No description provided for @inAppNotifications.
  ///
  /// In en, this message translates to:
  /// **'In-App Notifications'**
  String get inAppNotifications;

  /// No description provided for @inAppNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the notification bell and alerts inside the app.'**
  String get inAppNotificationsSubtitle;

  /// No description provided for @startSharingExperiences.
  ///
  /// In en, this message translates to:
  /// **'Share your experiences with the community!'**
  String get startSharingExperiences;

  /// No description provided for @visibleOnlyFor.
  ///
  /// In en, this message translates to:
  /// **'Visible only for {group}'**
  String visibleOnlyFor(String group);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @markdownSupported.
  ///
  /// In en, this message translates to:
  /// **'Markdown supported: **bold**, *italic*, # heading, - list'**
  String get markdownSupported;

  /// No description provided for @enterGuidelinesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter community guidelines here...'**
  String get enterGuidelinesHint;

  /// No description provided for @enterEnglishGuidelinesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the English guidelines here...'**
  String get enterEnglishGuidelinesHint;

  /// No description provided for @enterPortugueseGuidelinesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the Portuguese guidelines here...'**
  String get enterPortugueseGuidelinesHint;

  /// No description provided for @guidelinesVersionsHint.
  ///
  /// In en, this message translates to:
  /// **'The app shows the version that matches the participant\'s language. If Portuguese is empty, English is used.'**
  String get guidelinesVersionsHint;

  /// No description provided for @noGuidelinesYet.
  ///
  /// In en, this message translates to:
  /// **'No guidelines available yet.'**
  String get noGuidelinesYet;

  /// No description provided for @guidelinesSaved.
  ///
  /// In en, this message translates to:
  /// **'Guidelines saved successfully!'**
  String get guidelinesSaved;

  /// No description provided for @failedToSaveGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Failed to save guidelines: {error}'**
  String failedToSaveGuidelines(String error);

  /// No description provided for @myQuestions.
  ///
  /// In en, this message translates to:
  /// **'My Questions'**
  String get myQuestions;

  /// No description provided for @supportFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get supportFilterAll;

  /// No description provided for @supportFilterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportFilterOpen;

  /// No description provided for @supportFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get supportFilterCompleted;

  /// No description provided for @failedToLoadQuestions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load questions'**
  String get failedToLoadQuestions;

  /// No description provided for @noQuestionsYet.
  ///
  /// In en, this message translates to:
  /// **'No questions yet'**
  String get noQuestionsYet;

  /// No description provided for @noQuestionsFound.
  ///
  /// In en, this message translates to:
  /// **'No questions found'**
  String get noQuestionsFound;

  /// No description provided for @haveAQuestionHelp.
  ///
  /// In en, this message translates to:
  /// **'Have a question? We\'re here to help!'**
  String get haveAQuestionHelp;

  /// No description provided for @tryChangingFilter.
  ///
  /// In en, this message translates to:
  /// **'Try changing your filter'**
  String get tryChangingFilter;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Question'**
  String get deleteQuestion;

  /// No description provided for @confirmDeleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this question? This action cannot be undone.'**
  String get confirmDeleteQuestion;

  /// No description provided for @questionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Question deleted successfully'**
  String get questionDeleted;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'Brief summary of your question'**
  String get subjectHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Please provide as much detail as possible...'**
  String get descriptionHint;

  /// No description provided for @submitQuestion.
  ///
  /// In en, this message translates to:
  /// **'Submit Question'**
  String get submitQuestion;

  /// No description provided for @questionAbout.
  ///
  /// In en, this message translates to:
  /// **'Question about:'**
  String get questionAbout;

  /// No description provided for @questionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Question submitted successfully!'**
  String get questionSubmitted;

  /// No description provided for @pleaseEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject for your question'**
  String get pleaseEnterSubject;

  /// No description provided for @subjectMinLength.
  ///
  /// In en, this message translates to:
  /// **'Subject must be at least 5 characters'**
  String get subjectMinLength;

  /// No description provided for @pleaseDescribeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please describe your question'**
  String get pleaseDescribeQuestion;

  /// No description provided for @descriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 20 characters'**
  String get descriptionMinLength;

  /// No description provided for @failedToCreateQuestion.
  ///
  /// In en, this message translates to:
  /// **'Failed to create question. Please try again.'**
  String get failedToCreateQuestion;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String anErrorOccurred(String error);

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @questionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Question not found'**
  String get questionNotFound;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @reopenQuestion.
  ///
  /// In en, this message translates to:
  /// **'Reopen Question'**
  String get reopenQuestion;

  /// No description provided for @askedOn.
  ///
  /// In en, this message translates to:
  /// **'Asked on {date}'**
  String askedOn(String date);

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference {number}'**
  String referenceNumber(String number);

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @sendMessageToStart.
  ///
  /// In en, this message translates to:
  /// **'Send a message to start the conversation'**
  String get sendMessageToStart;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @questionHasBeenCompleted.
  ///
  /// In en, this message translates to:
  /// **'This question has been completed'**
  String get questionHasBeenCompleted;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @confirmMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Are you sure your question has been answered? You can reopen it later if needed.'**
  String get confirmMarkCompleted;

  /// No description provided for @questionMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Question marked as completed'**
  String get questionMarkedCompleted;

  /// No description provided for @confirmReopenQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you need further assistance with this question?'**
  String get confirmReopenQuestion;

  /// No description provided for @questionReopened.
  ///
  /// In en, this message translates to:
  /// **'Question reopened'**
  String get questionReopened;

  /// No description provided for @supportTeam.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTeam;

  /// No description provided for @supportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusReviewed.
  ///
  /// In en, this message translates to:
  /// **'Being Reviewed'**
  String get supportStatusReviewed;

  /// No description provided for @supportStatusNeedsResponse.
  ///
  /// In en, this message translates to:
  /// **'Needs Your Response'**
  String get supportStatusNeedsResponse;

  /// No description provided for @supportStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get supportStatusCompleted;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get failedToSendMessage;

  /// No description provided for @errorSendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Error sending message: {error}'**
  String errorSendingMessage(String error);

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @tapHeartToCollectPrefix.
  ///
  /// In en, this message translates to:
  /// **'Tap '**
  String get tapHeartToCollectPrefix;

  /// No description provided for @tapHeartToCollectSuffix.
  ///
  /// In en, this message translates to:
  /// **' throughout the app to collect your favorites'**
  String get tapHeartToCollectSuffix;

  /// No description provided for @failedToLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to load favorites'**
  String get failedToLoadFavorites;

  /// No description provided for @fromLibrary.
  ///
  /// In en, this message translates to:
  /// **'From Library'**
  String get fromLibrary;

  /// No description provided for @fromJourney.
  ///
  /// In en, this message translates to:
  /// **'From Journey'**
  String get fromJourney;

  /// No description provided for @fromSource.
  ///
  /// In en, this message translates to:
  /// **'From {title}'**
  String fromSource(String title);

  /// No description provided for @stepWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Step {number}: {title}'**
  String stepWithTitle(int number, String title);

  /// No description provided for @journeyStepHeader.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String journeyStepHeader(int number);

  /// No description provided for @journeyActivityInspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get journeyActivityInspiration;

  /// No description provided for @journeyActivityMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get journeyActivityMeditation;

  /// No description provided for @journeyActivityPractices.
  ///
  /// In en, this message translates to:
  /// **'Practices'**
  String get journeyActivityPractices;

  /// No description provided for @optionalActivity.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalActivity;

  /// No description provided for @mediaAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get mediaAudio;

  /// No description provided for @mediaVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get mediaVideo;

  /// No description provided for @mediaText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get mediaText;

  /// No description provided for @mediaJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get mediaJournal;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @activityFallback.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityFallback;

  /// No description provided for @communityHintTitle.
  ///
  /// In en, this message translates to:
  /// **'The power of community'**
  String get communityHintTitle;

  /// No description provided for @communityHintMessage.
  ///
  /// In en, this message translates to:
  /// **'Join a community to connect and share experiences, encouraging thoughts, ideas, and content for self-development.'**
  String get communityHintMessage;

  /// No description provided for @libraryHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore and grow'**
  String get libraryHintTitle;

  /// No description provided for @libraryHintMessage.
  ///
  /// In en, this message translates to:
  /// **'Access a growing collection of reflections, meditations, and resources to deepen your practice and support your spiritual development.'**
  String get libraryHintMessage;

  /// No description provided for @journeyHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to a wonderful journey!'**
  String get journeyHintTitle;

  /// No description provided for @journeyHintMessage.
  ///
  /// In en, this message translates to:
  /// **'Learn, create, and share good wishes that make a real impact. Discover inspiration, meditations, and daily practices for personal and world transformation.'**
  String get journeyHintMessage;

  /// No description provided for @onboardingJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get onboardingJourneyTitle;

  /// No description provided for @onboardingJourneyBody.
  ///
  /// In en, this message translates to:
  /// **'Welcome to a wonderful journey! A journey to learn, create and share good wishes that have an impact. Good wishes are a way for self-transformation and world transformation. You will find inspirations, meditations, daily practices and companionship…'**
  String get onboardingJourneyBody;

  /// No description provided for @onboardingLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get onboardingLearnTitle;

  /// No description provided for @onboardingLearnBody.
  ///
  /// In en, this message translates to:
  /// **'When you feel that you would like to learn more, clarify or deepen your understanding and experience, new content and references are available to help you with your practice and personal progress…'**
  String get onboardingLearnBody;

  /// No description provided for @onboardingCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get onboardingCommunityTitle;

  /// No description provided for @onboardingCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'Collective good wishes are powerful. As you move along you will be part of a community of good wishers, available to help one another through the exchange of a heart-felt feelings that gives hope, strength and support… the basis for a new world.'**
  String get onboardingCommunityBody;

  /// No description provided for @onboardingBeginsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Journey Begins'**
  String get onboardingBeginsTitle;

  /// No description provided for @onboardingBeginsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up below in order to get started!'**
  String get onboardingBeginsSubtitle;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @searchAllContent.
  ///
  /// In en, this message translates to:
  /// **'Search all content...'**
  String get searchAllContent;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @listOfAllContent.
  ///
  /// In en, this message translates to:
  /// **'List of All Content'**
  String get listOfAllContent;

  /// No description provided for @listOfContents.
  ///
  /// In en, this message translates to:
  /// **'List of Contents'**
  String get listOfContents;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @noContentFound.
  ///
  /// In en, this message translates to:
  /// **'No content found'**
  String get noContentFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search terms'**
  String get tryAdjustingFilters;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @contentFilter.
  ///
  /// In en, this message translates to:
  /// **'Content Filter'**
  String get contentFilter;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @selectAuthor.
  ///
  /// In en, this message translates to:
  /// **'Select Author'**
  String get selectAuthor;

  /// No description provided for @selectEvent.
  ///
  /// In en, this message translates to:
  /// **'Select Event'**
  String get selectEvent;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @selectTopics.
  ///
  /// In en, this message translates to:
  /// **'Select Topics'**
  String get selectTopics;

  /// No description provided for @searchAuthor.
  ///
  /// In en, this message translates to:
  /// **'Search for an author...'**
  String get searchAuthor;

  /// No description provided for @searchEvent.
  ///
  /// In en, this message translates to:
  /// **'Search for an event...'**
  String get searchEvent;

  /// No description provided for @searchYear.
  ///
  /// In en, this message translates to:
  /// **'Search for a year...'**
  String get searchYear;

  /// No description provided for @searchTapOutsideToClose.
  ///
  /// In en, this message translates to:
  /// **'Search... (tap outside to close)'**
  String get searchTapOutsideToClose;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortByRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get sortByRelevance;

  /// No description provided for @sortByDateNewest.
  ///
  /// In en, this message translates to:
  /// **'Date (newest first)'**
  String get sortByDateNewest;

  /// No description provided for @sortByDateOldest.
  ///
  /// In en, this message translates to:
  /// **'Date (oldest first)'**
  String get sortByDateOldest;

  /// No description provided for @sortByTitleAZ.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get sortByTitleAZ;

  /// No description provided for @sortByTitleZA.
  ///
  /// In en, this message translates to:
  /// **'Title (Z-A)'**
  String get sortByTitleZA;

  /// No description provided for @clearNamedFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear {label} filter'**
  String clearNamedFilter(String label);

  /// No description provided for @portalContentLibrary.
  ///
  /// In en, this message translates to:
  /// **'Portal Content Library'**
  String get portalContentLibrary;

  /// No description provided for @portalHubTitle.
  ///
  /// In en, this message translates to:
  /// **'The Call of the Time Portal'**
  String get portalHubTitle;

  /// No description provided for @portalDialoguesRetreats.
  ///
  /// In en, this message translates to:
  /// **'Dialogues & Retreats'**
  String get portalDialoguesRetreats;

  /// No description provided for @portalHeartToHeart.
  ///
  /// In en, this message translates to:
  /// **'Heart to Heart Conversations'**
  String get portalHeartToHeart;

  /// No description provided for @libraryHeaderHeartToHeart.
  ///
  /// In en, this message translates to:
  /// **'Heart to Heart'**
  String get libraryHeaderHeartToHeart;

  /// No description provided for @libraryHeaderMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get libraryHeaderMeditation;

  /// No description provided for @portalMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get portalMessages;

  /// No description provided for @wordsOfWisdom.
  ///
  /// In en, this message translates to:
  /// **'Words of Wisdom'**
  String get wordsOfWisdom;

  /// No description provided for @portalDadiJanki.
  ///
  /// In en, this message translates to:
  /// **'Dadi Janki'**
  String get portalDadiJanki;

  /// No description provided for @portalMeditations.
  ///
  /// In en, this message translates to:
  /// **'Meditations'**
  String get portalMeditations;

  /// No description provided for @portalListOfAllMessages.
  ///
  /// In en, this message translates to:
  /// **'List of All Messages'**
  String get portalListOfAllMessages;

  /// No description provided for @portalListOfAllMeditations.
  ///
  /// In en, this message translates to:
  /// **'List of All Meditations'**
  String get portalListOfAllMeditations;

  /// No description provided for @portalListOfAllDadiJanki.
  ///
  /// In en, this message translates to:
  /// **'List of All Content with Dadi Janki'**
  String get portalListOfAllDadiJanki;

  /// No description provided for @portalListOfAllDialogues.
  ///
  /// In en, this message translates to:
  /// **'List of All Dialogues & Retreats'**
  String get portalListOfAllDialogues;

  /// No description provided for @portalListOfAllHeartToHeart.
  ///
  /// In en, this message translates to:
  /// **'List of All Heart to Heart Conversations'**
  String get portalListOfAllHeartToHeart;

  /// No description provided for @portalEventContents.
  ///
  /// In en, this message translates to:
  /// **'Event contents'**
  String get portalEventContents;

  /// No description provided for @searchForADialogue.
  ///
  /// In en, this message translates to:
  /// **'Search for a dialogue...'**
  String get searchForADialogue;

  /// No description provided for @searchForAConversation.
  ///
  /// In en, this message translates to:
  /// **'Search for a conversation...'**
  String get searchForAConversation;

  /// No description provided for @searchForAMessage.
  ///
  /// In en, this message translates to:
  /// **'Search for a message...'**
  String get searchForAMessage;

  /// No description provided for @searchForAMeditation.
  ///
  /// In en, this message translates to:
  /// **'Search for a meditation...'**
  String get searchForAMeditation;

  /// No description provided for @searchForContent.
  ///
  /// In en, this message translates to:
  /// **'Search for content...'**
  String get searchForContent;

  /// No description provided for @speakers.
  ///
  /// In en, this message translates to:
  /// **'Speakers: {names}'**
  String speakers(String names);

  /// No description provided for @mainSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Main Speakers: {names}'**
  String mainSpeakers(String names);

  /// No description provided for @locationValue.
  ///
  /// In en, this message translates to:
  /// **'Location: {value}'**
  String locationValue(String value);

  /// No description provided for @eventStartEnd.
  ///
  /// In en, this message translates to:
  /// **'Start {start} - End {end}'**
  String eventStartEnd(String start, String end);

  /// No description provided for @listOfRecordings.
  ///
  /// In en, this message translates to:
  /// **'List of Recordings'**
  String get listOfRecordings;

  /// No description provided for @eventFilter.
  ///
  /// In en, this message translates to:
  /// **'Event Filter'**
  String get eventFilter;

  /// No description provided for @messageYear.
  ///
  /// In en, this message translates to:
  /// **'Message - {year}'**
  String messageYear(String year);

  /// No description provided for @fromAuthors.
  ///
  /// In en, this message translates to:
  /// **'From {names}'**
  String fromAuthors(String names);

  /// No description provided for @filterByLocation.
  ///
  /// In en, this message translates to:
  /// **'Location: {value}'**
  String filterByLocation(String value);

  /// No description provided for @filterByEventType.
  ///
  /// In en, this message translates to:
  /// **'Event type: {value}'**
  String filterByEventType(String value);

  /// No description provided for @messageFromAuthors.
  ///
  /// In en, this message translates to:
  /// **'Message from {authors}'**
  String messageFromAuthors(String authors);

  /// No description provided for @shareContent.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareContent;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocation;

  /// No description provided for @selectEventType.
  ///
  /// In en, this message translates to:
  /// **'Select event type'**
  String get selectEventType;

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orSeparator;

  /// No description provided for @withAuthors.
  ///
  /// In en, this message translates to:
  /// **'With {names}'**
  String withAuthors(String names);

  /// No description provided for @atEvent.
  ///
  /// In en, this message translates to:
  /// **'at {event}'**
  String atEvent(String event);

  /// No description provided for @linkToGroups.
  ///
  /// In en, this message translates to:
  /// **'Link to Groups'**
  String get linkToGroups;

  /// No description provided for @linkToJourneys.
  ///
  /// In en, this message translates to:
  /// **'Link to Journeys'**
  String get linkToJourneys;

  /// No description provided for @activityLinkedToStep.
  ///
  /// In en, this message translates to:
  /// **'Activity added to the step.'**
  String get activityLinkedToStep;

  /// No description provided for @failedToLinkActivity.
  ///
  /// In en, this message translates to:
  /// **'Could not add the activity.'**
  String get failedToLinkActivity;

  /// No description provided for @couldNotLoadLinkActivity.
  ///
  /// In en, this message translates to:
  /// **'Could not load.'**
  String get couldNotLoadLinkActivity;

  /// No description provided for @noJourneysToLink.
  ///
  /// In en, this message translates to:
  /// **'No journeys are linked to the groups you manage.'**
  String get noJourneysToLink;

  /// No description provided for @noJourneysAvailable.
  ///
  /// In en, this message translates to:
  /// **'No journeys available.'**
  String get noJourneysAvailable;

  /// No description provided for @noJourneysMatch.
  ///
  /// In en, this message translates to:
  /// **'No journeys match \"{query}\".'**
  String noJourneysMatch(String query);

  /// No description provided for @searchJourneys.
  ///
  /// In en, this message translates to:
  /// **'Search journeys…'**
  String get searchJourneys;

  /// No description provided for @selectJourney.
  ///
  /// In en, this message translates to:
  /// **'Select a journey'**
  String get selectJourney;

  /// No description provided for @selectStep.
  ///
  /// In en, this message translates to:
  /// **'Select a step'**
  String get selectStep;

  /// No description provided for @noStepsInJourney.
  ///
  /// In en, this message translates to:
  /// **'This journey has no steps.'**
  String get noStepsInJourney;

  /// No description provided for @noStepsMatch.
  ///
  /// In en, this message translates to:
  /// **'No steps match \"{query}\".'**
  String noStepsMatch(String query);

  /// No description provided for @searchSteps.
  ///
  /// In en, this message translates to:
  /// **'Search steps…'**
  String get searchSteps;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity label'**
  String get activityLabel;

  /// No description provided for @activityLabelCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom label'**
  String get activityLabelCustom;

  /// No description provided for @customActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customActivityLabel;

  /// No description provided for @activityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get activityTypeLabel;

  /// No description provided for @activityTypeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get activityTypeAudio;

  /// No description provided for @activityTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get activityTypeVideo;

  /// No description provided for @activityTypePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get activityTypePdf;

  /// No description provided for @activityTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get activityTypeText;

  /// No description provided for @activityPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get activityPromptLabel;

  /// No description provided for @activityOrder.
  ///
  /// In en, this message translates to:
  /// **'Order in step'**
  String get activityOrder;

  /// No description provided for @activityRequiredHelp.
  ///
  /// In en, this message translates to:
  /// **'Must be finished before the next step can open.'**
  String get activityRequiredHelp;

  /// No description provided for @activityOptionalHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. It does not count toward opening the next step.'**
  String get activityOptionalHelp;

  /// No description provided for @activityAudioUrl.
  ///
  /// In en, this message translates to:
  /// **'Audio URL'**
  String get activityAudioUrl;

  /// No description provided for @activityAudioFilename.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get activityAudioFilename;

  /// No description provided for @activityAudioDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get activityAudioDuration;

  /// No description provided for @activityVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get activityVideoUrl;

  /// No description provided for @activityPdfUrl.
  ///
  /// In en, this message translates to:
  /// **'PDF URL'**
  String get activityPdfUrl;

  /// No description provided for @activityTextBody.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get activityTextBody;

  /// No description provided for @activityLibraryTextCopied.
  ///
  /// In en, this message translates to:
  /// **'The library text is copied into this activity.'**
  String get activityLibraryTextCopied;

  /// No description provided for @activityLibraryTextMissing.
  ///
  /// In en, this message translates to:
  /// **'This library item has no text to copy.'**
  String get activityLibraryTextMissing;

  /// No description provided for @activityMediaMissing.
  ///
  /// In en, this message translates to:
  /// **'Add the file or text for this activity type.'**
  String get activityMediaMissing;

  /// No description provided for @activityLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a label.'**
  String get activityLabelRequired;

  /// No description provided for @activityLabelTooLong.
  ///
  /// In en, this message translates to:
  /// **'Label must be 40 characters or less.'**
  String get activityLabelTooLong;

  /// No description provided for @activityPromptRequired.
  ///
  /// In en, this message translates to:
  /// **'Write a prompt.'**
  String get activityPromptRequired;

  /// No description provided for @activityPromptTooLong.
  ///
  /// In en, this message translates to:
  /// **'Prompt must be 130 characters or less.'**
  String get activityPromptTooLong;

  /// No description provided for @activityOrderInvalid.
  ///
  /// In en, this message translates to:
  /// **'Order must be 1 or more.'**
  String get activityOrderInvalid;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add activity'**
  String get addActivity;

  /// No description provided for @stepNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepNumberLabel(int number);

  /// No description provided for @groupLinksUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group links updated.'**
  String get groupLinksUpdated;

  /// No description provided for @failedToUpdateLinks.
  ///
  /// In en, this message translates to:
  /// **'Failed to update links.'**
  String get failedToUpdateLinks;

  /// No description provided for @noGroupsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No groups available.'**
  String get noGroupsAvailable;

  /// No description provided for @noGroupsMatch.
  ///
  /// In en, this message translates to:
  /// **'No groups match \"{query}\".'**
  String noGroupsMatch(String query);

  /// No description provided for @searchGroups.
  ///
  /// In en, this message translates to:
  /// **'Search groups…'**
  String get searchGroups;

  /// No description provided for @willBeUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Will be unlinked'**
  String get willBeUnlinked;

  /// No description provided for @willBeLinked.
  ///
  /// In en, this message translates to:
  /// **'Will be linked'**
  String get willBeLinked;

  /// No description provided for @noFilter.
  ///
  /// In en, this message translates to:
  /// **'No filter'**
  String get noFilter;

  /// No description provided for @filteredBySearch.
  ///
  /// In en, this message translates to:
  /// **'Filtered by Search Field → {query}'**
  String filteredBySearch(String query);

  /// No description provided for @filtersApplied.
  ///
  /// In en, this message translates to:
  /// **'Filters → {filters}'**
  String filtersApplied(String filters);

  /// No description provided for @filterByAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author: {value}'**
  String filterByAuthor(String value);

  /// No description provided for @filterByEvent.
  ///
  /// In en, this message translates to:
  /// **'Event: {value}'**
  String filterByEvent(String value);

  /// No description provided for @filterByYear.
  ///
  /// In en, this message translates to:
  /// **'Year: {value}'**
  String filterByYear(String value);

  /// No description provided for @filterByJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey: {value}'**
  String filterByJourney(String value);

  /// No description provided for @filterByGroup.
  ///
  /// In en, this message translates to:
  /// **'Group: {value}'**
  String filterByGroup(String value);

  /// No description provided for @filterByTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics: {value}'**
  String filterByTopics(String value);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutGroup.
  ///
  /// In en, this message translates to:
  /// **'About Group'**
  String get aboutGroup;

  /// No description provided for @aboutThisGroup.
  ///
  /// In en, this message translates to:
  /// **'About this group'**
  String get aboutThisGroup;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @leaveTheGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave the Group'**
  String get leaveTheGroup;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @confirmLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this group?'**
  String get confirmLeaveGroup;

  /// No description provided for @leftGroupSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Left the group successfully'**
  String get leftGroupSuccessfully;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @updateGroup.
  ///
  /// In en, this message translates to:
  /// **'Update Group'**
  String get updateGroup;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroup;

  /// No description provided for @joinedGroupSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'You have joined the group successfully'**
  String get joinedGroupSuccessfully;

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group Not Found'**
  String get groupNotFound;

  /// No description provided for @groupInformationMissing.
  ///
  /// In en, this message translates to:
  /// **'Group information is missing.'**
  String get groupInformationMissing;

  /// No description provided for @privateGroupInviteOnly.
  ///
  /// In en, this message translates to:
  /// **'This is a private group. You need an invitation to join and see the content.'**
  String get privateGroupInviteOnly;

  /// No description provided for @facilitators.
  ///
  /// In en, this message translates to:
  /// **'Facilitators'**
  String get facilitators;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get noMembersFound;

  /// No description provided for @noMembersInGroup.
  ///
  /// In en, this message translates to:
  /// **'No members in this group'**
  String get noMembersInGroup;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @tabExperiences.
  ///
  /// In en, this message translates to:
  /// **'Experiences'**
  String get tabExperiences;

  /// No description provided for @tabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get tabEvents;

  /// No description provided for @tabMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get tabMessages;

  /// No description provided for @tabResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get tabResources;

  /// No description provided for @newExperience.
  ///
  /// In en, this message translates to:
  /// **'New experience'**
  String get newExperience;

  /// No description provided for @shareExperiencesSpace.
  ///
  /// In en, this message translates to:
  /// **'A space to share your experiences, inspire others, and receive good wishes from the community'**
  String get shareExperiencesSpace;

  /// No description provided for @experienceUnpublished.
  ///
  /// In en, this message translates to:
  /// **'Experience unpublished'**
  String get experienceUnpublished;

  /// No description provided for @experiencesInspire.
  ///
  /// In en, this message translates to:
  /// **'Experience experiences that inspire'**
  String get experiencesInspire;

  /// No description provided for @errorLoadingExperiences.
  ///
  /// In en, this message translates to:
  /// **'Error loading experiences'**
  String get errorLoadingExperiences;

  /// No description provided for @beFirstToShareExperience.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share an experience with everyone'**
  String get beFirstToShareExperience;

  /// No description provided for @noExperiencesYetPeriod.
  ///
  /// In en, this message translates to:
  /// **'No experiences yet.'**
  String get noExperiencesYetPeriod;

  /// No description provided for @fromGroup.
  ///
  /// In en, this message translates to:
  /// **'From group {name}'**
  String fromGroup(String name);

  /// No description provided for @likedShareExperience.
  ///
  /// In en, this message translates to:
  /// **'How about sharing your experience?'**
  String get likedShareExperience;

  /// No description provided for @shareInGroups.
  ///
  /// In en, this message translates to:
  /// **'Share in'**
  String get shareInGroups;

  /// No description provided for @chooseGroups.
  ///
  /// In en, this message translates to:
  /// **'Choose groups'**
  String get chooseGroups;

  /// No description provided for @chooseOneOrMoreGroups.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more groups where you want to share your experience.'**
  String get chooseOneOrMoreGroups;

  /// No description provided for @noGroupsToShare.
  ///
  /// In en, this message translates to:
  /// **'Join a group to share your experience.'**
  String get noGroupsToShare;

  /// No description provided for @shareYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get shareYourExperience;

  /// No description provided for @writeAboutExperience.
  ///
  /// In en, this message translates to:
  /// **'Write about your experience...'**
  String get writeAboutExperience;

  /// No description provided for @enableComments.
  ///
  /// In en, this message translates to:
  /// **'Enable comments'**
  String get enableComments;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @experienceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Experience not found'**
  String get experienceNotFound;

  /// No description provided for @editExperience.
  ///
  /// In en, this message translates to:
  /// **'Edit Experience'**
  String get editExperience;

  /// No description provided for @draftNotPublishedYet.
  ///
  /// In en, this message translates to:
  /// **'Draft - Not published yet'**
  String get draftNotPublishedYet;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// No description provided for @noCommentsYetPeriod.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noCommentsYetPeriod;

  /// No description provided for @confirmDeleteThisExperience.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion of this experience?'**
  String get confirmDeleteThisExperience;

  /// No description provided for @confirmDeleteThisComment.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion of this comment?'**
  String get confirmDeleteThisComment;

  /// No description provided for @withdrawExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw this experience?'**
  String get withdrawExperienceTitle;

  /// No description provided for @withdrawExperienceMessage.
  ///
  /// In en, this message translates to:
  /// **'It will be permanently removed from the group and cannot be restored.'**
  String get withdrawExperienceMessage;

  /// No description provided for @unpublish.
  ///
  /// In en, this message translates to:
  /// **'Unpublish'**
  String get unpublish;

  /// No description provided for @unpublishExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpublish this experience?'**
  String get unpublishExperienceTitle;

  /// No description provided for @unpublishExperienceMessage.
  ///
  /// In en, this message translates to:
  /// **'The experience will be removed from public view.'**
  String get unpublishExperienceMessage;

  /// No description provided for @welcomeToReviseExperience.
  ///
  /// In en, this message translates to:
  /// **'You’re welcome to revise and share again whenever you feel ready.'**
  String get welcomeToReviseExperience;

  /// No description provided for @suggestionsSharedToRefine.
  ///
  /// In en, this message translates to:
  /// **'Suggestions were shared to help refine this experience.'**
  String get suggestionsSharedToRefine;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get newEvent;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @facilitatedBy.
  ///
  /// In en, this message translates to:
  /// **'Facilitated by {name}'**
  String facilitatedBy(String name);

  /// No description provided for @openForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Open for everyone'**
  String get openForEveryone;

  /// No description provided for @openOnlyForThisGroup.
  ///
  /// In en, this message translates to:
  /// **'Open only for this group'**
  String get openOnlyForThisGroup;

  /// No description provided for @eventLink.
  ///
  /// In en, this message translates to:
  /// **'Event Link'**
  String get eventLink;

  /// No description provided for @noRegistrationsYet.
  ///
  /// In en, this message translates to:
  /// **'No registrations yet.'**
  String get noRegistrationsYet;

  /// No description provided for @registeredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'You are registered with success'**
  String get registeredSuccessfully;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @unsubscribedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'You are unsubscribed with success'**
  String get unsubscribedSuccessfully;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @deleteThisEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete this event?'**
  String get deleteThisEvent;

  /// No description provided for @eventDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event deleted with success'**
  String get eventDeletedSuccessfully;

  /// No description provided for @eventCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event created with success'**
  String get eventCreatedSuccessfully;

  /// No description provided for @eventUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event updated with success'**
  String get eventUpdatedSuccessfully;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events found'**
  String get noUpcomingEvents;

  /// No description provided for @noRecordedEvents.
  ///
  /// In en, this message translates to:
  /// **'No recorded events found'**
  String get noRecordedEvents;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet.'**
  String get noEventsYet;

  /// No description provided for @pastEvents.
  ///
  /// In en, this message translates to:
  /// **'Past events'**
  String get pastEvents;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @facilitator.
  ///
  /// In en, this message translates to:
  /// **'Facilitator'**
  String get facilitator;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @singleDay.
  ///
  /// In en, this message translates to:
  /// **'Single Day'**
  String get singleDay;

  /// No description provided for @multiDay.
  ///
  /// In en, this message translates to:
  /// **'Multi-day'**
  String get multiDay;

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// No description provided for @doesNotRepeat.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get doesNotRepeat;

  /// No description provided for @repeatsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatsWeekly;

  /// No description provided for @repeatsEveryTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get repeatsEveryTwoWeeks;

  /// No description provided for @repeatsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatsMonthly;

  /// No description provided for @repeatUntilOptional.
  ///
  /// In en, this message translates to:
  /// **'Repeat until (optional)'**
  String get repeatUntilOptional;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearDate;

  /// No description provided for @recurrenceShowsNext.
  ///
  /// In en, this message translates to:
  /// **'The home and the event list show only the next date. When that day passes, the following one appears.'**
  String get recurrenceShowsNext;

  /// No description provided for @repeatsWeeklyDetail.
  ///
  /// In en, this message translates to:
  /// **'Repeats every week'**
  String get repeatsWeeklyDetail;

  /// No description provided for @repeatsEveryTwoWeeksDetail.
  ///
  /// In en, this message translates to:
  /// **'Repeats every 2 weeks'**
  String get repeatsEveryTwoWeeksDetail;

  /// No description provided for @repeatsMonthlyDetail.
  ///
  /// In en, this message translates to:
  /// **'Repeats every month'**
  String get repeatsMonthlyDetail;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @registrationUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Registration URL (optional)'**
  String get registrationUrlOptional;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @saveEvent.
  ///
  /// In en, this message translates to:
  /// **'Save Event'**
  String get saveEvent;

  /// No description provided for @eventHeaderImage.
  ///
  /// In en, this message translates to:
  /// **'Event image'**
  String get eventHeaderImage;

  /// No description provided for @eventHeaderImageSize.
  ///
  /// In en, this message translates to:
  /// **'Recommended: 600 × 600 px'**
  String get eventHeaderImageSize;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @activityImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get activityImageTitle;

  /// No description provided for @activityPdfUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This PDF is not available.'**
  String get activityPdfUnavailable;

  /// No description provided for @pdfViewPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pdfViewPage;

  /// No description provided for @pdfViewReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get pdfViewReading;

  /// No description provided for @pdfReadingEmpty.
  ///
  /// In en, this message translates to:
  /// **'This PDF has no text that can be enlarged. Use the page view.'**
  String get pdfReadingEmpty;

  /// No description provided for @pdfReadingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the text of this PDF.'**
  String get pdfReadingFailed;

  /// No description provided for @pdfDecreaseTextSize.
  ///
  /// In en, this message translates to:
  /// **'Decrease text size'**
  String get pdfDecreaseTextSize;

  /// No description provided for @pdfIncreaseTextSize.
  ///
  /// In en, this message translates to:
  /// **'Increase text size'**
  String get pdfIncreaseTextSize;

  /// No description provided for @usingGroupImage.
  ///
  /// In en, this message translates to:
  /// **'Using the group image'**
  String get usingGroupImage;

  /// No description provided for @useGroupImage.
  ///
  /// In en, this message translates to:
  /// **'Use group image'**
  String get useGroupImage;

  /// No description provided for @onlyThisGroup.
  ///
  /// In en, this message translates to:
  /// **'Only this group'**
  String get onlyThisGroup;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @messagesByFacilitator.
  ///
  /// In en, this message translates to:
  /// **'Messages from facilitators. Replies viewed by facilitators only'**
  String get messagesByFacilitator;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @sendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get sendTo;

  /// No description provided for @allMembersBroadcast.
  ///
  /// In en, this message translates to:
  /// **'All members (broadcast)'**
  String get allMembersBroadcast;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @messageUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Message updated with success'**
  String get messageUpdatedSuccessfully;

  /// No description provided for @messageCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Message created with success'**
  String get messageCreatedSuccessfully;

  /// No description provided for @saveMessage.
  ///
  /// In en, this message translates to:
  /// **'Save Message'**
  String get saveMessage;

  /// No description provided for @addMessage.
  ///
  /// In en, this message translates to:
  /// **'Add Message'**
  String get addMessage;

  /// No description provided for @pinMessage.
  ///
  /// In en, this message translates to:
  /// **'Pin message'**
  String get pinMessage;

  /// No description provided for @pinMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Stays at the top, even after it has been read.'**
  String get pinMessageHint;

  /// No description provided for @pinnedMessage.
  ///
  /// In en, this message translates to:
  /// **'Pinned by the facilitator'**
  String get pinnedMessage;

  /// No description provided for @newComment.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newComment;

  /// No description provided for @commentsOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get commentsOldestFirst;

  /// No description provided for @commentsNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get commentsNewestFirst;

  /// No description provided for @commentsConversationOrder.
  ///
  /// In en, this message translates to:
  /// **'Conversation order'**
  String get commentsConversationOrder;

  /// No description provided for @newReplies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new reply} other{{count} new replies}}'**
  String newReplies(int count);

  /// No description provided for @commentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 comment} other{{count} comments}}'**
  String commentCount(int count);

  /// No description provided for @confirmDeleteThisMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion of this message?'**
  String get confirmDeleteThisMessage;

  /// No description provided for @newResource.
  ///
  /// In en, this message translates to:
  /// **'New resource'**
  String get newResource;

  /// No description provided for @addResource.
  ///
  /// In en, this message translates to:
  /// **'Add Resource'**
  String get addResource;

  /// No description provided for @editResource.
  ///
  /// In en, this message translates to:
  /// **'Edit Resource'**
  String get editResource;

  /// No description provided for @noResourcesYetAddFirst.
  ///
  /// In en, this message translates to:
  /// **'No resources yet.\nTap + to add the first one.'**
  String get noResourcesYetAddFirst;

  /// No description provided for @noResourcesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No resources available yet.'**
  String get noResourcesAvailable;

  /// No description provided for @unlinkFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Unlink from Group'**
  String get unlinkFromGroup;

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @confirmUnlinkResource.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" from this group\'s Resources tab?\n\nThe original content will remain in the Library.'**
  String confirmUnlinkResource(String title);

  /// No description provided for @deleteResource.
  ///
  /// In en, this message translates to:
  /// **'Delete Resource'**
  String get deleteResource;

  /// No description provided for @confirmRemoveResource.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" from this group?'**
  String confirmRemoveResource(String title);

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get titleRequired;

  /// No description provided for @urlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL / address is required.'**
  String get urlRequired;

  /// No description provided for @failedToSaveTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get failedToSaveTryAgain;

  /// No description provided for @optionalDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get optionalDescription;

  /// No description provided for @urlAddress.
  ///
  /// In en, this message translates to:
  /// **'URL / Address'**
  String get urlAddress;

  /// No description provided for @resourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Resource title'**
  String get resourceTitle;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @youtubeVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'YouTube video URL *'**
  String get youtubeVideoUrl;

  /// No description provided for @youtubeUrl.
  ///
  /// In en, this message translates to:
  /// **'YouTube URL'**
  String get youtubeUrl;

  /// No description provided for @pleaseEnterYoutubeUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a YouTube URL.'**
  String get pleaseEnterYoutubeUrl;

  /// No description provided for @pleaseSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a file.'**
  String get pleaseSelectFile;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get uploadFailed;

  /// No description provided for @failedToSaveResource.
  ///
  /// In en, this message translates to:
  /// **'Failed to save resource.'**
  String get failedToSaveResource;

  /// No description provided for @tapToSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Tap to select file'**
  String get tapToSelectFile;

  /// No description provided for @fileRequired.
  ///
  /// In en, this message translates to:
  /// **'File *'**
  String get fileRequired;

  /// No description provided for @enterTextRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter text *'**
  String get enterTextRequired;

  /// No description provided for @pleaseEnterText.
  ///
  /// In en, this message translates to:
  /// **'Please enter the text.'**
  String get pleaseEnterText;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @markdownPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write in Markdown...'**
  String get markdownPlaceholder;

  /// No description provided for @noContentAvailable.
  ///
  /// In en, this message translates to:
  /// **'No content available.'**
  String get noContentAvailable;

  /// No description provided for @noContentFoundInResources.
  ///
  /// In en, this message translates to:
  /// **'No content found in resources.'**
  String get noContentFoundInResources;

  /// No description provided for @writeSomething.
  ///
  /// In en, this message translates to:
  /// **'Write something...'**
  String get writeSomething;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @posting.
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get posting;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @moreInformation.
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get moreInformation;

  /// No description provided for @groupManagers.
  ///
  /// In en, this message translates to:
  /// **'Group managers'**
  String get groupManagers;

  /// No description provided for @selectManagers.
  ///
  /// In en, this message translates to:
  /// **'Select Managers/ facilitators'**
  String get selectManagers;

  /// No description provided for @privateGroup.
  ///
  /// In en, this message translates to:
  /// **'Private Group'**
  String get privateGroup;

  /// No description provided for @onlyMembersCanSee.
  ///
  /// In en, this message translates to:
  /// **'Only members can see content.'**
  String get onlyMembersCanSee;

  /// No description provided for @anyoneCanSee.
  ///
  /// In en, this message translates to:
  /// **'Anyone can see content.'**
  String get anyoneCanSee;

  /// No description provided for @managersFacilitatorsCount.
  ///
  /// In en, this message translates to:
  /// **'Managers / Facilitators ({count})'**
  String managersFacilitatorsCount(int count);

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email (min 3 chars)...'**
  String get searchByNameOrEmail;

  /// No description provided for @searchToFindUsers.
  ///
  /// In en, this message translates to:
  /// **'Search to find users'**
  String get searchToFindUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @groupImage.
  ///
  /// In en, this message translates to:
  /// **'Group Image'**
  String get groupImage;

  /// No description provided for @noJourneysFoundForGroup.
  ///
  /// In en, this message translates to:
  /// **'No journeys found for this group.'**
  String get noJourneysFoundForGroup;

  /// No description provided for @noExperiencesToModerate.
  ///
  /// In en, this message translates to:
  /// **'No experiences to moderate'**
  String get noExperiencesToModerate;

  /// No description provided for @noFilteredExperiences.
  ///
  /// In en, this message translates to:
  /// **'No {filter} experiences'**
  String noFilteredExperiences(String filter);

  /// No description provided for @noPendingExperiences.
  ///
  /// In en, this message translates to:
  /// **'No Pending Experiences'**
  String get noPendingExperiences;

  /// No description provided for @confirmApproveExperience.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this experience?'**
  String get confirmApproveExperience;

  /// No description provided for @setAsNotPublished.
  ///
  /// In en, this message translates to:
  /// **'Set as Not Published'**
  String get setAsNotPublished;

  /// No description provided for @explainNotPublished.
  ///
  /// In en, this message translates to:
  /// **'Explain why this experience is not being published...'**
  String get explainNotPublished;

  /// No description provided for @suggestRefinement.
  ///
  /// In en, this message translates to:
  /// **'Suggest Refinement'**
  String get suggestRefinement;

  /// No description provided for @provideRefinementFeedback.
  ///
  /// In en, this message translates to:
  /// **'Provide feedback on what refinement is suggested...'**
  String get provideRefinementFeedback;

  /// No description provided for @pleaseProvideReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason'**
  String get pleaseProvideReason;

  /// No description provided for @provideAReason.
  ///
  /// In en, this message translates to:
  /// **'Provide a reason...'**
  String get provideAReason;

  /// No description provided for @confirmRemoveMemberNamed.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{name}\" from this group?'**
  String confirmRemoveMemberNamed(String name);

  /// No description provided for @confirmMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to {action} \"{name}\"?'**
  String confirmMemberAction(String action, String name);

  /// No description provided for @noEmailRegistered.
  ///
  /// In en, this message translates to:
  /// **'No email registered'**
  String get noEmailRegistered;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @moderation.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get moderation;

  /// No description provided for @moderationFilterAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting'**
  String get moderationFilterAwaiting;

  /// No description provided for @moderationFilterRefinement.
  ///
  /// In en, this message translates to:
  /// **'Refinement'**
  String get moderationFilterRefinement;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @approveExperience.
  ///
  /// In en, this message translates to:
  /// **'Approve Experience'**
  String get approveExperience;

  /// No description provided for @experienceApproved.
  ///
  /// In en, this message translates to:
  /// **'Experience approved successfully'**
  String get experienceApproved;

  /// No description provided for @revert.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get revert;

  /// No description provided for @refine.
  ///
  /// In en, this message translates to:
  /// **'Refine'**
  String get refine;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @errorJoiningGroup.
  ///
  /// In en, this message translates to:
  /// **'Error joining group: {error}'**
  String errorJoiningGroup(String error);

  /// No description provided for @noPermissionToDeleteExperience.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to delete this experience'**
  String get noPermissionToDeleteExperience;

  /// No description provided for @noPermissionToLockExperience.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to lock this experience'**
  String get noPermissionToLockExperience;

  /// No description provided for @messageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Message not found.'**
  String get messageNotFound;

  /// No description provided for @messageDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Message deleted successfully'**
  String get messageDeletedSuccessfully;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeBack(String name);

  /// No description provided for @journeyResources.
  ///
  /// In en, this message translates to:
  /// **'Journey resources'**
  String get journeyResources;

  /// No description provided for @restartJourney.
  ///
  /// In en, this message translates to:
  /// **'Restart journey'**
  String get restartJourney;

  /// No description provided for @aboutThisJourney.
  ///
  /// In en, this message translates to:
  /// **'About this journey'**
  String get aboutThisJourney;

  /// No description provided for @aboutNamed.
  ///
  /// In en, this message translates to:
  /// **'About {title}'**
  String aboutNamed(String title);

  /// No description provided for @resetJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset this journey'**
  String get resetJourneyTitle;

  /// No description provided for @resetJourneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Resetting your journey will delete all progress made so far. This action cannot be undone.'**
  String get resetJourneyDescription;

  /// No description provided for @resetJourneyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset journey'**
  String get resetJourneyConfirm;

  /// No description provided for @journeyResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Journey reset successfully'**
  String get journeyResetSuccess;

  /// No description provided for @errorResettingJourney.
  ///
  /// In en, this message translates to:
  /// **'Error resetting journey: {error}'**
  String errorResettingJourney(String error);
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
