# What's this?

This is a strawman for a concept I'm calling "looseleaf experiment analysis".

It's heavily informed by Felix's design of mozanalysis
and assumes much of the same conceptual framework.

My goals are:
- Represent an experiment analysis more or less declaratively
- Represent metrics as summary operations in BigQuery SQL with minimal magic
  while avoiding complex string manipulations

The driving motivations are:
- it's painful to access our telemetry data from PySpark
  using the BigQuery storage connector API.
- BigQuery is fast and doesn't require managing a compute cluster,
  so it makes sense to push as much work as we can into BigQuery.

The inputs are:
- An experiment configuration file (experiments/)
- Dataset definitions (data\_sources/)
- Metrics definitions (metrics/)

You run it as e.g. `looseleaf_bind my_experiment.toml`
and it computes every table that is ready to be computed that doesn't already exist.
The metrics for each analysis window are extracted once, ever.
(In a future world, some or all of the experiment configuration
could be derived from Experimenter and accessed using its REST API.)

How it should work in overview is:
- Looseleaf consults the experiment configuration to learn the experiment duration and the
  analysis windows.
- Looseleaf looks at the metrics queries listed in the experiment configuration.
  The metadata on the metrics specifies the required datasources
  and the columns that are required from them.
- Looseleaf materializes a table with the necessary columns from each data source for each window.
- Looseleaf executes each metrics query against the materialized data and materializes the result.

The output is:
- One materialized table in BigQuery for each metric for each analysis window.
  In the most common case, these will contain one row per client,
  and will (?) have `client_id` and `branch` columns.

A requirement is that it should be possible and easy to operate over the output
using the Spark BigQuery storage connector.

Strictly out of scope are:
- Bootstrapping confidence intervals: that should still happen in Sparkland.
  It _could_ be desirable to specify that process using this framework.
- Visualization and presentation

# Some open questions

- What are the right things to include in metric metadata?
  I've sprinkled a bunch of things in, more or less randomly;
  some of them are probably useful and some of them probably aren't.
- Are `client_id` and `branch` always the right grouping variables?

# Design tradeoffs

- Metrics are expressed as complete queries.
  - +: "[Explicit is better than implicit][pep20]";
    full queries (vs. fragments) limits the amount of string manipulation
  - -: Metrics have some boilerplate (e.g. writing out `GROUP BY client_id, branch`)
  - Solutions: Cut back a little and add flexibility by introducing a `{{grouping_variable_list}}`
    template variable?

- Requiring that the enrollment join is performed explicitly
  as part of the definition of a data source
  means having to write that join once for each new data source.
  An alternative is coercing all data sources into a compatible shape
  and then performing an identical join on each.
  A disadvantage of the former is that the join can be tricky to express correctly.
  A mitigation is that writing expressions for new data sources is hopefully rare.
  A disadvantage of the latter is that it introduces a new concept (a "joinable-format datasource"),
  and requires a transformation (implicitly or explicitly) of the data source
  after it's been defined.
  I fear it'll be confusing if metrics reference a data source,
  but the data source provided to the metric is not the same as the data source as-defined.

[pep20]: https://www.python.org/dev/peps/pep-0020/
