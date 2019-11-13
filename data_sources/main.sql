--! name = 'main'
--! depends_on = ["normandy_enrollments"]
--! persist = true

SELECT
  {{source.normandy_enrollments}}.*,
  {{column_list}}
FROM
  `moz-fx-data-shared-prod.telemetry.main`
  RIGHT OUTER JOIN {{source.normandy_enrollments}} ON (
    {{source.normandy_enrollments}}.client_id = main.client_id
    AND {{source.normandy_enrollments}}.enrollment_date <= submission_date
  )
WHERE
  DATE(submission_timestamp) >= {{window.start}}
  AND DATE(submission_timestamp) <= {{window.end}}
