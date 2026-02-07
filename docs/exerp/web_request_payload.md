# web_request_payload
Operational table for web request payload records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `web_request_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(30)` | No | No | - | - |
| `reference_center` | Center component of the composite reference to the related reference record. | `int4` | No | No | - | - |
| `reference_id` | Identifier component of the composite reference to the related reference record. | `int4` | No | No | - | - |
| `reference_subid` | Business attribute `reference_subid` used by web request payload workflows and reporting. | `int4` | Yes | No | - | - |
| `payload` | Binary payload storing structured runtime data for this record. | `bytea` | No | No | - | - |
| `send_counter` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |

# Relations
