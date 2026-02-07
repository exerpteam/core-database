# error_reports
Operational table for error reports records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `client_instance` | Identifier of the related client instances record used by this row. | `int4` | No | No | [client_instances](client_instances.md) via (`client_instance` -> `id`) | - |
| `exceptionid` | Business attribute `exceptionid` used by error reports workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `reporter_center` | Center component of the composite reference to the related reporter record. | `int4` | No | No | - | - |
| `reporter_id` | Identifier component of the composite reference to the related reporter record. | `int4` | No | No | - | - |
| `created_on` | Business attribute `created_on` used by error reports workflows and reporting. | `int8` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `issue_tracker_exported_on` | Business attribute `issue_tracker_exported_on` used by error reports workflows and reporting. | `int8` | Yes | No | - | - |
| `stacktrace` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `log` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `model_fields` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `ui_events` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `enviroment_info` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `clublead_central_info` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `screenshot_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `screenshot_value` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `deleted` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `title` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `automatic_generated` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `issue_tracker_id` | Identifier for the related issue tracker entity used by this record. | `VARCHAR(12)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [client_instances](client_instances.md).
- Second-level FK neighborhood includes: [clients](clients.md), [log_in_log](log_in_log.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
