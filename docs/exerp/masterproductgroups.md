# masterproductgroups
Operational table for masterproductgroups records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `managerrole` | Identifier of the related roles record used by this row. | `int4` | Yes | No | [roles](roles.md) via (`managerrole` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `showinsale` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `converted_id` | Identifier for the related converted entity used by this record. | `int4` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [roles](roles.md); incoming FK from [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [frequent_products_item](frequent_products_item.md), [impliedemployeeroles](impliedemployeeroles.md), [installment_plan_configs](installment_plan_configs.md), [journalentry_and_role_link](journalentry_and_role_link.md).
