# payment_accounts
Financial/transactional table for payment accounts records. It is typically used where rows are center-scoped; it appears in approximately 614 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - |
| `active_agr_center` | Center component of the composite reference to the related active agr record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`active_agr_center`, `active_agr_id`, `active_agr_subid` -> `center`, `id`, `subid`) | - |
| `active_agr_id` | Identifier component of the composite reference to the related active agr record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`active_agr_center`, `active_agr_id`, `active_agr_subid` -> `center`, `id`, `subid`) | - |
| `active_agr_subid` | Identifier of the related payment agreements record used by this row. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`active_agr_center`, `active_agr_id`, `active_agr_subid` -> `center`, `id`, `subid`) | - |
| `day_in_interval` | Business attribute `day_in_interval` used by payment accounts workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (614 query files), [persons](persons.md) (584 query files), [payment_agreements](payment_agreements.md) (569 query files), [centers](centers.md) (376 query files), [subscriptions](subscriptions.md) (277 query files), [person_ext_attrs](person_ext_attrs.md) (243 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md), [payment_agreements](payment_agreements.md); incoming FK from [payment_agreements](payment_agreements.md), [payment_requests](payment_requests.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [advance_notices](advance_notices.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [cashcollectioncases](cashcollectioncases.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md), [employees](employees.md), [invoice_lines_mt](invoice_lines_mt.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
