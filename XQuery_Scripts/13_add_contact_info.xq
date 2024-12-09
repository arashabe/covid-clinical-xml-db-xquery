(: Add new contact information to a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT00571389'
let $new-contact := <overall_contact>
                      <last_name>Marco Rossi</last_name>
                      <phone>123-456-7890</phone>
                    </overall_contact>

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
return (
  insert node $new-contact into $study
)
