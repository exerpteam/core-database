# accounts
Financial/transactional table for accounts records. It is typically used where rows are center-scoped; it appears in approximately 434 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `periodcenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `periodid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `atype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `account_vat_type_group_id` | Identifier of the related account vat type group record. | `int4` | Yes | No | - | [account_vat_type_group](account_vat_type_group.md) via (`account_vat_type_group_id` -> `id`) |
| `report_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `SYSTEM` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `trans_rebook_rule_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `trans_rebook_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (294 query files), [persons](persons.md) (290 query files), [account_trans](account_trans.md) (274 query files), [products](products.md) (226 query files), [ar_trans](ar_trans.md) (215 query files), [account_receivables](account_receivables.md) (197 query files).
- FK-linked tables: incoming FK from [account_receivables](account_receivables.md), [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [cashregisters](cashregisters.md), [clearinghouse_creditors](clearinghouse_creditors.md), [products](products.md), [vat_types](vat_types.md).
- Second-level FK neighborhood includes: [account_vat_type_link](account_vat_type_link.md), [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cash_register_log](cash_register_log.md), [cashcollectioncases](cashcollectioncases.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
