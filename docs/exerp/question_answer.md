# question_answer
Operational table for question answer records in the Exerp schema. It is typically used where it appears in approximately 93 query files; common companions include [questionnaire_answer](questionnaire_answer.md), [questionnaire_campaigns](questionnaire_campaigns.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `answer_center` | Center component of the composite reference to the related answer record. | `int4` | No | No | [questionnaire_answer](questionnaire_answer.md) via (`answer_center`, `answer_id`, `answer_subid` -> `center`, `id`, `subid`) | - |
| `answer_id` | Identifier component of the composite reference to the related answer record. | `int4` | No | No | [questionnaire_answer](questionnaire_answer.md) via (`answer_center`, `answer_id`, `answer_subid` -> `center`, `id`, `subid`) | - |
| `answer_subid` | Identifier of the related questionnaire answer record used by this row. | `int4` | No | No | [questionnaire_answer](questionnaire_answer.md) via (`answer_center`, `answer_id`, `answer_subid` -> `center`, `id`, `subid`) | - |
| `question_id` | Identifier for the related question entity used by this record. | `int4` | No | No | - | - |
| `text_answer` | Business attribute `text_answer` used by question answer workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `number_answer` | Operational field `number_answer` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `encrypted_number_answer` | Business attribute `encrypted_number_answer` used by question answer workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `encrypted_text_answer` | Business attribute `encrypted_text_answer` used by question answer workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `encryption_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [questionnaire_answer](questionnaire_answer.md) (93 query files), [questionnaire_campaigns](questionnaire_campaigns.md) (88 query files), [persons](persons.md) (86 query files), [questionnaires](questionnaires.md) (82 query files), [centers](centers.md) (65 query files), [person_ext_attrs](person_ext_attrs.md) (46 query files).
- FK-linked tables: outgoing FK to [questionnaire_answer](questionnaire_answer.md).
- Second-level FK neighborhood includes: [persons](persons.md), [questionnaire_campaigns](questionnaire_campaigns.md).
