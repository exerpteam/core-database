# extract_group_and_role_link
Bridge table that links related entities for extract group and role link relationships. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `extract_group_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [extract_group](extract_group.md) via (`extract_group_id` -> `id`) | - |
| `role_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [roles](roles.md) via (`role_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [extract_group](extract_group.md), [roles](roles.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_link](extract_group_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md), [products](products.md).
