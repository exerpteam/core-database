# roles
Operational table for roles records in the Exerp schema. It is typically used where it appears in approximately 168 query files; common companions include [persons](persons.md), [employees](employees.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `rolename` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `masterroleid` | Foreign key field linking this record to `roles`. | `int4` | Yes | No | [roles](roles.md) via (`masterroleid` -> `id`) | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `config_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `system_id` | Identifier of the related system record. | `int4` | Yes | No | - | - |
| `is_action` | Boolean flag indicating whether action applies. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (113 query files), [employees](employees.md) (100 query files), [employeesroles](employeesroles.md) (100 query files), [centers](centers.md) (88 query files), [person_ext_attrs](person_ext_attrs.md) (64 query files), [products](products.md) (55 query files).
- FK-linked tables: outgoing FK to [roles](roles.md); incoming FK from [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md), [products](products.md), [questionnaire_campaigns](questionnaire_campaigns.md), [roles](roles.md), [selectable_role_groups](selectable_role_groups.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md), [delivery_lines_mt](delivery_lines_mt.md), [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [employees](employees.md), [extract_group](extract_group.md), [extract_group_link](extract_group_link.md).
