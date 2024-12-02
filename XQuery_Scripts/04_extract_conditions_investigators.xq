(: Extract conditions and investigators :)
for $study in collection('DB2_covid_studies')//clinical_study
return 
<result>
    <Condition>{ $study/condition/text() }</Condition>
    <Investigator>
        <Name>{ $study/overall_official/last_name/text() }</Name>
        <Role>{ $study/overall_official/role/text() }</Role>
        <Affiliation>{ $study/overall_official/affiliation/text() }</Affiliation>
    </Investigator>
</result>
