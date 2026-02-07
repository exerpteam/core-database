# dc_st_to_cust_jrnl_dc_tp_links
Bridge table that links related entities for dc st to cust jrnl dc tp links relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `documentation_setting_key` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [documentation_settings](documentation_settings.md) via (`documentation_setting_key` -> `id`) | - |
| `custom_journal_doc_type_key` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [custom_journal_document_types](custom_journal_document_types.md) via (`custom_journal_doc_type_key` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [custom_journal_document_types](custom_journal_document_types.md), [documentation_settings](documentation_settings.md).
- Second-level FK neighborhood includes: [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [documentation_requirements](documentation_requirements.md), [roles](roles.md), [templates](templates.md).
