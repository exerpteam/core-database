# data_cleaning_out
Operational table for data cleaning out records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `data_cleaning_agency_id` | Identifier of the related datacleaning agency record used by this row. | `int4` | No | No | [datacleaning_agency](datacleaning_agency.md) via (`data_cleaning_agency_id` -> `id`) | - |
| `exchanged_file_id` | Identifier of the related exchanged file record used by this row. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [datacleaning_agency](datacleaning_agency.md), [exchanged_file](exchanged_file.md); incoming FK from [data_cleaning_out_line](data_cleaning_out_line.md).
- Second-level FK neighborhood includes: [cashcollection_requests](cashcollection_requests.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_monitor_period](data_cleaning_monitor_period.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md), [exchanged_file_sc](exchanged_file_sc.md), [gl_export_batches](gl_export_batches.md).
