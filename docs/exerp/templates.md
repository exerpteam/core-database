# templates
Intermediate/cache table used to accelerate templates processing. It is typically used where it appears in approximately 38 query files; common companions include [centers](centers.md), [masterproductregister](masterproductregister.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `ttype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `layout` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `METHOD` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `outputmimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |
| `use_default` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `SIGN` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [centers](centers.md) (28 query files), [masterproductregister](masterproductregister.md) (22 query files), [privilege_grants](privilege_grants.md) (20 query files), [privilege_sets](privilege_sets.md) (20 query files), [product_account_configurations](product_account_configurations.md) (20 query files), [product_group](product_group.md) (18 query files).
- FK-linked tables: incoming FK from [documentation_settings](documentation_settings.md), [message_type_config_relations](message_type_config_relations.md), [messages](messages.md).
- Second-level FK neighborhood includes: [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md), [document_set_to_question_cmpgn](document_set_to_question_cmpgn.md), [documentation_requirements](documentation_requirements.md), [event_type_config](event_type_config.md), [message_attachments](message_attachments.md), [messages_of_todos](messages_of_todos.md), [persons](persons.md), [sms](sms.md).
