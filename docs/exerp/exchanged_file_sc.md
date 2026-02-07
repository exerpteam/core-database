# exchanged_file_sc
Operational table for exchanged file sc records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 5 query files; common companions include [exchanged_file](exchanged_file.md), [exchanged_file_exp](exchanged_file_exp.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_grouping` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `SCHEDULE` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `schedule_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `service` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `agency` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `agency_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `store_in_database` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `store_in_filesystem` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `exports` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `next_schedule_day` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `attempts` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `filename_pattern` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `file_format` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `export_as_gzip` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |

# Relations
- Commonly used with: [exchanged_file](exchanged_file.md) (5 query files), [exchanged_file_exp](exchanged_file_exp.md) (4 query files), [EXTRACT](EXTRACT.md) (3 query files), [exchanged_file_op](exchanged_file_op.md) (2 query files), [areas](areas.md) (2 query files).
- FK-linked tables: incoming FK from [exchanged_file](exchanged_file.md).
- Second-level FK neighborhood includes: [cashcollection_requests](cashcollection_requests.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md), [gl_export_batches](gl_export_batches.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
