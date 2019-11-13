--! name = "fraction_slow_content_frame_time"
--! source = "main"
--! scope = "window"
--! binding = "client"
--! columns = [
--!   "branch",
--!   "client_id",
--!   "payload.processes.gpu.histograms.content_frame_time_vsync",
--! ]

WITH per_user AS (
  SELECT
    client_id,
    branch,
    SUM(udf.histogram_to_threshold_count(content_frame_time_vsync, 192)) AS slow_events,
    SUM(udf.histogram_to_threshold_count(content_frame_time_vsync, 0)) AS n_events
  FROM {{source}}
  GROUP BY
    client_id,
    branch
)

SELECT
  client_id,
  branch,
  slow_events / n_events AS {{name}}
FROM per_user
