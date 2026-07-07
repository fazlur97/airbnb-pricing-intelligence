# Manchester Airbnb Pricing Intelligence

A data pipeline and dashboard that transforms raw Airbnb listing data for Manchester into a pricing intelligence tool — helping identify underpriced and overpriced listings relative to their local market.

## Overview

This project ingests raw [Inside Airbnb](http://insideairbnb.com/) data for Manchester, transforms it through a layered dbt pipeline, and surfaces the results in an interactive Power BI dashboard covering pricing, occupancy, and neighbourhood-level trends.

## Tech stack

- **dbt** — transformation logic, testing, and modeling (staging → intermediate → mart)
- **DuckDB** — embedded analytical database powering the pipeline
- **Docker** — containerized dbt environment for reproducibility
- **Power BI** — dashboard and visualization layer
- **Parquet** — interchange format between DuckDB and Power BI

## Architecture

Raw source data → **staging** (`stg_listings`, `stg_calendar`, `stg_reviews`) → **intermediate** (`int_listings_enriched`) → **marts** (business-ready output).

Only the mart layer is exposed downstream — staging and intermediate models are internal to the pipeline and never queried directly by the dashboard.

### Mart tables

| Table | Grain | Purpose |
|---|---|---|
| `listings` | one row per listing | Core dimension — price, room type, property type, location |
| `neighbourhoods` | one row per neighbourhood | Dimension for grouping/labeling listings by area |
| `calendar` | one row per listing per date | Daily availability and price, used for occupancy and seasonality |
| `fct_listing_performance` | one row per listing | Pre-computed performance metrics, incl. occupancy rate |
| `reviews` | one row per review | Demand proxy — review volume and recency |
| `agg_neighbourhood_pricing` | one row per neighbourhood | Pre-aggregated pricing stats, computed in dbt rather than in BI |

## Getting the data into Power BI

DuckDB doesn't have a native Power BI connector, and its single-writer file lock makes a live ODBC connection fragile in practice. Mart tables are instead exported to **Parquet** from inside the dbt container and loaded into Power BI via **Get Data → Parquet**, one file per mart table. This sidesteps file-locking issues entirely and is a common pattern in real analytical pipelines.

## Known data limitations

- **Occupancy rate is a proxy, not a confirmed booking count.** It's derived from `calendar.available = false`, which can also reflect a host manually blocking dates rather than an actual reservation. It's reliable for *relative* comparisons (e.g. across neighbourhoods or listings) but shouldn't be read as an exact measurement.
- **A small number of price outliers were filtered from dashboard visuals** (values well above the normal range, likely placeholder or erroneous entries in the source scrape) to avoid skewing averages and chart scales.

## Dashboard

**Overview page** — KPI cards (average price, total listings, occupancy rate), listings by neighbourhood, and a price-vs-occupancy scatter, with slicers for room type, neighbourhood, and price range.

**Pricing opportunities page** *(planned/in progress)* — quadrant view of price vs. occupancy split at the median, surfacing listings that may be under- or overpriced relative to comparable properties.

**Seasonality page** *(planned/in progress)* — monthly price and occupancy trends from the `calendar` mart.

## Screenshots

_Add dashboard screenshots here._

## Possible next steps

- Time-based DAX measures (month-over-month price change)
- Drill-through page for individual listing detail
- Validation of occupancy proxy against real booking data, if a suitable source becomes available
