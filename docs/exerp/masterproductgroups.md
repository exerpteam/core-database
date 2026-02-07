# masterproductgroups
Operational table for masterproductgroups records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `managerrole` | Foreign key field linking this record to `roles`. | `int4` | Yes | No | [roles](roles.md) via (`managerrole` -> `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `showinsale` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `converted_id` | Identifier of the related converted record. | `int4` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [roles](roles.md); incoming FK from [masterproductregister](masterproductregister.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [frequent_products_item](frequent_products_item.md), [impliedemployeeroles](impliedemployeeroles.md), [installment_plan_configs](installment_plan_configs.md), [journalentry_and_role_link](journalentry_and_role_link.md).
