# message_type_config_relations
Configuration table for message type config relations behavior and defaults. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `event_type_config_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [event_type_config](event_type_config.md) via (`event_type_config_id` -> `id`) | - |
| `ranking` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `delivery_method_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `template_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [templates](templates.md) via (`template_id` -> `id`) | - |
| `delivery_schedule` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `charge_product` | Business attribute `charge_product` used by message type config relations workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `availability_period_id` | Identifier for the related availability period entity used by this record. | `int4` | Yes | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) |
| `receiver_address_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `sender_address_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `delay` | Business attribute `delay` used by message type config relations workflows and reporting. | `int4` | No | No | - | - |
| `messagecategory` | Business attribute `messagecategory` used by message type config relations workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [event_type_config](event_type_config.md), [templates](templates.md).
- Second-level FK neighborhood includes: [documentation_settings](documentation_settings.md), [messages](messages.md), [push_message_targets](push_message_targets.md).
