SELECT
    p.external_id              AS person_external_id,
    s.id                       AS subscription_id,
    s.start_date,
    s.end_date,
    cc.campaign_id,
    cc.code
FROM persons p
JOIN subscriptions s
    ON  s.owner_center = p.current_person_center
    AND s.owner_id     = p.current_person_id
LEFT JOIN campaign_code_usages ccu
    ON ccu.external_id = p.external_id
LEFT JOIN campaign_codes cc
    ON cc.id = ccu.campaign_code_id
WHERE
    p.external_id IN (
        	'30819260',
            '1717719',
            '2419380',
            '30804780',
            '2674603',
            '30812596',
            '30846511',
            '2442703',
            '30832153',
            '30827200',
            '2803579'
        -- aggiungi qui altri external_id
    )
    AND (s.end_date > CURRENT_DATE OR s.end_date IS NULL);