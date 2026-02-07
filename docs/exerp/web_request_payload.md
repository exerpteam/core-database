# web_request_payload
Operational table for web request payload records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `web_request_type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - | `Sample value` |
| `reference_center` | Center part of the reference to related reference data. | `int4` | No | No | - | - | `101` |
| `reference_id` | Identifier of the related reference record. | `int4` | No | No | - | - | `1001` |
| `reference_subid` | Sub-identifier for related reference detail rows. | `int4` | Yes | No | - | - | `1` |
| `payload` | Table field used by operational and reporting workloads. | `bytea` | No | No | - | - | `Sample` |
| `send_counter` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
