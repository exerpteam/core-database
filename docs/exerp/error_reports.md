# error_reports
Operational table for error reports records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `client_instance` | Foreign key field linking this record to `client_instances`. | `int4` | No | No | [client_instances](client_instances.md) via (`client_instance` -> `id`) | - |
| `exceptionid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `reporter_center` | Center part of the reference to related reporter data. | `int4` | No | No | - | - |
| `reporter_id` | Identifier of the related reporter record. | `int4` | No | No | - | - |
| `created_on` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `issue_tracker_exported_on` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `stacktrace` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `log` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `model_fields` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `ui_events` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `enviroment_info` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `clublead_central_info` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `screenshot_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `screenshot_value` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `deleted` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `title` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `automatic_generated` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `issue_tracker_id` | Identifier of the related issue tracker record. | `VARCHAR(12)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [client_instances](client_instances.md).
- Second-level FK neighborhood includes: [clients](clients.md), [log_in_log](log_in_log.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
