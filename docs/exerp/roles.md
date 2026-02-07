# roles
Operational table for roles records in the Exerp schema. It is typically used where it appears in approximately 168 query files; common companions include [persons](persons.md), [employees](employees.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `rolename` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `masterroleid` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [roles](roles.md) via (`masterroleid` -> `id`) | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | Yes | No | - | - |
| `config_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `system_id` | Identifier for the related system entity used by this record. | `int4` | Yes | No | - | - |
| `is_action` | Boolean flag indicating whether `action` applies to this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (113 query files), [employees](employees.md) (100 query files), [employeesroles](employeesroles.md) (100 query files), [centers](centers.md) (88 query files), [person_ext_attrs](person_ext_attrs.md) (64 query files), [products](products.md) (55 query files).
- FK-linked tables: outgoing FK to [roles](roles.md); incoming FK from [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md), [products](products.md), [questionnaire_campaigns](questionnaire_campaigns.md), [roles](roles.md), [selectable_role_groups](selectable_role_groups.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md), [delivery_lines_mt](delivery_lines_mt.md), [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [employees](employees.md), [extract_group](extract_group.md), [extract_group_link](extract_group_link.md).
