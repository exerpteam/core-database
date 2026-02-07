# journalentry_signatures
Operational table for journalentry signatures records in the Exerp schema. It is typically used where it appears in approximately 33 query files; common companions include [journalentries](journalentries.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `journalentry_id` | Foreign key field linking this record to `journalentries`. | `int4` | No | No | [journalentries](journalentries.md) via (`journalentry_id` -> `id`) | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `reason` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `signature_center` | Foreign key field linking this record to `signatures`. | `int4` | Yes | No | [signatures](signatures.md) via (`signature_center`, `signature_id` -> `center`, `id`) | - | `101` |
| `signature_id` | Foreign key field linking this record to `signatures`. | `int4` | Yes | No | [signatures](signatures.md) via (`signature_center`, `signature_id` -> `center`, `id`) | - | `1001` |
| `position_left` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `position_top` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `width` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `height` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `page` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [journalentries](journalentries.md) (33 query files), [persons](persons.md) (28 query files), [centers](centers.md) (20 query files), [subscriptions](subscriptions.md) (20 query files), [products](products.md) (18 query files), [clipcards](clipcards.md) (15 query files).
- FK-linked tables: outgoing FK to [journalentries](journalentries.md), [signatures](signatures.md).
- Second-level FK neighborhood includes: [cashcollectionjournalentries](cashcollectionjournalentries.md), [doc_requirement_items](doc_requirement_items.md), [journalentry_and_role_link](journalentry_and_role_link.md), [persons](persons.md).
