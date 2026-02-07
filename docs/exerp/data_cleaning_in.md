# data_cleaning_in
Operational table for data cleaning in records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `data_cleaning_agency_id` | Foreign key field linking this record to `datacleaning_agency`. | `int4` | No | No | [datacleaning_agency](datacleaning_agency.md) via (`data_cleaning_agency_id` -> `id`) | - | `1001` |
| `exchanged_file_id` | Foreign key field linking this record to `exchanged_file`. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - | `1001` |

# Relations
- FK-linked tables: outgoing FK to [datacleaning_agency](datacleaning_agency.md), [exchanged_file](exchanged_file.md); incoming FK from [data_cleaning_in_line](data_cleaning_in_line.md).
- Second-level FK neighborhood includes: [cashcollection_requests](cashcollection_requests.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_monitor_period](data_cleaning_monitor_period.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md), [exchanged_file_sc](exchanged_file_sc.md), [gl_export_batches](gl_export_batches.md).
