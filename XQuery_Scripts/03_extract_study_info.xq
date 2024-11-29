(: Extract study title and status :)
for $study in collection('DB2_covid_studies')//clinical_study
return 
<result>
    <StudyTitle>{ $study/official_title/text() }</StudyTitle>
    <StudyStatus>{ $study/overall_status/text() }</StudyStatus>
</result>
