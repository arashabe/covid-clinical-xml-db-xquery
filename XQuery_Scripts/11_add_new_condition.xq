(: Add a new condition to a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT00571389'
let $new-condition := 'New Condition Example'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
return (
  insert node <condition>{ $new-condition }</condition> into $study
)
