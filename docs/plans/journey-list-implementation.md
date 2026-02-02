# Journey List Implementation with Admin Controls

## Implementation Progress

- [x] **Phase 1: Admin Portal - Settings Infrastructure** ✅ COMPLETED
  - [x] Database migration created
  - [x] Settings service extended
  - [x] Mobile features widget created
  - [x] Mobile features view model created
  - [x] Settings page integrated
- [x] **Phase 2: Mobile App - Settings Infrastructure** ✅ COMPLETED
  - [x] Settings repository created
  - [x] App config model created
  - [x] App state extended with config loading
- [x] **Phase 3: Mobile App - Journey List Data Layer** ✅ COMPLETED
  - [x] Journeys repository extended with list methods
- [x] **Phase 4: Mobile App - Journey List UI Layer** ✅ COMPLETED
  - [x] Journey list view model created
  - [x] Journey card widget created
  - [x] Journeys tab widget created
  - [x] Journey list page created
- [x] **Phase 5: Mobile App - Navigation Integration** ✅ COMPLETED
  - [x] Journey page updated (removed hardcoded default)
  - [x] Nav bar updated with conditional tabs
  - [x] Journey list route added to router
  - [x] Settings load added to app initialization (splash screen)

---

## Overview
Implement a Journey list screen in the mobile app (similar to Community/Groups) with administrative toggles to:
1. Enable/disable journey list (default: enabled) - when disabled, opens journey ID=1 directly
2. Enable/disable community module (default: enabled) - controls bottom nav visibility

## Architecture Summary

### Mobile App Structure
- **My Journeys**: Journeys user has started (from `cc_user_journeys`)
- **Other Journeys**: Public journeys + private journeys accessible via user's group memberships
- **Access Control**: Private journeys shown only if user is member of associated groups (via `cc_group_journeys` → `cc_group_members`)

### Admin Portal Structure
- Settings stored in `cc_settings` table with category `mobile_features`
- Toggle switches for both features
- Changes sync to mobile app via direct Supabase queries

---

## Implementation Plan

## Phase 1: Admin Portal - Settings Infrastructure

### 1.1 Database Migration
**Create**: SQL migration file in admin portal docs

```sql
INSERT INTO cc_settings (setting_key, setting_name, description, value, value_type, category, created_at, updated_at)
VALUES
  ('enable_journey_list', 'Enable Journey List', 'Show journey list page vs. journey ID=1 only', 'true', 'boolean', 'mobile_features', NOW(), NOW()),
  ('enable_community_module', 'Enable Community Module', 'Show/hide community in bottom nav', 'true', 'boolean', 'mobile_features', NOW(), NOW())
ON CONFLICT (setting_key) DO NOTHING;
```

### 1.2 Settings Service Extension
**File**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin/lib/data/services/settings_service.dart`

**Add**:
- `MobileFeaturesSettings` class with `enableJourneyList` and `enableCommunityModule` properties
- `getMobileFeaturesSettings()` method (pattern: follow `getEmailSettings()`)

### 1.3 Mobile Features Widget
**Create**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin/lib/ui/settings/widgets/mobile_features_settings/mobile_features_settings_widget.dart`

**Pattern**: Follow `email_settings_widget.dart` structure
- Two Switch widgets for the boolean settings
- Expandable section
- Save button with success/error messaging

### 1.4 Mobile Features ViewModel
**Create**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin/lib/ui/settings/widgets/mobile_features_settings/mobile_features_settings_view_model.dart`

**Pattern**: Follow `email_settings_view_model.dart`
- `loadSettings()` from `SettingsService.instance.getMobileFeaturesSettings()`
- `saveSettings()` via `SettingsService.instance.updateSettings()`

### 1.5 Settings Page Integration
**File**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/cott-portal-admin/lib/ui/settings/settings_page/settings_page.dart`

**Add**:
- `_buildMobileFeaturesSection()` method
- Add to Wrap children after email config section

---

## Phase 2: Mobile App - Settings Infrastructure

### 2.1 Settings Repository
**Create**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/data/repositories/settings_repository.dart`

**Methods**:
- `getSettingValue(String key)` - Fetch single setting
- `getSettingsByCategory(String category)` - Fetch category settings
- Uses `CcSettingsTable()` queries with graceful error handling

### 2.2 App Config Model
**Create**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/data/models/app_config.dart`

```dart
class AppConfig {
  final bool enableJourneyList;
  final bool enableCommunityModule;

  factory AppConfig.defaults() // true, true
  factory AppConfig.fromMap(Map<String, String> settings)
}
```

### 2.3 App State Extension
**File**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/app_state.dart`

**Add**:
- `AppConfig _appConfig` property with getter/setter
- `loadAppConfig(SettingsRepository)` method
- Defaults to enabled if settings fetch fails

---

## Phase 3: Mobile App - Journey List Data Layer

### 3.1 Journeys Repository Extension
**File**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/data/repositories/journeys_repository.dart`

**Add Methods**:

