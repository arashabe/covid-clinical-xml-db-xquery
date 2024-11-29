(: Import the BaseX database module :)
import module namespace db = "http://basex.org/modules/db";
(: Import the file module for file operations :)
import module namespace file = "http://expath.org/ns/file";

(: Add XML files to the collection :)
let $collection-name := 'DB2_covid_studies'
let $file-path := 'J:\DB2-project\COVID-19\'

for $file in file:list($file-path)
return db:add($collection-name, file:read-text(concat($file-path, $file)), $file)
