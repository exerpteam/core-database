# exchanged_file
Operational table for exchanged file records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 17 query files; common companions include [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `service` | Operational field `service` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `agency` | Business attribute `agency` used by exchanged file workflows and reporting. | `int4` | Yes | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `timeout_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `store_in_database` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `store_in_filesystem` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `filesystem_location` | Business attribute `filesystem_location` used by exchanged file workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `filename` | Business attribute `filename` used by exchanged file workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `mime_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `mime_value` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `zipped` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `filehash` | Business attribute `filehash` used by exchanged file workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `mod` | Business attribute `mod` used by exchanged file workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `current_operation` | Business attribute `current_operation` used by exchanged file workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `records` | Operational field `records` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `errors` | Business attribute `errors` used by exchanged file workflows and reporting. | `int4` | Yes | No | - | - |
| `exported` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `file_format` | Business attribute `file_format` used by exchanged file workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `earliest_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `schedule_id` | Identifier of the related exchanged file sc record used by this row. | `int4` | Yes | No | [exchanged_file_sc](exchanged_file_sc.md) via (`schedule_id` -> `id`) | - |
| `reference_file_id` | Identifier for the related reference file entity used by this record. | `int4` | Yes | No | - | - |
| `retry_timeout` | Operational counter/limit used for processing control and performance monitoring. | `int8` | Yes | No | - | - |
| `handling_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `export_as_gzip` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `entity_reference_id` | Identifier for the related entity reference entity used by this record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [exchanged_file_exp](exchanged_file_exp.md) (12 query files), [exchanged_file_op](exchanged_file_op.md) (9 query files), [exchanged_file_sc](exchanged_file_sc.md) (5 query files), [extract](extract.md) (5 query files), [aggregated_transactions](aggregated_transactions.md) (5 query files), [gl_export_batches](gl_export_batches.md) (5 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [exchanged_file_sc](exchanged_file_sc.md); incoming FK from [cashcollection_requests](cashcollection_requests.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md), [gl_export_batches](gl_export_batches.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
