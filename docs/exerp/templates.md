# templates
Intermediate/cache table used to accelerate templates processing. It is typically used where it appears in approximately 38 query files; common companions include [centers](centers.md), [masterproductregister](masterproductregister.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `ttype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `layout` | Business attribute `layout` used by templates workflows and reporting. | `int4` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `METHOD` | Operational field `METHOD` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `outputmimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `use_default` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `SIGN` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (28 query files), [masterproductregister](masterproductregister.md) (22 query files), [privilege_grants](privilege_grants.md) (20 query files), [privilege_sets](privilege_sets.md) (20 query files), [product_account_configurations](product_account_configurations.md) (20 query files), [product_group](product_group.md) (18 query files).
- FK-linked tables: incoming FK from [documentation_settings](documentation_settings.md), [message_type_config_relations](message_type_config_relations.md), [messages](messages.md).
- Second-level FK neighborhood includes: [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md), [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [documentation_requirements](documentation_requirements.md), [event_type_config](event_type_config.md), [message_attachments](message_attachments.md), [messages_of_todos](messages_of_todos.md), [persons](persons.md), [sms](sms.md).
