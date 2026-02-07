# receiver_group_caches
Intermediate/cache table used to accelerate receiver group caches processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `receiver_group_id` | Identifier of the related privilege receiver groups record used by this row. | `int4` | No | No | [privilege_receiver_groups](privilege_receiver_groups.md) via (`receiver_group_id` -> `id`) | - |
| `privilege_id` | Identifier for the related privilege entity used by this record. | `int4` | No | No | - | - |
| `privilege_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(20)` | No | No | - | - |
| `valid_from` | Operational field `valid_from` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `valid_to` | Operational field `valid_to` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [privilege_receiver_groups](privilege_receiver_groups.md).
