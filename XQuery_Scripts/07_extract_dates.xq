(: Extract study start and completion dates :)
for $study in collection('DB2_covid_studies')//clinical_study
return 
<result>
    <StartDate>{ $study/start_date/text() }</StartDate>
    <CompletionDate>{ $study/completion_date/text() }</CompletionDate>
</result>
