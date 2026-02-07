SELECT
    p.FULLNAME,
    DECODE(p.SEX,'F','Female','M','Male') AS "Sex",
    email.TXTVALUE                        AS "Email",
    p.CENTER||'p'||p.ID                   AS "MemberID",
    p.EXTERNAL_ID as "External ID",
    qa.QUESTION_ID as "Question ID",
    qa.NUMBER_ANSWER as "Question Answer"
FROM
    QUESTION_ANSWER QA
JOIN
    QUESTIONNAIRE_ANSWER QUN
ON
    QA.ANSWER_CENTER = QUN.CENTER
    AND QA.ANSWER_ID = QUN.ID
    AND QA.ANSWER_SUBID = QUN.SUBID
JOIN
    PUREGYM.QUESTIONNAIRE_CAMPAIGNS QC
ON
    QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
JOIN
    PUREGYM.QUESTIONNAIRES Q
ON
    q.ID = QC.QUESTIONNAIRE
JOIN
    PUREGYM.PERSONS p
ON
    QUN.CENTER = P.CENTER
    AND QUN.ID = P.ID
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
WHERE
    Q.NAME in('Segmentation Questionnaire 1','Segmentation Questionnaire 2')
    AND p.sex !='C' and p.center = 172