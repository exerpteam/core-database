# question_answer
Operational table for question answer records in the Exerp schema. It is typically used where it appears in approximately 93 query files; common companions include [questionnaire_answer](questionnaire_answer.md), [questionnaire_campaigns](questionnaire_campaigns.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `answer_center` | Foreign key field linking this record to `questionnaire_answer`. | `int4` | No | No | [questionnaire_answer](questionnaire_answer.md) via (`answer_center`, `answer_id`, `answer_subid` -> `center`, `id`, `subid`) | - | `101` |
| `answer_id` | Foreign key field linking this record to `questionnaire_answer`. | `int4` | No | No | [questionnaire_answer](questionnaire_answer.md) via (`answer_center`, `answer_id`, `answer_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `answer_subid` | Foreign key field linking this record to `questionnaire_answer`. | `int4` | No | No | [questionnaire_answer](questionnaire_answer.md) via (`answer_center`, `answer_id`, `answer_subid` -> `center`, `id`, `subid`) | - | `1` |
| `question_id` | Identifier of the related question record. | `int4` | No | No | - | - | `1001` |
| `text_answer` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `number_answer` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `encrypted_number_answer` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `encrypted_text_answer` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `encryption_time` | Epoch timestamp for encryption. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [questionnaire_answer](questionnaire_answer.md) (93 query files), [questionnaire_campaigns](questionnaire_campaigns.md) (88 query files), [persons](persons.md) (86 query files), [questionnaires](questionnaires.md) (82 query files), [centers](centers.md) (65 query files), [person_ext_attrs](person_ext_attrs.md) (46 query files).
- FK-linked tables: outgoing FK to [questionnaire_answer](questionnaire_answer.md).
- Second-level FK neighborhood includes: [persons](persons.md), [questionnaire_campaigns](questionnaire_campaigns.md).
