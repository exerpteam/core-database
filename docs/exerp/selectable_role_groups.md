# selectable_role_groups
Operational table for selectable role groups records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `role_id` | Foreign key field linking this record to `roles`. | `int4` | No | Yes | [roles](roles.md) via (`role_id` -> `id`) | - |
| `group_purpose_id` | Identifier of the related group purpose record. | `int4` | No | Yes | - | - |

# Relations
- FK-linked tables: outgoing FK to [roles](roles.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md), [products](products.md).
