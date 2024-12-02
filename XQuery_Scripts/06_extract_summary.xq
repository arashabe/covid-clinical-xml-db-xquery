(: Extract study summary :)
for $study in collection('DB2_covid_studies')//clinical_study
return 
<result>
    <Summary>{ $study/brief_summary/textblock/text() }</Summary>
</result>
