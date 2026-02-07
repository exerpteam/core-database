# kpi_group_and_role_link
Bridge table that links related entities for kpi group and role link relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `kpi_group_id` | Foreign key field linking this record to `kpi_group`. | `int4` | No | Yes | [kpi_group](kpi_group.md) via (`kpi_group_id` -> `id`) | - |
| `role_id` | Foreign key field linking this record to `roles`. | `int4` | No | Yes | [roles](roles.md) via (`role_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [kpi_group](kpi_group.md), [roles](roles.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_field_group](kpi_field_group.md), [masterproductgroups](masterproductgroups.md), [products](products.md).
