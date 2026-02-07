# document_set_to_question_cmpgn
Operational table for document set to question cmpgn records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `documentation_setting_id` | Foreign key field linking this record to `documentation_settings`. | `int4` | No | Yes | [documentation_settings](documentation_settings.md) via (`documentation_setting_id` -> `id`) | - |
| `questionnaire_campaign_id` | Foreign key field linking this record to `questionnaire_campaigns`. | `int4` | No | Yes | [questionnaire_campaigns](questionnaire_campaigns.md) via (`questionnaire_campaign_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [documentation_settings](documentation_settings.md), [questionnaire_campaigns](questionnaire_campaigns.md).
- Second-level FK neighborhood includes: [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md), [documentation_requirements](documentation_requirements.md), [questionnaire_answer](questionnaire_answer.md), [questionnaires](questionnaires.md), [roles](roles.md), [templates](templates.md).