```dart
/// Get journeys user has started
Future<List<CcJourneysRow>> getMyJourneys(String userId) {
  // Query cc_user_journeys for journey IDs
  // Fetch journey details from cc_journeys
}

/// Get available journeys (public + private via groups, NOT started)
Future<List<CcJourneysRow>> getAvailableJourneysForList(String userId) {
  // Get started journey IDs (to exclude)
  // Get public journeys (is_public = true)
  // Get private journeys via _getPrivateJourneysForUser()
  // Combine and deduplicate
}

/// Get private journeys accessible via user's groups
Future<List<CcJourneysRow>> _getPrivateJourneysForUser(String userId) {
  // Get user's groups from cc_group_members
  // Get journeys from cc_group_journeys WHERE group_id IN user's groups
  // Join with cc_journeys to get full journey data
}
```

**Key Logic**:
- My Journeys: FROM `cc_user_journeys` WHERE `user_id`
- Other Journeys: Public journeys + private journeys (via groups) NOT already started
- Deduplication via Set to handle journeys in multiple groups

---

## Phase 4: Mobile App - Journey List UI Layer

### 4.1 Journey List ViewModel
**Create**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/ui/journey/journey_list_page/view_model/journey_list_view_model.dart`

**Pattern**: Follow `community_view_model.dart`
- `List<CcJourneysRow> myJourneys`
- `List<CcJourneysRow> availableJourneys`
- `_init()` loads both lists
- `refreshJourneysList()` for pull-to-refresh

### 4.2 Journey List Page
**Create**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/ui/journey/journey_list_page/journey_list_page.dart`

**Pattern**: Follow `community_page.dart` exactly
- ChangeNotifierProvider with JourneyListViewModel
- AppBar with "Journeys" title
- Body: `JourneysTabWidget()`
- Implement RouteAware to refresh on `didPopNext()`

### 4.3 Journeys Tab Widget
**Create**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/ui/journey/journey_list_page/widgets/journeys_tab_widget.dart`

**Pattern**: Follow `groups_tab_widget.dart` structure exactly
- SingleChildScrollView with two sections
- **"My Journeys"** section with `viewModel.myJourneys`
- Divider
- **"Other Journeys"** section with `viewModel.availableJourneys`
- Empty state messages for each section
- onTap navigates to `JourneyPage` with journeyId param

### 4.4 Journey Card Widget
**Create**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/ui/journey/journey_list_page/widgets/journey_card.dart`

**Structure**:
- Container with border/shadow (similar to group cards)
- Icon/image on left (60x60)
- Journey title and description
- Chevron right indicator

---

## Phase 5: Mobile App - Navigation Integration

### 5.1 Journey Page Update
**File**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/ui/journey/journey_page/journey_page.dart`

**Changes**:
- Line 25: Remove `?? 1` default from constructor - make `journeyId` nullable
- Constructor: `this.journeyId` (no default)
- In initState: `final int effectiveJourneyId = widget.journeyId ?? 1;`

### 5.2 Nav Bar Page Update (CRITICAL)
**File**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/ui/core/nav_bar/nav_bar_page.dart`

**Changes**:
```dart
@override
Widget build(BuildContext context) {
  // Watch app state for config
  final appState = context.watch<FFAppState>();

  // Build tabs based on config
  final tabs = _buildTabs(appState.appConfig);

  // Build bottom nav items based on config
  final navItems = _buildBottomNavItems(appState.appConfig);
}

Map<String, Widget> _buildTabs(AppConfig config) {
  return {
    'homePage': HomePage(),
    'learnListPage': LearnListPage(),
    'journeyPage': config.enableJourneyList
        ? JourneyListPage()
        : JourneyPage(journeyId: 1),
    if (config.enableCommunityModule)
      'communityPage': CommunityPage(),
    'userProfilePage': UserProfilePage(),
  };
}

List<BottomNavigationBarItem> _buildBottomNavItems(AppConfig config) {
  // Home, Library, Journey always shown
  // Community conditionally shown based on config.enableCommunityModule
  // Profile always shown
}
```

### 5.3 App Initialization
**File**: Find main entry point (likely `main.dart` or splash screen)

**Add** during app startup:
```dart
final settingsRepo = SettingsRepository();
await context.read<FFAppState>().loadAppConfig(settingsRepo);
```

---

## Phase 6: Router Updates (If Needed)

**File**: `/Users/rodrigoambros/Documents/Desenv/0.Clientes/Agencia/ProjGW/codigo/g-w-community/lib/routing/router.dart`

**Add Route** for JourneyListPage:
```dart
GoRoute(
  path: JourneyListPage.routePath,
  name: JourneyListPage.routeName,
  builder: (context, state) => const JourneyListPage(),
),
```

---

## Testing & Verification

### Admin Portal Testing
1. Navigate to Settings page
2. Verify "Mobile Features" expandable section appears
3. Toggle "Enable Journey List" → Save → Verify persists on reload
4. Toggle "Enable Community Module" → Save → Verify persists on reload
5. Database check: `SELECT * FROM cc_settings WHERE category = 'mobile_features';`

