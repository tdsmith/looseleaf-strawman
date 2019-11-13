--! name = 'normandy_enrollments'

SELECT
  client_id,
  submission_date AS enrollment_date,
  udf.get_key(event_map_values, "branch") AS branch
FROM `moz-fx-data-shared-prod.telemetry.events`
WHERE
  submission_date >= {{experiment.start}}
  AND submission_date <= {{experiment.end_enrollment}}
  AND event_category = 'normandy'
  AND event_method = 'enroll'
  AND event_string_value = {{experiment.slug}}
