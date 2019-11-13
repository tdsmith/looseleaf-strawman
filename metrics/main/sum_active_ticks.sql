--! name = "sum_active_ticks"
--! source = "main"
--! scope = "window"
--! binding = "client"
--! columns = [
--!   "branch",
--!   "client_id",
--!   "payload.processes.parent.scalars.browser_engagement_active_ticks",
--! ]

SELECT
  client_id,
  branch,
  SUM(payload.processes.parent.scalars.browser_engagement_active_ticks) AS {{name}}
FROM {{source}}
GROUP BY branch
