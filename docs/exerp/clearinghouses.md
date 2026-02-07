# clearinghouses
Operational table for clearinghouses records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 306 query files; common companions include [account_receivables](account_receivables.md), [payment_agreements](payment_agreements.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `ctype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `datasupplier_id` | Identifier of the related datasupplier record. | `text(2147483647)` | Yes | No | - | - |
| `serial` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `external_clearinghouse_id` | Identifier of the related external clearinghouse record. | `text(2147483647)` | Yes | No | - | - |
| `gen_payment_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `use_ch_notification` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `available_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `external_authorization` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `agr_signature_required` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `coll_default_fee` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `rejection_fee` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `coll_invalid_fee` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `cc_end_agr_on_expiry_date` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `cancel_pa_on_rejected_rep_sc` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `properties_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `cycle_bookdate_on_collect_fee` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `enable_card_on_file` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `enable_dynamic_trans_fee` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `dynamic_trans_fee` | Text field containing descriptive or reference information. | `VARCHAR(100)` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (290 query files), [payment_agreements](payment_agreements.md) (277 query files), [persons](persons.md) (275 query files), [payment_accounts](payment_accounts.md) (213 query files), [centers](centers.md) (177 query files), [payment_requests](payment_requests.md) (122 query files).
- FK-linked tables: incoming FK from [ch_and_pcc_link](ch_and_pcc_link.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [exchanged_file](exchanged_file.md), [payment_agreements](payment_agreements.md), [payment_cycle_config](payment_cycle_config.md), [payment_requests](payment_requests.md), [unplaced_payments](unplaced_payments.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
