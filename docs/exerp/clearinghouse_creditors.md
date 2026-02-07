# clearinghouse_creditors
Operational table for clearinghouse creditors records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 32 query files; common companions include [account_receivables](account_receivables.md), [payment_agreements](payment_agreements.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `clearinghouse` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [clearinghouses](clearinghouses.md) via (`clearinghouse` -> `id`) | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `creditor_id` | Primary key component used to uniquely identify this record. | `VARCHAR(16)` | No | Yes | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `creditor_name` | Business attribute `creditor_name` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `giro_account_no` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `deposit_account_center` | Center component of the composite reference to the related deposit account record. | `int4` | Yes | No | [accounts](accounts.md) via (`deposit_account_center`, `deposit_account_id` -> `center`, `id`) | - |
| `deposit_account_id` | Identifier component of the composite reference to the related deposit account record. | `int4` | Yes | No | [accounts](accounts.md) via (`deposit_account_center`, `deposit_account_id` -> `center`, `id`) | - |
| `liability_account_center` | Center component of the composite reference to the related liability account record. | `int4` | Yes | No | [accounts](accounts.md) via (`liability_account_center`, `liability_account_id` -> `center`, `id`) | - |
| `liability_account_id` | Identifier component of the composite reference to the related liability account record. | `int4` | Yes | No | [accounts](accounts.md) via (`liability_account_center`, `liability_account_id` -> `center`, `id`) | - |
| `rejection_account_center` | Center component of the composite reference to the related rejection account record. | `int4` | Yes | No | [accounts](accounts.md) via (`rejection_account_center`, `rejection_account_id` -> `center`, `id`) | - |
| `rejection_account_id` | Identifier component of the composite reference to the related rejection account record. | `int4` | Yes | No | [accounts](accounts.md) via (`rejection_account_center`, `rejection_account_id` -> `center`, `id`) | - |
| `indemnity_account_center` | Center component of the composite reference to the related indemnity account record. | `int4` | Yes | No | [accounts](accounts.md) via (`indemnity_account_center`, `indemnity_account_id` -> `center`, `id`) | - |
| `indemnity_account_id` | Identifier component of the composite reference to the related indemnity account record. | `int4` | Yes | No | [accounts](accounts.md) via (`indemnity_account_center`, `indemnity_account_id` -> `center`, `id`) | - |
| `refund_account_center` | Center component of the composite reference to the related refund account record. | `int4` | Yes | No | - | - |
| `refund_account_id` | Identifier component of the composite reference to the related refund account record. | `int4` | Yes | No | - | - |
| `invoice_fee_account_center` | Center component of the composite reference to the related invoice fee account record. | `int4` | Yes | No | - | - |
| `invoice_fee_account_id` | Identifier component of the composite reference to the related invoice fee account record. | `int4` | Yes | No | - | - |
| `rejection_fee_account_center` | Center component of the composite reference to the related rejection fee account record. | `int4` | Yes | No | - | - |
| `rejection_fee_account_id` | Identifier component of the composite reference to the related rejection fee account record. | `int4` | Yes | No | - | - |
| `default_creditor_ch` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`default_creditor_ch`, `default_creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `default_creditor_id` | Identifier referencing another record in the same table hierarchy. | `text(2147483647)` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`default_creditor_ch`, `default_creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `disable_unplaced_payments` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `field_1` | Business attribute `field_1` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `field_2` | Business attribute `field_2` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `field_3` | Business attribute `field_3` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `field_4` | Business attribute `field_4` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `field_5` | Business attribute `field_5` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `field_6` | Business attribute `field_6` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `reference_modifier` | Business attribute `reference_modifier` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `web_text` | Business attribute `web_text` used by clearinghouse creditors workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `seller_center_id` | Identifier of the related centers record used by this row. | `int4` | Yes | No | [centers](centers.md) via (`seller_center_id` -> `id`) | - |
| `properties_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `field_7` | Business attribute `field_7` used by clearinghouse creditors workflows and reporting. | `VARCHAR(40)` | Yes | No | - | - |
| `field_8` | Business attribute `field_8` used by clearinghouse creditors workflows and reporting. | `VARCHAR(40)` | Yes | No | - | - |
| `field_9` | Business attribute `field_9` used by clearinghouse creditors workflows and reporting. | `VARCHAR(40)` | Yes | No | - | - |
| `field_10` | Business attribute `field_10` used by clearinghouse creditors workflows and reporting. | `VARCHAR(40)` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (28 query files), [payment_agreements](payment_agreements.md) (27 query files), [clearinghouses](clearinghouses.md) (26 query files), [persons](persons.md) (25 query files), [payment_accounts](payment_accounts.md) (21 query files), [centers](centers.md) (20 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md), [centers](centers.md), [clearinghouse_creditors](clearinghouse_creditors.md), [clearinghouses](clearinghouses.md); incoming FK from [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [clearinghouse_creditors](clearinghouse_creditors.md), [payment_agreements](payment_agreements.md), [payment_requests](payment_requests.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [accountingperiods](accountingperiods.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [bookings](bookings.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
