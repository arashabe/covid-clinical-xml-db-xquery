(: Remove a specific condition from a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT00571389'
let $condition-to-remove := 'New Condition Example'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
where $study/condition = $condition-to-remove
return (
  delete node $study/condition[text() = $condition-to-remove]
)
