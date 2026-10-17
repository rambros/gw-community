# Link to Journeys

An admin or facilitator can turn a library item or event recording into a step activity. The menu sits next to Link to Groups on the content card (library, catalog, portal event recordings, and a group's library) and in the admin content actions menu.

The new row is a real `cc_step_activities` record. Every participant of that journey sees it. People who already started that step get an open `cc_user_activities` row in the same save, so the activity shows up when they open the step again.

## Who can choose which journey

- Admin sees every journey. The app reads that role from `cc_members.user_role`. The database accepts the same list, and also `is_portal_admin()`.
- A facilitator sees only journeys linked, through `cc_group_journeys`, to groups where their membership role is `GROUP_MANAGER` or `ADMIN`.

The activity is not limited to that group. It belongs to the step.

## What the form does

1. Pick the journey.
2. Pick the step.
3. Fill the activity the same way the admin activity form does, with the type locked.

The label is required (Meditation, Inspiration, Daily Practice, Journal, or a custom label up to 40 characters). The prompt is required and starts as the item title. Order defaults to the end of the step. Required defaults to on: a new required activity blocks the next step until it is finished.

The library list does not load every media column. Before the form opens, the app reads `text`, `video_url`, the recording URL, the PDF URL, and the other media fields from `portal_item`. Those values are copied onto the activity. A text activity uses that text as it is, so the form does not ask for a text body.

The type follows the item, using the same rules as Link to Groups:

| Item | Activity | Media copied into |
| --- | --- | --- |
| audio | `audio` | `audio_url`, file name, duration, transcript |
| video | `video` | `portal_item.video_url`, or `midia_file_url` when that is empty |
| text | `text` | `text` |
| anything else, unless it already has an audio URL | `pdf` | `midia_file_url` |

There is no link back to `portal_item`. Later edits to the library item do not change the activity. Running the action again creates another activity.

Audio does not ask for an animation. Journal and image are not created from a library item.

## Database

Apply `docs/sql/link_activity_to_journey.sql` (admin migrations `20261017193840_link_activity_to_journey.sql`, `20261017200526_recognize_member_admin_for_step_activity.sql`, and `20261017202000_seed_progress_for_linked_step_activity.sql`). PDF activities also need `pdf_url` from `docs/sql/pdf_activity.sql`.

`create_step_activity_from_content` checks the caller, shifts `order_in_step` from the chosen position, inserts the step activity, and creates an open progress row for each person who already has that step. Facilitators do not get a general update policy on existing activities. `next_step_activity_order` returns the next position for the form.
