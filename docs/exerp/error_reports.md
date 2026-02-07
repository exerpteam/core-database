# error_reports
Operational table for error reports records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `client_instance` | Foreign key field linking this record to `client_instances`. | `int4` | No | No | [client_instances](client_instances.md) via (`client_instance` -> `id`) | - | `42` |
| `exceptionid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `reporter_center` | Center part of the reference to related reporter data. | `int4` | No | No | - | - | `101` |
| `reporter_id` | Identifier of the related reporter record. | `int4` | No | No | - | - | `1001` |
| `created_on` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `issue_tracker_exported_on` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `stacktrace` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `log` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `model_fields` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `ui_events` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `enviroment_info` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `clublead_central_info` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `screenshot_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `screenshot_value` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `deleted` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `title` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `automatic_generated` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `issue_tracker_id` | Identifier of the related issue tracker record. | `VARCHAR(12)` | Yes | No | - | - | `1001` |

# Relations
- FK-linked tables: outgoing FK to [client_instances](client_instances.md).
- Second-level FK neighborhood includes: [clients](clients.md), [log_in_log](log_in_log.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
