(: Filter studies based on specific condition :)
for $study in collection('DB2_covid_studies')//clinical_study
where $study/condition = 'COVID-19 Donors'
return 
<result>
    <StudyTitle>{ $study/official_title/text() }</StudyTitle>
    <StudyStatus>{ $study/overall_status/text() }</StudyStatus>
</result>
