# questionnaire_campaigns
Operational table for questionnaire campaigns records in the Exerp schema. It is typically used where it appears in approximately 120 query files; common companions include [questionnaire_answer](questionnaire_answer.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `questionnaire` | Foreign key field linking this record to `questionnaires`. | `int4` | Yes | No | [questionnaires](questionnaires.md) via (`questionnaire` -> `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `required` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `startdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | No | No | - | - |
| `stopdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | No | No | - | - |
| `type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `viewresultrole` | Foreign key field linking this record to `roles`. | `int4` | Yes | No | [roles](roles.md) via (`viewresultrole` -> `id`) | - |
| `source_id` | Identifier of the related source record. | `int4` | Yes | No | - | - |
| `document_template_id` | Identifier of the related document template record. | `int4` | Yes | No | - | - |
| `validity_period_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `validity_period_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [questionnaire_answer](questionnaire_answer.md) (115 query files), [persons](persons.md) (107 query files), [questionnaires](questionnaires.md) (95 query files), [question_answer](question_answer.md) (88 query files), [centers](centers.md) (77 query files), [person_ext_attrs](person_ext_attrs.md) (48 query files).
- FK-linked tables: outgoing FK to [questionnaires](questionnaires.md), [roles](roles.md); incoming FK from [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [questionnaire_answer](questionnaire_answer.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [documentation_settings](documentation_settings.md), [employees](employees.md), [employeesroles](employeesroles.md), [EXTRACT](EXTRACT.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md).
