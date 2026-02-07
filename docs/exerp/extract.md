# extract
Operational table for extract records in the Exerp schema. It is typically used where it appears in approximately 616 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `target_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `roleid` | Identifier of the related roles record used by this row. | `int4` | Yes | No | [roles](roles.md) via (`roleid` -> `id`) | - |
| `sql_query_blob` | Serialized SQL definition executed by the extract/report runtime. | `bytea` | Yes | No | - | - |
| `report_name` | Business attribute `report_name` used by extract workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `report` | Serialized report artifact associated with this record. | `bytea` | Yes | No | - | - |
| `api_enabled` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `timeout` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `frequent_export` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (485 query files), [centers](centers.md) (477 query files), [subscriptions](subscriptions.md) (252 query files), [products](products.md) (246 query files), [person_ext_attrs](person_ext_attrs.md) (199 query files), [account_receivables](account_receivables.md) (181 query files).
- FK-linked tables: outgoing FK to [roles](roles.md); incoming FK from [extract_group_link](extract_group_link.md), [extract_parameter](extract_parameter.md), [extract_usage](extract_usage.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employees](employees.md), [employeesroles](employeesroles.md), [extract_group](extract_group.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md).
