# extract_group_link
Bridge table that links related entities for extract group link relationships. It is typically used where it appears in approximately 5 query files; common companions include [EXTRACT](EXTRACT.md), [extract_group](extract_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `extract_id` | Foreign key field linking this record to `extract`. | `int4` | No | Yes | [EXTRACT](EXTRACT.md) via (`extract_id` -> `id`) | - |
| `group_id` | Foreign key field linking this record to `extract_group`. | `int4` | No | Yes | [extract_group](extract_group.md) via (`group_id` -> `id`) | - |

# Relations
- Commonly used with: [EXTRACT](EXTRACT.md) (5 query files), [extract_group](extract_group.md) (5 query files), [extract_usage](extract_usage.md) (4 query files).
- FK-linked tables: outgoing FK to [EXTRACT](EXTRACT.md), [extract_group](extract_group.md).
- Second-level FK neighborhood includes: [extract_group_and_role_link](extract_group_and_role_link.md), [extract_parameter](extract_parameter.md), [extract_usage](extract_usage.md), [roles](roles.md).
