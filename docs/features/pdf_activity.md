# PDF activity

A PDF activity is a step activity whose type is `pdf`. The facilitator writes the same prompt used by the other activities and uploads a PDF. On the step, the participant sees that prompt and opens the document. Nothing is uploaded from the phone.

`activity_prompt` is the prompt. `cc_step_activities.pdf_url` is the file, stored in the public `portal` bucket under `activity-pdfs/`.

Apply `docs/sql/pdf_activity.sql` before creating one. The admin activity form lists `pdf` next to audio, text, journal, video, and image.
