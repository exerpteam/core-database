# questionnaire_answer
Operational table for questionnaire answer records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 131 query files; common companions include [persons](persons.md), [questionnaire_campaigns](questionnaire_campaigns.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `questionnaire_campaign_id` | Foreign key field linking this record to `questionnaire_campaigns`. | `int4` | Yes | No | [questionnaire_campaigns](questionnaire_campaigns.md) via (`questionnaire_campaign_id` -> `id`) | - |
| `log_time` | Epoch timestamp for log. | `int8` | No | No | - | - |
| `completed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `result_code` | Text field containing descriptive or reference information. | `VARCHAR(2000)` | Yes | No | - | - |
| `status` | Lifecycle status code for the record. | `VARCHAR(50)` | No | No | - | - |
| `journal_entry_id` | Identifier of the related journal entry record. | `int4` | Yes | No | - | - |
| `expiration_date` | Date for expiration. | `DATE` | Yes | No | - | - |
| `replaced_by_center` | Foreign key field linking this record to `questionnaire_answer`. | `int4` | Yes | No | [questionnaire_answer](questionnaire_answer.md) via (`replaced_by_center`, `replaced_by_id`, `replaced_by_subid` -> `center`, `id`, `subid`) | - |
| `replaced_by_id` | Foreign key field linking this record to `questionnaire_answer`. | `int4` | Yes | No | [questionnaire_answer](questionnaire_answer.md) via (`replaced_by_center`, `replaced_by_id`, `replaced_by_subid` -> `center`, `id`, `subid`) | - |
| `replaced_by_subid` | Foreign key field linking this record to `questionnaire_answer`. | `int4` | Yes | No | [questionnaire_answer](questionnaire_answer.md) via (`replaced_by_center`, `replaced_by_id`, `replaced_by_subid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [persons](persons.md) (123 query files), [questionnaire_campaigns](questionnaire_campaigns.md) (115 query files), [questionnaires](questionnaires.md) (94 query files), [question_answer](question_answer.md) (93 query files), [centers](centers.md) (92 query files), [subscriptions](subscriptions.md) (59 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [questionnaire_answer](questionnaire_answer.md), [questionnaire_campaigns](questionnaire_campaigns.md); incoming FK from [question_answer](question_answer.md), [questionnaire_answer](questionnaire_answer.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