### Mobile App Testing - Journey List Enabled
1. Launch app → Settings should load (check appState.appConfig)
2. Tap Journey tab → Should show Journey List page
3. Verify "My Journeys" shows only started journeys
4. Start a journey → Verify moves from "Other" to "My" section
5. Verify "Other Journeys" shows public journeys
6. Join a group with private journey → Verify journey appears in "Other Journeys"
7. Leave group → Private journey should disappear from "Other Journeys"
8. Tap journey card → Opens JourneyPage with correct journeyId

### Mobile App Testing - Journey List Disabled
1. Admin: Disable "Enable Journey List" setting
2. Mobile: Restart app (or pull settings)
3. Tap Journey tab → Should open journey ID=1 directly (no list)

### Mobile App Testing - Community Disabled
1. Admin: Disable "Enable Community Module" setting
2. Mobile: Restart app
3. Bottom nav should show 4 tabs: Home, Library, Journey, Profile
4. Community tab hidden

### Mobile App Testing - Settings Fetch Failure
1. Simulate network error or missing settings table
2. Verify app defaults: journey list enabled, community enabled
3. Verify app doesn't crash

### Edge Cases
- **Empty lists**: Verify appropriate messages ("You haven't started any journeys yet")
- **Journey in multiple groups**: Verify no duplicates in "Other Journeys"
- **User loses group access**: Started journey stays in "My Journeys", disappears from "Other"

---

## Critical Files Reference

### Admin Portal (Create/Modify)
1. `docs/database/012_add_mobile_feature_toggles.sql` - NEW migration
2. `/data/services/settings_service.dart` - ADD methods & model
3. `/ui/settings/widgets/mobile_features_settings/mobile_features_settings_widget.dart` - NEW widget
4. `/ui/settings/widgets/mobile_features_settings/mobile_features_settings_view_model.dart` - NEW viewmodel
5. `/ui/settings/settings_page/settings_page.dart` - MODIFY add section

### Mobile App (Create/Modify)
6. `/lib/data/repositories/settings_repository.dart` - NEW repository
7. `/lib/data/models/app_config.dart` - NEW model
8. `/lib/app_state.dart` - MODIFY add config loading
9. `/lib/data/repositories/journeys_repository.dart` - MODIFY add methods
10. `/lib/ui/journey/journey_list_page/view_model/journey_list_view_model.dart` - NEW viewmodel
11. `/lib/ui/journey/journey_list_page/journey_list_page.dart` - NEW page
12. `/lib/ui/journey/journey_list_page/widgets/journeys_tab_widget.dart` - NEW widget
13. `/lib/ui/journey/journey_list_page/widgets/journey_card.dart` - NEW widget
14. `/lib/ui/journey/journey_page/journey_page.dart` - MODIFY remove default
15. `/lib/ui/core/nav_bar/nav_bar_page.dart` - MODIFY conditional tabs
16. `/lib/routing/router.dart` - ADD journey list route
17. App initialization file - ADD settings load

---

## Implementation Sequence

1. **Admin Portal** (Database → Service → UI)
   - Run migration
   - Extend settings service
   - Create widget & viewmodel
   - Integrate into settings page
   - Test admin changes

2. **Mobile Data Layer** (Bottom-up)
   - Settings repository
   - App config model
   - App state extension
   - Journeys repository methods
   - Test data methods in isolation

3. **Mobile UI Layer** (Bottom-up)
   - Journey card widget
   - Journeys tab widget
   - Journey list viewmodel
   - Journey list page
   - Test UI components

4. **Navigation Integration** (Top-down)
   - Update journey page (remove default)
   - Update nav bar (conditional tabs)
   - Add router entry
   - App initialization
   - End-to-end testing

5. **Polish & Edge Cases**
   - Test all scenarios
   - Verify edge cases
   - Performance check
   - Documentation

---

## Rollback Strategy

If issues arise:
1. **Admin Portal**: Disable "Enable Journey List" → Reverts to journey ID=1 behavior
2. **Database**: Settings are data inserts only (no schema changes) - safe to rollback
3. **Mobile App**: Graceful defaults ensure functionality even if settings fail

---

## Success Criteria

- [ ] Admin can toggle journey list enable/disable
- [ ] Admin can toggle community module enable/disable
- [ ] Settings persist and reload correctly in admin
- [ ] Mobile app shows journey list when enabled
- [ ] Mobile app shows journey ID=1 directly when list disabled
- [ ] Mobile app hides community tab when module disabled
- [ ] "My Journeys" shows only started journeys
- [ ] "Other Journeys" shows public + accessible private journeys
- [ ] Private journey access controlled by group membership
- [ ] No duplicates in journey lists
- [ ] App handles settings fetch failures gracefully
- [ ] Empty states display appropriately
- [ ] Navigation flows work correctly
- [ ] No crashes or errors in any scenario
