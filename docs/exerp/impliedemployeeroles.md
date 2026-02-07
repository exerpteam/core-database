# impliedemployeeroles
People-related master or relationship table for impliedemployeeroles data. It is typically used where it appears in approximately 16 query files; common companions include [roles](roles.md), [employees](employees.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `roleid` | Foreign key field linking this record to `roles`. | `int4` | No | Yes | [roles](roles.md) via (`roleid` -> `id`) | - |
| `implied` | Foreign key field linking this record to `roles`. | `int4` | No | Yes | [roles](roles.md) via (`implied` -> `id`) | - |
| `scope_override` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [roles](roles.md) (16 query files), [employees](employees.md) (12 query files), [employeesroles](employeesroles.md) (12 query files), [persons](persons.md) (12 query files), [centers](centers.md) (11 query files), [areas](areas.md) (8 query files).
- FK-linked tables: outgoing FK to [roles](roles.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md), [products](products.md), [questionnaire_campaigns](questionnaire_campaigns.md).
