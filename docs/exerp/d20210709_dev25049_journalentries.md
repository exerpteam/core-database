# d20210709_dev25049_journalentries
Operational table for d20210709 dev25049 journalentries records in the Exerp schema. It is typically used where change-tracking timestamps are available.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Identifier of the record, typically unique within `center`. | `int4` | Yes | No | - | - | `1001` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `new_last_modified` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |

# Relations
- Interesting data points: change timestamps support incremental extraction and reconciliation.
