# receiver_group_caches
Intermediate/cache table used to accelerate receiver group caches processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `receiver_group_id` | Foreign key field linking this record to `privilege_receiver_groups`. | `int4` | No | No | [privilege_receiver_groups](privilege_receiver_groups.md) via (`receiver_group_id` -> `id`) | - | `1001` |
| `privilege_id` | Identifier of the related privilege record. | `int4` | No | No | - | - | `1001` |
| `privilege_type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | No | No | - | - | `Sample value` |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |

# Relations
- FK-linked tables: outgoing FK to [privilege_receiver_groups](privilege_receiver_groups.md).
