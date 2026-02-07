# questionnaire_campaigns
Operational table for questionnaire campaigns records in the Exerp schema. It is typically used where it appears in approximately 120 query files; common companions include [questionnaire_answer](questionnaire_answer.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `questionnaire` | Identifier of the related questionnaires record used by this row. | `int4` | Yes | No | [questionnaires](questionnaires.md) via (`questionnaire` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `required` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `startdate` | Operational field `startdate` used in query filtering and reporting transformations. | `DATE` | No | No | - | - |
| `stopdate` | Operational field `stopdate` used in query filtering and reporting transformations. | `DATE` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `viewresultrole` | Identifier of the related roles record used by this row. | `int4` | Yes | No | [roles](roles.md) via (`viewresultrole` -> `id`) | - |
| `source_id` | Identifier for the related source entity used by this record. | `int4` | Yes | No | - | - |
| `document_template_id` | Identifier for the related document template entity used by this record. | `int4` | Yes | No | - | - |
| `validity_period_value` | Business attribute `validity_period_value` used by questionnaire campaigns workflows and reporting. | `int4` | Yes | No | - | - |
| `validity_period_unit` | Business attribute `validity_period_unit` used by questionnaire campaigns workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [questionnaire_answer](questionnaire_answer.md) (115 query files), [persons](persons.md) (107 query files), [questionnaires](questionnaires.md) (95 query files), [question_answer](question_answer.md) (88 query files), [centers](centers.md) (77 query files), [person_ext_attrs](person_ext_attrs.md) (48 query files).
- FK-linked tables: outgoing FK to [questionnaires](questionnaires.md), [roles](roles.md); incoming FK from [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [questionnaire_answer](questionnaire_answer.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [documentation_settings](documentation_settings.md), [employees](employees.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md).
