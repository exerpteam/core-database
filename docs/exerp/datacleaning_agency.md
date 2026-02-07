# datacleaning_agency
Operational table for datacleaning agency records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `plugin_id` | Identifier of the related plugin record. | `text(2147483647)` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- FK-linked tables: incoming FK from [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md).
- Second-level FK neighborhood includes: [data_cleaning_in_line](data_cleaning_in_line.md), [data_cleaning_out_line](data_cleaning_out_line.md), [exchanged_file](exchanged_file.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
