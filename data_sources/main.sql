--! name = 'main'
--! depends_on = ["normandy_enrollments"]
--! persist = true

SELECT
  {{source.normandy_enrollments}}.*,
  {{column_list}}
FROM
  `moz-fx-data-shared-prod.telemetry.main`
  RIGHT INNER JOIN {{source.normandy_enrollments}} ON (
    {{source.normandy_enrollments}}.client_id = main.client_id
    AND DATE(main.submission_timestamp) >= DATE_ADD({{source.normandy_enrollments}}.enrollment_date, {{window.start}} DAY)
    AND DATE(main.submission_timestamp) <= DATE_ADD({{source.normandy_enrollments}}.enrollment_date, {{window.end}} DAY)
  )
WHERE
  DATE(main.submission_timestamp) >= DATE_ADD({{experiment.start}}, {{window.start}} DAY)
  AND DATE(main.submission_timestamp) <= DATE_ADD({{experiment.start}}, {{window.end}} DAY)
