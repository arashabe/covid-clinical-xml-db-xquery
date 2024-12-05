(: Add new completion date to a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT01087333'
let $new-completion-date := 'December 2025'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
return (
  insert node <completion_date type="Anticipated">{$new-completion-date}</completion_date> into $study
)
