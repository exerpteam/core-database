# kpi_fields
Operational table for kpi fields records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 65 query files; common companions include [kpi_data](kpi_data.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `KEY` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `display_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `display_decimals` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `start_date` | Date when the record becomes effective. | `DATE` | No | No | - | - | `2025-01-31` |
| `configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `last_calculation` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |
| `kpi` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `best_rate` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `recalculate_from_dependent` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `scope_aggregation` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `time_aggregation` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `dashboard` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `dashboard_scale_from` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `dashboard_scale_to` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `dashboard_target_fieldid` | Foreign key field linking this record to `kpi_fields`. | `int4` | Yes | No | [kpi_fields](kpi_fields.md) via (`dashboard_target_fieldid` -> `id`) | - | `42` |
| `benchmark` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `benchmark_interval_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `benchmark_scope` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `live` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `dashboard_warning_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `refresh_interval` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |

# Relations
- Commonly used with: [kpi_data](kpi_data.md) (65 query files), [centers](centers.md) (56 query files), [area_centers](area_centers.md) (32 query files), [areas](areas.md) (32 query files), [bookings](bookings.md) (23 query files), [countries](countries.md) (19 query files).
- FK-linked tables: outgoing FK to [kpi_fields](kpi_fields.md); incoming FK from [kpi_data](kpi_data.md), [kpi_field_group](kpi_field_group.md), [kpi_fields](kpi_fields.md).
- Second-level FK neighborhood includes: [centers](centers.md), [kpi_group](kpi_group.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
