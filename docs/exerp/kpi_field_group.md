# kpi_field_group
Operational table for kpi field group records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `field_id` | Foreign key field linking this record to `kpi_fields`. | `int4` | No | Yes | [kpi_fields](kpi_fields.md) via (`field_id` -> `id`) | - | `1001` |
| `group_id` | Foreign key field linking this record to `kpi_group`. | `int4` | No | Yes | [kpi_group](kpi_group.md) via (`group_id` -> `id`) | - | `1001` |

# Relations
- FK-linked tables: outgoing FK to [kpi_fields](kpi_fields.md), [kpi_group](kpi_group.md).
- Second-level FK neighborhood includes: [kpi_data](kpi_data.md), [kpi_group_and_role_link](kpi_group_and_role_link.md).
