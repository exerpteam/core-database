# journalentry_signatures
Operational table for journalentry signatures records in the Exerp schema. It is typically used where it appears in approximately 33 query files; common companions include [journalentries](journalentries.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `journalentry_id` | Identifier of the related journalentries record used by this row. | `int4` | No | No | [journalentries](journalentries.md) via (`journalentry_id` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `reason` | Operational field `reason` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `signature_center` | Center component of the composite reference to the related signature record. | `int4` | Yes | No | [signatures](signatures.md) via (`signature_center`, `signature_id` -> `center`, `id`) | - |
| `signature_id` | Identifier component of the composite reference to the related signature record. | `int4` | Yes | No | [signatures](signatures.md) via (`signature_center`, `signature_id` -> `center`, `id`) | - |
| `position_left` | Business attribute `position_left` used by journalentry signatures workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `position_top` | Business attribute `position_top` used by journalentry signatures workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `width` | Business attribute `width` used by journalentry signatures workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `height` | Business attribute `height` used by journalentry signatures workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `page` | Business attribute `page` used by journalentry signatures workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [journalentries](journalentries.md) (33 query files), [persons](persons.md) (28 query files), [centers](centers.md) (20 query files), [subscriptions](subscriptions.md) (20 query files), [products](products.md) (18 query files), [clipcards](clipcards.md) (15 query files).
- FK-linked tables: outgoing FK to [journalentries](journalentries.md), [signatures](signatures.md).
- Second-level FK neighborhood includes: [cashcollectionjournalentries](cashcollectionjournalentries.md), [doc_requirement_items](doc_requirement_items.md), [journalentry_and_role_link](journalentry_and_role_link.md), [persons](persons.md).
