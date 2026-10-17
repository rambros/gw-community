# Image activity

An image activity is a step activity whose type is `image`. The facilitator writes the prompt as the title, a reflection text, and uploads the image. On the step, the participant only sees that title, the image, and the reflection. Nothing is uploaded from the phone.

`activity_prompt` is the title. `text` is the reflection. `cc_step_activities.image_url` is the picture, stored in the public `portal` bucket under `activity-images/`.

Apply `docs/sql/image_activity.sql` before creating one. The admin activity form lists `image` next to audio, text, journal, and video.
