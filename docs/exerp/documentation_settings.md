# documentation_settings
Configuration table for documentation settings behavior and defaults. It is typically used where lifecycle state codes are present; it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `definition_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(10)` | Yes | No | - | - |
| `availability` | Text field containing descriptive or reference information. | `VARCHAR(2000)` | Yes | No | - | - |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `override_name` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(200)` | Yes | No | - | - |
| `override_external_id` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |
| `override_cust_journ_doc_types` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `contract_template_id` | Foreign key field linking this record to `templates`. | `int4` | Yes | No | [templates](templates.md) via (`contract_template_id` -> `id`) | - |
| `override_contract_template` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `override_questionnaire_campgns` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [templates](templates.md); incoming FK from [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md), [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [documentation_requirements](documentation_requirements.md).
- Second-level FK neighborhood includes: [custom_journal_document_types](custom_journal_document_types.md), [doc_requirement_items](doc_requirement_items.md), [message_type_config_relations](message_type_config_relations.md), [messages](messages.md), [persons](persons.md), [questionnaire_campaigns](questionnaire_campaigns.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
