# questionnaires
Operational table for questionnaires records in the Exerp schema. It is typically used where it appears in approximately 132 query files; common companions include [persons](persons.md), [questionnaire_campaigns](questionnaire_campaigns.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `headline` | Business attribute `headline` used by questionnaires workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | No | No | - | - |
| `questions` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `employeecenter` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `creation_time` | Timestamp used for event ordering and operational tracking. | `DATE` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `ENCRYPTED` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `externalid` | Operational field `externalid` used in query filtering and reporting transformations. | `VARCHAR(50)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (112 query files), [questionnaire_campaigns](questionnaire_campaigns.md) (95 query files), [questionnaire_answer](questionnaire_answer.md) (94 query files), [centers](centers.md) (92 query files), [question_answer](question_answer.md) (82 query files), [extract](extract.md) (46 query files).
- FK-linked tables: outgoing FK to [employees](employees.md); incoming FK from [questionnaire_campaigns](questionnaire_campaigns.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
