# exchanged_file
Operational table for exchanged file records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 17 query files; common companions include [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `service` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `agency` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `timeout_time` | Epoch timestamp for timeout. | `int8` | Yes | No | - | - | `1738281600000` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `store_in_database` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `store_in_filesystem` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `filesystem_location` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `filename` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `mime_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mime_value` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `zipped` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `filehash` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `mod` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `current_operation` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `records` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `errors` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `exported` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `file_format` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `earliest_time` | Epoch timestamp for earliest. | `int8` | Yes | No | - | - | `1738281600000` |
| `schedule_id` | Foreign key field linking this record to `exchanged_file_sc`. | `int4` | Yes | No | [exchanged_file_sc](exchanged_file_sc.md) via (`schedule_id` -> `id`) | - | `1001` |
| `reference_file_id` | Identifier of the related reference file record. | `int4` | Yes | No | - | - | `1001` |
| `retry_timeout` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `handling_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `export_as_gzip` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `entity_reference_id` | Identifier of the related entity reference record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Commonly used with: [exchanged_file_exp](exchanged_file_exp.md) (12 query files), [exchanged_file_op](exchanged_file_op.md) (9 query files), [exchanged_file_sc](exchanged_file_sc.md) (5 query files), [EXTRACT](EXTRACT.md) (5 query files), [aggregated_transactions](aggregated_transactions.md) (5 query files), [gl_export_batches](gl_export_batches.md) (5 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [exchanged_file_sc](exchanged_file_sc.md); incoming FK from [cashcollection_requests](cashcollection_requests.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md), [gl_export_batches](gl_export_batches.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
