# documentation_settings
Configuration table for documentation settings behavior and defaults. It is typically used where lifecycle state codes are present; it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `definition_key` | Operational field `definition_key` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(10)` | Yes | No | - | - |
| `availability` | Operational field `availability` used in query filtering and reporting transformations. | `VARCHAR(2000)` | Yes | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(50)` | Yes | No | - | - |
| `override_name` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `VARCHAR(200)` | Yes | No | - | - |
| `override_external_id` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `VARCHAR(20)` | Yes | No | - | - |
| `override_cust_journ_doc_types` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `contract_template_id` | Identifier of the related templates record used by this row. | `int4` | Yes | No | [templates](templates.md) via (`contract_template_id` -> `id`) | - |
| `override_contract_template` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `override_questionnaire_campgns` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [templates](templates.md); incoming FK from [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md), [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [documentation_requirements](documentation_requirements.md).
- Second-level FK neighborhood includes: [custom_journal_document_types](custom_journal_document_types.md), [doc_requirement_items](doc_requirement_items.md), [message_type_config_relations](message_type_config_relations.md), [messages](messages.md), [persons](persons.md), [questionnaire_campaigns](questionnaire_campaigns.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
