(: Remove the specific contact information from a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT00571389'
let $contact-last-name := 'Marco Rossi'
let $contact-phone := '123-456-7890'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
where $study/overall_contact/last_name = $contact-last-name
      and $study/overall_contact/phone = $contact-phone
return (
  delete node $study/overall_contact[phone = $contact-phone and last_name = $contact-last-name]
)
