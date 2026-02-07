# accounts
Financial/transactional table for accounts records. It is typically used where rows are center-scoped; it appears in approximately 434 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `periodcenter` | Center component of the composite reference to the related period record. | `int4` | Yes | No | - | - |
| `periodid` | Identifier component of the composite reference to the related period record. | `int4` | Yes | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `atype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `account_vat_type_group_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | [account_vat_type_group](account_vat_type_group.md) via (`account_vat_type_group_id` -> `id`) |
| `report_key` | Business attribute `report_key` used by accounts workflows and reporting. | `int4` | Yes | No | - | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `SYSTEM` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `trans_rebook_rule_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `trans_rebook_configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (294 query files), [persons](persons.md) (290 query files), [account_trans](account_trans.md) (274 query files), [products](products.md) (226 query files), [ar_trans](ar_trans.md) (215 query files), [account_receivables](account_receivables.md) (197 query files).
- FK-linked tables: incoming FK from [account_receivables](account_receivables.md), [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [cashregisters](cashregisters.md), [clearinghouse_creditors](clearinghouse_creditors.md), [products](products.md), [vat_types](vat_types.md).
- Second-level FK neighborhood includes: [account_vat_type_link](account_vat_type_link.md), [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cash_register_log](cash_register_log.md), [cashcollectioncases](cashcollectioncases.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
