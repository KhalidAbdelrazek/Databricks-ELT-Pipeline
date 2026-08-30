# Databricks ELT Pipeline

A production-style ELT project built on Azure Databricks that simulates a fintech transaction platform, loads raw data into a landing zone, ingests it into a Medallion architecture, transforms it with dbt, and exposes curated analytical models for BI reporting in Metabase.

This project demonstrates an end-to-end modern data stack workflow:

* Synthetic data generation for core fintech entities
* Incremental ingestion from a landing zone into Bronze
* Data standardization and quality checks in Silver
* Dimensional modeling and revenue aggregates in Gold
* Reporting consumption through Metabase dashboards and reports

## Project overview

The pipeline models a fintech payments environment with customers, accounts, merchants, billers, commission rules, and transactions. It combines Databricks notebooks for ingestion/orchestration with a dbt project for transformations and testing.

At a high level, the project flow is:

1. Provision the catalog, schemas, and landing volume
2. Generate historical and incremental raw datasets into the landing zone
3. Load raw files into Bronze tables using Auto Loader-style streaming ingestion and merge logic
4. Transform Bronze data into Silver staging models with dbt
5. Build Gold dimensions, facts, snapshots, and aggregate marts with dbt
6. Connect the curated Gold layer to Metabase for reporting and business insights

## Architecture

```text
Landing Zone (/Volumes/main/default/landing_zone)
        |
        v
Bronze: raw ingestion tables in main.bronze
        |
        v
Silver: cleaned staging models in main.silver
        |
        v
Gold: dimensions, fact tables, snapshots, and aggregates in main.gold
        |
        v
Metabase: dashboards, reporting, and business analytics
```

## Technology stack

* Azure Databricks
* Unity Catalog
* Databricks Volumes
* PySpark
* Auto Loader (`cloudFiles`)
* Delta Lake merge-based upserts
* dbt for SQL transformations, testing, and snapshots
* Metabase for downstream analytics and reporting

## Repository structure

```text
Databricks-ELT-Pipeline/
├── README.md
├── init/
│   └── 1.0 init
├── generator/
│   └── landing_zone_generator
├── el/
│   └── landing_to_bronze
└── fintech_dwh/
    ├── dbt_project.yml
    ├── profiles.yml
    ├── macros/
    │   └── generate_schema_name.sql
    ├── snapshots/
    │   └── commission_rules_snapshot.sql
    └── models/
        ├── staging/
        │   ├── sources.yml
        │   ├── schema.yml
        │   ├── stg_customers.sql
        │   ├── stg_accounts.sql
        │   ├── stg_transactions.sql
        │   ├── stg_merchants.sql
        │   └── stg_billers.sql
        └── marts/
            ├── schema.yml
            ├── dim_customers.sql
            ├── dim_accounts.sql
            ├── dim_merchants.sql
            ├── dim_billers.sql
            ├── fact_transactions.sql
            ├── agg_daily_revenue.sql
            ├── agg_revenue_by_channel.sql
            └── agg_revenue_by_type.sql
```

## Data pipeline layers

### 1. Initialization

The `init/1.0 init` notebook bootstraps the project environment by creating:

* Catalog: `main`
* Schemas: `main.bronze`, `main.silver`, `main.gold`
* Landing volume: `main.default.landing_zone`

### 2. Landing zone generation

The `generator/landing_zone_generator` notebook creates synthetic fintech data in multiple raw formats to mimic realistic ingestion scenarios:

* Customers: Parquet
* Accounts: Parquet
* Merchants: CSV
* Billers: CSV
* Commission rules: Parquet
* Transactions: JSON

The generator supports both:

* Historical bootstrap loads for initial backfill
* Daily incremental runs for new records and updates

Examples of incremental behavior implemented in the notebook include:

* New customer and account creation
* Customer profile updates and account status changes
* Commission rule repricing over time
* New daily transactions and resolution of pending transactions

### 3. Bronze layer ingestion

The `el/landing_to_bronze` notebook ingests landing-zone files into `main.bronze`.

For customers, accounts, and transactions, the notebook uses streaming reads with `cloudFiles` and applies merge-based upserts into Delta tables via `foreachBatch`. This enables deduplication by business key and keeps the latest record using `updated_at`.

