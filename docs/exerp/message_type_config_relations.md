# message_type_config_relations
Configuration table for message type config relations behavior and defaults. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `event_type_config_id` | Foreign key field linking this record to `event_type_config`. | `int4` | No | Yes | [event_type_config](event_type_config.md) via (`event_type_config_id` -> `id`) | - | `1001` |
| `ranking` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - | `42` |
| `delivery_method_id` | Identifier of the related delivery method record. | `int4` | No | Yes | - | - | `1001` |
| `template_id` | Foreign key field linking this record to `templates`. | `int4` | No | Yes | [templates](templates.md) via (`template_id` -> `id`) | - | `1001` |
| `delivery_schedule` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `charge_product` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `availability_period_id` | Identifier of the related availability period record. | `int4` | Yes | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) | `1001` |
| `receiver_address_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `sender_address_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `delay` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `messagecategory` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- FK-linked tables: outgoing FK to [event_type_config](event_type_config.md), [templates](templates.md).
- Second-level FK neighborhood includes: [documentation_settings](documentation_settings.md), [messages](messages.md), [push_message_targets](push_message_targets.md).
