# clearinghouse_creditors
Operational table for clearinghouse creditors records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 32 query files; common companions include [account_receivables](account_receivables.md), [payment_agreements](payment_agreements.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `clearinghouse` | Foreign key field linking this record to `clearinghouses`. | `int4` | No | Yes | [clearinghouses](clearinghouses.md) via (`clearinghouse` -> `id`) | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `creditor_id` | Identifier of the related creditor record. | `VARCHAR(16)` | No | Yes | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `creditor_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `giro_account_no` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `deposit_account_center` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`deposit_account_center`, `deposit_account_id` -> `center`, `id`) | - |
| `deposit_account_id` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`deposit_account_center`, `deposit_account_id` -> `center`, `id`) | - |
| `liability_account_center` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`liability_account_center`, `liability_account_id` -> `center`, `id`) | - |
| `liability_account_id` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`liability_account_center`, `liability_account_id` -> `center`, `id`) | - |
| `rejection_account_center` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`rejection_account_center`, `rejection_account_id` -> `center`, `id`) | - |
| `rejection_account_id` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`rejection_account_center`, `rejection_account_id` -> `center`, `id`) | - |
| `indemnity_account_center` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`indemnity_account_center`, `indemnity_account_id` -> `center`, `id`) | - |
| `indemnity_account_id` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`indemnity_account_center`, `indemnity_account_id` -> `center`, `id`) | - |
| `refund_account_center` | Center part of the reference to related refund account data. | `int4` | Yes | No | - | - |
| `refund_account_id` | Identifier of the related refund account record. | `int4` | Yes | No | - | - |
| `invoice_fee_account_center` | Center part of the reference to related invoice fee account data. | `int4` | Yes | No | - | - |
| `invoice_fee_account_id` | Identifier of the related invoice fee account record. | `int4` | Yes | No | - | - |
| `rejection_fee_account_center` | Center part of the reference to related rejection fee account data. | `int4` | Yes | No | - | - |
| `rejection_fee_account_id` | Identifier of the related rejection fee account record. | `int4` | Yes | No | - | - |
| `default_creditor_ch` | Foreign key field linking this record to `clearinghouse_creditors`. | `int4` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`default_creditor_ch`, `default_creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `default_creditor_id` | Foreign key field linking this record to `clearinghouse_creditors`. | `text(2147483647)` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`default_creditor_ch`, `default_creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `disable_unplaced_payments` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `field_1` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `field_2` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `field_3` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `field_4` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `field_5` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `field_6` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `reference_modifier` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `web_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `seller_center_id` | Foreign key field linking this record to `centers`. | `int4` | Yes | No | [centers](centers.md) via (`seller_center_id` -> `id`) | - |
| `properties_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `field_7` | Text field containing descriptive or reference information. | `VARCHAR(40)` | Yes | No | - | - |
| `field_8` | Text field containing descriptive or reference information. | `VARCHAR(40)` | Yes | No | - | - |
| `field_9` | Text field containing descriptive or reference information. | `VARCHAR(40)` | Yes | No | - | - |
| `field_10` | Text field containing descriptive or reference information. | `VARCHAR(40)` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (28 query files), [payment_agreements](payment_agreements.md) (27 query files), [clearinghouses](clearinghouses.md) (26 query files), [persons](persons.md) (25 query files), [payment_accounts](payment_accounts.md) (21 query files), [centers](centers.md) (20 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md), [centers](centers.md), [clearinghouse_creditors](clearinghouse_creditors.md), [clearinghouses](clearinghouses.md); incoming FK from [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [clearinghouse_creditors](clearinghouse_creditors.md), [payment_agreements](payment_agreements.md), [payment_requests](payment_requests.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [accountingperiods](accountingperiods.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [bookings](bookings.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
