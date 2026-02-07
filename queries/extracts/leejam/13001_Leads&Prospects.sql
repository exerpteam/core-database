WITH params AS MATERIALIZED
(
        SELECT
               TO_DATE(:fromdate,'YYYY-MM-DD') AS fromDate,
                c.id AS center_id
        FROM
                leejam.centers c
)
SELECT
    t1.center||'p'||t1.id AS "PersonID",
    t1.external_id        AS "ExternalID",
    t1.firstname          AS "FirstName",
    t1.lastname           AS "LastName",
    t1.sex                AS "Gender",
    t1.persontype         AS "PersonType",
    t1.status             AS "PersonStatus",
    t1.birthdate          AS "Birthday",
    t1.address1           AS "AddressLine1",
    t1.address2           AS "AddressLine2",
    t1.address3           AS "AddressLine3",
    t1.zipcode            AS "PostalCode",
    t1.country            AS "Country",
    t1.ssn                AS "Passport",
    t1.national_id        AS "NationalID",
    t1.resident_id        AS "ResidentID",
    t1.creationdate       AS "CreationDateTime",
     comptype.txtvalue AS "Company Type",
        corpem.txtvalue AS "Corporate email",
        crexp.txtvalue AS "CR expiry date",
        decrencam.txtvalue AS "DecemberRenewalCampaign",
        covid.txtvalue AS "Did you get COVID-19 vaccine",
        emaildom.txtvalue AS "EmailDomain",
        emgconnum.txtvalue AS "Emergency contact number",
        febcamp.txtvalue AS "FebruaryCampaign",
        founoff.txtvalue AS "FounderOffer",
        freepass.txtvalue AS "Free pass",
        freezepaid.txtvalue AS "Freeze is paid",
        fttwoready.txtvalue AS "FT2 ready",
        ftthreeready.txtvalue AS "FT3 ready",
        guest.txtvalue AS "Guest",
        hearus.txtvalue AS "How did you hear about us",
        jancamp.txtvalue AS "JanuaryCampaign",
        nation.txtvalue AS "Nationality",
        nycamp.txtvalue AS "NewYearCampaign",
        relatedparty.txtvalue AS "Related Party",
        sfd.txtvalue AS "SFD22FreeDaysCampaign",
        uaes.txtvalue AS "Uae Scale PT For New Staff",
        winback.txtvalue AS "WinBackCampaign",
        worldcup.txtvalue AS "WorldCupCampaign"
FROM
    (
        SELECT
            p.*,
            pcl.new_value AS "creationdate"
        FROM
            leejam.persons p
        JOIN
            leejam.person_change_logs pcl
        ON
            p.center = pcl.person_center
        AND p.id = pcl.person_id
        WHERE
            p.status IN (0,6)
            and pcl.change_attribute = 'CREATION_DATE'
        AND p.center IN (:scope)
       )t1
JOIN params on t1.center = params.center_id       
LEFT JOIN leejam.person_ext_attrs comptype ON comptype.personcenter = t1.center AND comptype.personid = t1.id AND comptype.name = 'Type'
LEFT JOIN leejam.person_ext_attrs corpem ON corpem.personcenter = t1.center AND corpem.personid = t1.id AND corpem.name = 'CorporateEmail'
LEFT JOIN leejam.person_ext_attrs crexp ON crexp.personcenter = t1.center AND crexp.personid = t1.id AND crexp.name = 'CREXPIRY'
LEFT JOIN leejam.person_ext_attrs decrencam ON decrencam.personcenter = t1.center AND decrencam.personid = t1.id AND decrencam.name = 'DecemberRenewalCampaign'
LEFT JOIN leejam.person_ext_attrs covid ON covid.personcenter = t1.center AND covid.personid = t1.id AND covid.name = 'VACCINE'
LEFT JOIN leejam.person_ext_attrs emaildom ON emaildom.personcenter = t1.center AND emaildom.personid = t1.id AND emaildom.name = 'EmailDomain'
LEFT JOIN leejam.person_ext_attrs emgconnum ON emgconnum.personcenter = t1.center AND emgconnum.personid = t1.id AND emgconnum.name = 'EMERGENCY'
LEFT JOIN leejam.person_ext_attrs febcamp ON febcamp.personcenter = t1.center AND febcamp.personid = t1.id AND febcamp.name = 'FebruaryCampaign'
LEFT JOIN leejam.person_ext_attrs founoff ON founoff.personcenter = t1.center AND founoff.personid = t1.id AND founoff.name = 'FounderOffer'
LEFT JOIN leejam.person_ext_attrs freepass ON freepass.personcenter = t1.center AND freepass.personid = t1.id AND freepass.name = 'FreePass'
LEFT JOIN leejam.person_ext_attrs freezepaid ON freezepaid.personcenter = t1.center AND freezepaid.personid = t1.id AND freezepaid.name = 'PAIDFREEZE'
LEFT JOIN leejam.person_ext_attrs fttwoready ON fttwoready.personcenter = t1.center AND fttwoready.personid = t1.id AND fttwoready.name = 'FT2READY'
LEFT JOIN leejam.person_ext_attrs ftthreeready ON ftthreeready.personcenter = t1.center AND ftthreeready.personid = t1.id AND ftthreeready.name = 'FT3READY'
LEFT JOIN leejam.person_ext_attrs guest ON guest.personcenter = t1.center AND guest.personid = t1.id AND guest.name = 'GUEST'
LEFT JOIN leejam.person_ext_attrs hearus ON hearus.personcenter = t1.center AND hearus.personid = t1.id AND hearus.name = 'SOURCE'
LEFT JOIN leejam.person_ext_attrs jancamp ON jancamp.personcenter = t1.center AND jancamp.personid = t1.id AND jancamp.name = 'JanuaryCampaign'
LEFT JOIN leejam.person_ext_attrs nation ON nation.personcenter = t1.center AND nation.personid = t1.id AND nation.name = 'NAT'
LEFT JOIN leejam.person_ext_attrs nycamp ON nycamp.personcenter = t1.center AND nycamp.personid = t1.id AND nycamp.name = 'NewYearCampaign'
LEFT JOIN leejam.person_ext_attrs relatedparty ON relatedparty.personcenter = t1.center AND relatedparty.personid = t1.id AND relatedparty.name = 'COMPREL'
LEFT JOIN leejam.person_ext_attrs sfd ON sfd.personcenter = t1.center AND sfd.personid = t1.id AND sfd.name = 'SFD22FreeDaysCampaign'
LEFT JOIN leejam.person_ext_attrs uaes ON uaes.personcenter = t1.center AND uaes.personid = t1.id AND uaes.name = 'SCALEPT'
LEFT JOIN leejam.person_ext_attrs winback ON winback.personcenter = t1.center AND winback.personid = t1.id AND winback.name = 'WinBackCampaign'
LEFT JOIN leejam.person_ext_attrs worldcup ON worldcup.personcenter = t1.center AND worldcup.personid = t1.id AND worldcup.name = 'WorldCupCampaign'
LEFT JOIN leejam.person_ext_attrs transf ON transf.personcenter = t1.center AND transf.personid = t1.id AND transf.name = '_eClub_TransferredFromId'
WHERE
    TO_DATE(t1.creationdate,'YYYY-MM-DD') = params.fromDate