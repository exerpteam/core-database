# journalentry_multiple_ref
Operational table for journalentry multiple ref records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `journalentry_id` | Identifier of the related journalentry record. | `int4` | No | Yes | - | - | `1001` |
| `ref_center` | Center part of the reference to related ref data. | `int4` | No | Yes | - | - | `101` |
| `ref_id` | Identifier of the related ref record. | `int4` | No | Yes | - | - | `1001` |

# Relations
