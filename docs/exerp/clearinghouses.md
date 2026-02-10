# clearinghouses
Operational table for clearinghouses records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 306 query files; common companions include [account_receivables](account_receivables.md), [payment_agreements](payment_agreements.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `ctype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | [clearinghouses_ctype](../master%20tables/clearinghouses_ctype.md) |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `datasupplier_id` | Identifier for the related datasupplier entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `serial` | Business attribute `serial` used by clearinghouses workflows and reporting. | `int4` | No | No | - | - |
| `external_clearinghouse_id` | Identifier for the related external clearinghouse entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `gen_payment_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `use_ch_notification` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `available_on_web` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `external_authorization` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `agr_signature_required` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `coll_default_fee` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `rejection_fee` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `coll_invalid_fee` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `cc_end_agr_on_expiry_date` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `cancel_pa_on_rejected_rep_sc` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `properties_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `cycle_bookdate_on_collect_fee` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `enable_card_on_file` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `enable_dynamic_trans_fee` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `dynamic_trans_fee` | Monetary value used in financial calculation, settlement, or reporting. | `VARCHAR(100)` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (290 query files), [payment_agreements](payment_agreements.md) (277 query files), [persons](persons.md) (275 query files), [payment_accounts](payment_accounts.md) (213 query files), [centers](centers.md) (177 query files), [payment_requests](payment_requests.md) (122 query files).
- FK-linked tables: incoming FK from [ch_and_pcc_link](ch_and_pcc_link.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [exchanged_file](exchanged_file.md), [payment_agreements](payment_agreements.md), [payment_cycle_config](payment_cycle_config.md), [payment_requests](payment_requests.md), [unplaced_payments](unplaced_payments.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
