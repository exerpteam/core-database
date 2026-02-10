# clearing_in
Operational table for clearing in records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 56 query files; common companions include [account_receivables](account_receivables.md), [payment_requests](payment_requests.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `clearinghouse` | Identifier of the related clearinghouses record used by this row. | `int4` | Yes | No | [clearinghouses](clearinghouses.md) via (`clearinghouse` -> `id`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | [clearing_in_state](../master%20tables/clearing_in_state.md) |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `payment_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `total_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `received_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `generated_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `delivery` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `errors` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `substate` | State indicator used to control lifecycle transitions and filtering. | `int4` | Yes | No | - | - |
| `filename` | Business attribute `filename` used by clearing in workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `checksum` | Business attribute `checksum` used by clearing in workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `exchanged_file_id` | Identifier of the related exchanged file record used by this row. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (49 query files), [payment_requests](payment_requests.md) (42 query files), [persons](persons.md) (37 query files), [payment_agreements](payment_agreements.md) (33 query files), [payment_request_specifications](payment_request_specifications.md) (27 query files), [centers](centers.md) (26 query files).
- FK-linked tables: outgoing FK to [clearinghouses](clearinghouses.md), [exchanged_file](exchanged_file.md); incoming FK from [payment_requests](payment_requests.md), [unplaced_payments](unplaced_payments.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [cashcollection_requests](cashcollection_requests.md), [ch_and_pcc_link](ch_and_pcc_link.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
