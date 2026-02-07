# questionnaires
Operational table for questionnaires records in the Exerp schema. It is typically used where it appears in approximately 132 query files; common companions include [persons](persons.md), [questionnaire_campaigns](questionnaire_campaigns.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `headline` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `questions` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `employeecenter` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `creation_time` | Epoch timestamp when the row was created. | `DATE` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `ENCRYPTED` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `externalid` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (112 query files), [questionnaire_campaigns](questionnaire_campaigns.md) (95 query files), [questionnaire_answer](questionnaire_answer.md) (94 query files), [centers](centers.md) (92 query files), [question_answer](question_answer.md) (82 query files), [EXTRACT](EXTRACT.md) (46 query files).
- FK-linked tables: outgoing FK to [employees](employees.md); incoming FK from [questionnaire_campaigns](questionnaire_campaigns.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
