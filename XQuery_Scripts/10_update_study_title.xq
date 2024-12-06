(: Update the official title of a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT00571389'
let $new-title := 'Updated Study Title'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
return (
  replace value of node $study/official_title/text() with $new-title
)
