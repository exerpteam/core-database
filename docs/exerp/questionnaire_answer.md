# questionnaire_answer
Operational table for questionnaire answer records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 131 query files; common companions include [persons](persons.md), [questionnaire_campaigns](questionnaire_campaigns.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `questionnaire_campaign_id` | Identifier of the related questionnaire campaigns record used by this row. | `int4` | Yes | No | [questionnaire_campaigns](questionnaire_campaigns.md) via (`questionnaire_campaign_id` -> `id`) | - |
| `log_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `completed` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `result_code` | Business attribute `result_code` used by questionnaire answer workflows and reporting. | `VARCHAR(2000)` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `VARCHAR(50)` | No | No | - | - |
| `journal_entry_id` | Identifier for the related journal entry entity used by this record. | `int4` | Yes | No | - | - |
| `expiration_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `replaced_by_center` | Center component of the composite reference to the related replaced by record. | `int4` | Yes | No | [questionnaire_answer](questionnaire_answer.md) via (`replaced_by_center`, `replaced_by_id`, `replaced_by_subid` -> `center`, `id`, `subid`) | - |
| `replaced_by_id` | Identifier component of the composite reference to the related replaced by record. | `int4` | Yes | No | [questionnaire_answer](questionnaire_answer.md) via (`replaced_by_center`, `replaced_by_id`, `replaced_by_subid` -> `center`, `id`, `subid`) | - |
| `replaced_by_subid` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [questionnaire_answer](questionnaire_answer.md) via (`replaced_by_center`, `replaced_by_id`, `replaced_by_subid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [persons](persons.md) (123 query files), [questionnaire_campaigns](questionnaire_campaigns.md) (115 query files), [questionnaires](questionnaires.md) (94 query files), [question_answer](question_answer.md) (93 query files), [centers](centers.md) (92 query files), [subscriptions](subscriptions.md) (59 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [questionnaire_answer](questionnaire_answer.md), [questionnaire_campaigns](questionnaire_campaigns.md); incoming FK from [question_answer](question_answer.md), [questionnaire_answer](questionnaire_answer.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
