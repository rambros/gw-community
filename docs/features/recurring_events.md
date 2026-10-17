# Recurring events

A repeating community event is one `cc_events` row. `event_date` is the first occurrence. `recurrence` is `weekly`, `biweekly`, or `monthly`. `recurrence_until` is the last date an occurrence may start.

The home and the event lists show that row once, on the next date that has not passed. After that day (or after the last day of a multi-day occurrence), the same row shows the following date. A one-off whose day has passed leaves the upcoming list and appears under Past events. Past occurrences of a repeating event are not separate rows.

Apply `docs/sql/recurring_events.sql` before creating a repeating event. That script also updates `get_user_events`, which the community event list uses. The same fields are on the event form in the admin portal.
