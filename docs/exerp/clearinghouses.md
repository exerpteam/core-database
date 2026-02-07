# clearinghouses
Operational table for clearinghouses records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 306 query files; common companions include [account_receivables](account_receivables.md), [payment_agreements](payment_agreements.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `ctype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `datasupplier_id` | Identifier of the related datasupplier record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `serial` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `external_clearinghouse_id` | Identifier of the related external clearinghouse record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `gen_payment_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `use_ch_notification` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `available_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `external_authorization` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `agr_signature_required` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `coll_default_fee` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `rejection_fee` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `coll_invalid_fee` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `cc_end_agr_on_expiry_date` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `cancel_pa_on_rejected_rep_sc` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `properties_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `cycle_bookdate_on_collect_fee` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `enable_card_on_file` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `enable_dynamic_trans_fee` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `dynamic_trans_fee` | Text field containing descriptive or reference information. | `VARCHAR(100)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (290 query files), [payment_agreements](payment_agreements.md) (277 query files), [persons](persons.md) (275 query files), [payment_accounts](payment_accounts.md) (213 query files), [centers](centers.md) (177 query files), [payment_requests](payment_requests.md) (122 query files).
- FK-linked tables: incoming FK from [ch_and_pcc_link](ch_and_pcc_link.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [exchanged_file](exchanged_file.md), [payment_agreements](payment_agreements.md), [payment_cycle_config](payment_cycle_config.md), [payment_requests](payment_requests.md), [unplaced_payments](unplaced_payments.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
