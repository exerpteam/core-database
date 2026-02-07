# EXTRACT
Operational table for extract records in the Exerp schema. It is typically used where it appears in approximately 616 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `target_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `roleid` | Foreign key field linking this record to `roles`. | `int4` | Yes | No | [roles](roles.md) via (`roleid` -> `id`) | - | `42` |
| `sql_query_blob` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `report_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `report` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `api_enabled` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `timeout` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequent_export` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [persons](persons.md) (485 query files), [centers](centers.md) (477 query files), [subscriptions](subscriptions.md) (252 query files), [products](products.md) (246 query files), [person_ext_attrs](person_ext_attrs.md) (199 query files), [account_receivables](account_receivables.md) (181 query files).
- FK-linked tables: outgoing FK to [roles](roles.md); incoming FK from [extract_group_link](extract_group_link.md), [extract_parameter](extract_parameter.md), [extract_usage](extract_usage.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employees](employees.md), [employeesroles](employeesroles.md), [extract_group](extract_group.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md).
