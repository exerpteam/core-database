# contracts
Operational table for contracts records in the Exerp schema. It is typically used where it appears in approximately 6 query files; common companions include [journalentries](journalentries.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [journalentries](journalentries.md) (6 query files), [centers](centers.md) (4 query files), [journalentry_signatures](journalentry_signatures.md) (4 query files), [persons](persons.md) (4 query files), [signatures](signatures.md) (4 query files), [subscriptions](subscriptions.md) (4 query files).
- FK-linked tables: incoming FK from [licenses](licenses.md).
- Second-level FK neighborhood includes: [centers](centers.md), [license_change_logs_content](license_change_logs_content.md).
