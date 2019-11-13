--! name = "n_clients"
--! source = "main"
--! binding = "branch"
--! scope = ["window", "experiment"]
--! columns = ["branch", "client_id"]

SELECT
  branch,
  COUNT(DISTINCT client_id) AS {{name}}
FROM {{source}}
GROUP BY branch