For reference datasets such as merchants, billers, and commission rules, the notebook creates or replaces Bronze tables directly from the landed files.

Bronze tables created by the project include:

* `main.bronze.raw_customers`
* `main.bronze.raw_accounts`
* `main.bronze.raw_transactions`
* `main.bronze.raw_merchants`
* `main.bronze.raw_billers`
* `main.bronze.raw_commission_rules`

### 4. Silver layer with dbt staging models

The dbt project maps Bronze sources into cleaned staging models in the Silver schema. These models standardize casing, trim text fields, cast data types, and derive useful flags such as whether a transaction is online or card-based.

Silver models include:

* `stg_customers`
* `stg_accounts`
* `stg_merchants`
* `stg_billers`
* `stg_transactions`

The project configures staging models as views in the Silver layer.

### 5. Gold layer with marts and analytics models

The Gold layer contains business-ready data models for analytics and BI consumption.

Core models:

* Dimensions: `dim_customers`, `dim_accounts`, `dim_merchants`, `dim_billers`
* Fact table: `fact_transactions`
* Snapshot: `commission_rules_snapshot`
* Aggregates: `agg_daily_revenue`, `agg_revenue_by_channel`, `agg_revenue_by_type`

The `fact_transactions` model enriches transactions with merchant and biller scope attributes, joins to commission rules through a dbt snapshot, and calculates:

* `commission_amount`
* `net_amount`

This makes the Gold layer especially useful for revenue analytics, operational monitoring, and reporting.

## Data quality and modeling practices

The dbt project includes schema tests to improve trust in the pipeline, including:

* `unique` and `not_null` tests on primary business keys
* `relationships` tests across dimensions and facts
* `accepted_values` tests for domains such as transaction status, transaction type, account type, account status, channel, KYC status, and country code

The project also uses a custom `generate_schema_name` macro so dbt can write models into the intended Medallion schemas instead of defaulting to the target schema name.

## Reporting and BI integration

After the Medallion architecture is built, the curated Gold models are integrated with Metabase for reporting and dashboarding.

Metabase is the presentation layer for this project and can consume Gold tables such as:

* `fact_transactions`
* `agg_daily_revenue`
* `agg_revenue_by_channel`
* `agg_revenue_by_type`
* Customer and account dimensions for drill-down analysis

This enables use cases such as:

* Daily revenue tracking
* Revenue breakdown by channel and transaction type
* Settlement and transaction performance monitoring
* Customer, merchant, and biller level analytics

## How to run the project

### Step 1: Initialize the environment

Run the `init/1.0 init` notebook to create the required catalog objects and landing volume.

### Step 2: Generate landing-zone data

Run the `generator/landing_zone_generator` notebook.

Use the `is_incremental` widget to switch between:

* `false` for initial historical bootstrap
* `true` for daily incremental simulation

### Step 3: Load Bronze tables

Run the `el/landing_to_bronze` notebook to ingest raw files from the landing zone into the Bronze schema.

### Step 4: Build Silver and Gold with dbt

From the `fintech_dwh` dbt project, execute the standard dbt workflow:

```bash
dbt snapshot
dbt run
dbt test
```

The profile is configured for Databricks SQL and expects an access token through the `DBT_ACCESS_TOKEN` environment variable.

### Step 5: Connect Metabase

Point Metabase to the curated Databricks tables in the Gold layer and build dashboards on top of the aggregate and fact models.

## Example analytical outputs

The project is designed to power reporting outputs such as:

* Daily commission revenue trends
* Gross vs. net transaction value over time
* Channel-level revenue contribution
* Transaction-type revenue mix
* Customer and account activity summaries

## Why this project stands out

This project goes beyond a basic Medallion demo by combining:

* Multi-format raw ingestion
* Incremental data simulation
* Streaming-style Bronze ingestion with merge logic
* dbt-based transformation, testing, and snapshotting
* Business-ready Gold marts
* Metabase integration for real reporting consumption

It is a strong portfolio project for demonstrating practical data engineering and analytics engineering skills on Databricks.
