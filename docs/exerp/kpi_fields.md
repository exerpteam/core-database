# kpi_fields
Operational table for kpi fields records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 65 query files; common companions include [kpi_data](kpi_data.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `KEY` | Operational field `KEY` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `display_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `display_decimals` | Business attribute `display_decimals` used by kpi fields workflows and reporting. | `int4` | No | No | - | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `last_calculation` | Business attribute `last_calculation` used by kpi fields workflows and reporting. | `DATE` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `kpi` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `best_rate` | Business attribute `best_rate` used by kpi fields workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `recalculate_from_dependent` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `scope_aggregation` | Business attribute `scope_aggregation` used by kpi fields workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `time_aggregation` | Business attribute `time_aggregation` used by kpi fields workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `dashboard` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `dashboard_scale_from` | Business attribute `dashboard_scale_from` used by kpi fields workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `dashboard_scale_to` | Business attribute `dashboard_scale_to` used by kpi fields workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `dashboard_target_fieldid` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [kpi_fields](kpi_fields.md) via (`dashboard_target_fieldid` -> `id`) | - |
| `benchmark` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `benchmark_interval_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `benchmark_scope` | Business attribute `benchmark_scope` used by kpi fields workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `live` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `dashboard_warning_percentage` | Business attribute `dashboard_warning_percentage` used by kpi fields workflows and reporting. | `int4` | No | No | - | - |
| `refresh_interval` | Business attribute `refresh_interval` used by kpi fields workflows and reporting. | `text(2147483647)` | No | No | - | - |

# Relations
- Commonly used with: [kpi_data](kpi_data.md) (65 query files), [centers](centers.md) (56 query files), [area_centers](area_centers.md) (32 query files), [areas](areas.md) (32 query files), [bookings](bookings.md) (23 query files), [countries](countries.md) (19 query files).
- FK-linked tables: outgoing FK to [kpi_fields](kpi_fields.md); incoming FK from [kpi_data](kpi_data.md), [kpi_field_group](kpi_field_group.md), [kpi_fields](kpi_fields.md).
- Second-level FK neighborhood includes: [centers](centers.md), [kpi_group](kpi_group.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
