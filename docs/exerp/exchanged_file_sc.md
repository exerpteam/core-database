# exchanged_file_sc
Operational table for exchanged file sc records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 5 query files; common companions include [exchanged_file](exchanged_file.md), [exchanged_file_exp](exchanged_file_exp.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `scope_grouping` | Business attribute `scope_grouping` used by exchanged file sc workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `SCHEDULE` | Business attribute `SCHEDULE` used by exchanged file sc workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `schedule_configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `service` | Operational field `service` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `agency` | Business attribute `agency` used by exchanged file sc workflows and reporting. | `int4` | Yes | No | - | - |
| `agency_configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `store_in_database` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `store_in_filesystem` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `exports` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `next_schedule_day` | Business attribute `next_schedule_day` used by exchanged file sc workflows and reporting. | `DATE` | Yes | No | - | - |
| `attempts` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `filename_pattern` | Business attribute `filename_pattern` used by exchanged file sc workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `file_format` | Business attribute `file_format` used by exchanged file sc workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `export_as_gzip` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [exchanged_file](exchanged_file.md) (5 query files), [exchanged_file_exp](exchanged_file_exp.md) (4 query files), [extract](extract.md) (3 query files), [exchanged_file_op](exchanged_file_op.md) (2 query files), [areas](areas.md) (2 query files).
- FK-linked tables: incoming FK from [exchanged_file](exchanged_file.md).
- Second-level FK neighborhood includes: [cashcollection_requests](cashcollection_requests.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md), [gl_export_batches](gl_export_batches.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
