# What's this?

This is a strawman for a concept I'm calling "looseleaf experiment analysis".

It's heavily informed by Felix's design of mozanalysis
and assumes much of the same conceptual framework.

My goals are:
- Represent an experiment analysis more or less declaratively
- Represent metrics as summary operations in BigQuery SQL with minimal magic
  while avoiding complex string manipulations

The inputs are:
- An experiment configuration file (experiments/)
- Dataset definitions (data_sources/)
- Metrics definitions (metrics/)

You run it as e.g. `looseleaf_bind my_experiment.toml`
and it computes as much as it needs to.
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
  and will have `client_id` and `branch` columns.

A requirement is that it should be possible and easy to operate over the output
using the Spark BigQuery storage connector.

Strictly out of scope are:
- Bootstrapping confidence intervals: that should still happen in Sparkland.
  It _could_ be desirable to specify that process using this framework.
- Visualization and presentation
