## Index

1. [Introduction](#introduction)
2. [Step 1: Create a new collection](#step-1)
3. [Step 2: Add XML files to the collection](#step-2)
4. [Step 3: Extract study title and status](#step-3)
5. [Step 4: Extract conditions and investigators](#step-4)
6. [Step 5: Filter studies based on specific condition](#step-5)
7. [Step 6: Extract study summary](#step-6)
8. [Step 7: Extract study start and completion dates](#step-7)
9. [Step 8: Update study completion date](#step-8)
10. [Step 9: Add new completion date to a study](#step-9)
11. [Step 10: Update the official title of a study](#step-10)
12. [Step 11: Add a new condition to a study](#step-11)
13. [Step 12: Remove a specific condition from a study](#step-12)
14. [Step 13: Add new contact information to a study](#step-13)
15. [Step 14: Remove specific contact information from a study](#step-14)

---



<h1 id="introduction" style="text-align: center;">Introduction</h1>

This file aims to introduce XQuery, its utility, and its differences compared to relational database management systems (RDBMS). It covers the steps related to the files present in the **XQuery_Scripts** folder in the repository, providing a comprehensive overview of how to effectively use XQuery for XML data processing and management. 

**Prerequisite:** **BaseX** should be installed to execute the XQuery steps outlined in this document.


**BaseX** is a high-performance XML database engine and a highly compliant XQuery processor, with full support for W3C Update and Full Text extensions. It is used to build complex and data-intensive web applications.

### Why use BaseX?
BaseX is particularly useful for efficiently managing and querying large amounts of XML data. It is lightweight, easy to install and use, and offers interactive user interfaces for both desktop and web-based applications.

### Differences with SQL Server Management Studio (SSMS)
- **BaseX**: It is a dedicated XML database that uses XQuery for querying and data manipulation. It is open source and specifically designed for XML.
- **SQL Server Management Studio (SSMS)**: It is a graphical interface for SQL Server, a relational database management system (RDBMS) that uses SQL for querying and data manipulation.

### Real-world utility and use cases
BaseX is used in applications that require rapid and scalable processing of XML data, such as content management systems, full-text search applications, and data analytics systems. It is particularly useful in contexts where data is structured in XML and requires complex query and manipulation operations.

### Why is SQL Server Management or RDBMS more commonly used?
SQL Server Management and other RDBMS are more common because they are better suited for managing data structured in relational tables, which are prevalent in many business applications. Additionally, SQL is a widely used and well-supported query language.

### Scientific Comparison
- **BaseX**: Uses XQuery, a functional programming language designed for manipulating XML.
- **SQL Server Management**: Uses SQL, a structured query language designed for managing relational databases.

### Detailed Comparison between BaseX and SQL Server Management Studio (SSMS):

| **Feature**                  | **BaseX**                                                        | **SQL Server Management Studio (SSMS)**                                                   |
|-----------------------------|-----------------------------------------------------------------|------------------------------------------------------------------------------------------|
| **Database Type**            | XML Database                                                    | Relational Database (RDBMS)                                                              |
| **Query Language**           | XQuery                                                          | SQL                                                                                      |
| **Tables and Columns**       | Does not use traditional tables and columns                      | Uses tables, columns, indexes, etc.                                                      |
| **Stored Procedures**        | Does not support stored procedures                              | Supports stored procedures, functions, triggers, etc.                                    |
| **Triggers**                 | Does not support triggers                                       | Supports triggers for automatic actions on specific events                               |
| **Open Source**              | Yes                                                             | No (SSMS is a tool from Microsoft for SQL Server)                                        |
| **User Interface**           | Interactive web and desktop interfaces                           | Comprehensive graphical interface for managing SQL Server                                |
| **Primary Usage**            | Managing and querying XML data                                  | Managing and administering relational databases                                          |
| **Performance**              | Optimized for XML, suitable for large volumes of XML data       | Optimized for structured data in relational tables, suitable for business applications   |
| **Community Support**        | Community support and open source                               | Professional support from Microsoft, integration with other Microsoft services           |

### Utility and Use Cases
- **BaseX**: Ideal for applications requiring rapid and scalable XML data processing, such as content management systems and full-text search applications.
- **SSMS**: Ideal for managing business databases, e-commerce applications, human resources management systems, etc.

### Why is SQL Server Management or RDBMS more commonly used?
SQL Server Management and other RDBMS are more common because they are better suited for managing data structured in relational tables, which are prevalent in many business applications. Additionally, SQL is a widely used and well-supported query language.

---

<h2 id="step-1" style="text-align: center;">Step 1: Create a new collection</h2>


**The Problem:**
The entity needs a structured way to store and manage XML data. In BaseX, this is achieved by creating a collection. A collection in BaseX is similar to a database in traditional RDBMS, where multiple XML documents can be stored and queried together.

**The Solution:**
To create a new collection in BaseX, we use the `db:create` function. This function initializes a new collection where we can store and manage our XML data.

```xquery
(: Create a new collection :)
db:create('DB2_covid_studies')
```

**Explanation:**
This command creates a new collection named `DB2_covid_studies` in BaseX, where all the XML documents related to the COVID-19 studies will be stored.

---
<h2 id="step-2" style="text-align: center;">Step 2: Add XML files to the collection</h2>


**The Problem:**
After creating the collection, the next step is to populate it with XML files. The entity needs to add multiple XML files from a specified folder into the newly created collection. 

**The Solution:**
To add XML files to the collection, we use a combination of the `file:list`, `file:read-text`, and `db:add` functions in XQuery. The `file:list` function lists all XML files in the specified folder, `file:read-text` reads the content of each file, and `db:add` adds the content to the collection.

```xquery
(: Add XML files to the collection :)
let $collection-name := 'DB2_covid_studies'
let $file-path := 'J:\DB2-project\COVID-19\'

for $file in file:list($file-path)
return db:add($collection-name, file:read-text(concat($file-path, $file)), $file)
```

**Explanation:**
- `let $collection-name := 'DB2_covid_studies'`: This defines the name of the collection where the files will be added.
- `let $file-path := 'J:\DB2-project\COVID-19\'`: This defines the path to the folder containing the XML files.
- `for $file in file:list($file-path)`: This loop iterates over each file in the specified folder.
- `return db:add($collection-name, file:read-text(concat($file-path, $file)), $file)`: For each file, this command reads the file content and adds it to the collection.



---
<h2 id="step-3" style="text-align: center;">Step 3: Extract study title and status</h2>


**The Problem:**
The entity needs to extract specific information from the XML documents stored in the collection. In this case, they need to extract the study title and status from each clinical study document in the collection.

**The Solution:**
To extract the study title and status, we can use an XQuery expression that retrieves these elements from the XML documents.

```xquery
(: Extract study title and status :)
for $study in collection('DB2_covid_studies')//clinical_study
return 
<result>
    <StudyTitle>{ $study/official_title/text() }</StudyTitle>
    <StudyStatus>{ $study/overall_status/text() }</StudyStatus>
</result>
```

**Explanation:**
- `for $study in collection('DB2_covid_studies')//clinical_study`: This loop iterates over each `clinical_study` element (This is the name of the node) in the `DB2_covid_studies` collection.
- `return`: For each study, the query constructs a `<result>` element containing the study title and status.
  - `<StudyTitle>{ $study/official_title/text() }</StudyTitle>`: Extracts the text content of the `official_title` element and inserts it into the `<StudyTitle>` element.
  - `<StudyStatus>{ $study/overall_status/text() }</StudyStatus>`: Extracts the text content of the `overall_status` element and inserts it into the `<StudyStatus>` element.



---

<h2 id="step-4" style="text-align: center;">Step 4: Extract conditions and investigators</h2>


**The Problem:**
The entity needs to extract specific details about the conditions and investigators from each clinical study document stored in the collection. This information is crucial for understanding the context and key personnel involved in each study.

**The Solution:**
To extract conditions and investigators, we can use an XQuery expression that retrieves these elements from the XML documents. 

```xquery
(: Extract conditions and investigators :)
for $study in collection('DB2_covid_studies')//clinical_study
return 
<result>
    <Condition>{ $study/condition/text() }</Condition>
    <Investigator>
        <Name>{ $study/overall_official/last_name/text() }</Name>
        <Role>{ $study/overall_official/role/text() }</Role>
        <Affiliation>{ $study/overall_official/affiliation/text() }</Affiliation>
    </Investigator>
</result>
```

**Explanation:**
- `for $study in collection('DB2_covid_studies')//clinical_study`: This loop iterates over each `clinical_study` element in the `DB2_covid_studies` collection.
- `return`: For each study, the query constructs a `<result>` element containing the condition and investigator details.
  - `<Condition>{ $study/condition/text() }</Condition>`: Extracts the text content of the `condition` element and inserts it into the `<Condition>` element.
  - `<Investigator>`: This nested element contains the details of the investigator.
    - `<Name>{ $study/overall_official/last_name/text() }</Name>`: Extracts the text content of the `last_name` element from `overall_official` and inserts it into the `<Name>` element.
    - `<Role>{ $study/overall_official/role/text() }</Role>`: Extracts the text content of the `role` element from `overall_official` and inserts it into the `<Role>` element.
    - `<Affiliation>{ $study/overall_official/affiliation/text() }</Affiliation>`: Extracts the text content of the `affiliation` element from `overall_official` and inserts it into the `<Affiliation>` element.



---


<h2 id="step-5" style="text-align: center;">Step 5: Filter studies based on specific condition</h2>


**The Problem:**
The entity needs to filter and retrieve clinical study documents based on a specific condition. In this case, they are interested in studies related to "COVID-19 Donors" and want to extract specific details from those studies.

**The Solution:**
To filter studies based on a specific condition, we can use an XQuery expression with a `where` clause to select only those studies that match the desired condition.

```xquery
(: Filter studies based on specific condition :)
for $study in collection('DB2_covid_studies')//clinical_study
where $study/condition = 'COVID-19 Donors'
return 
<result>
    <StudyTitle>{ $study/official_title/text() }</StudyTitle>
    <StudyStatus>{ $study/overall_status/text() }</StudyStatus>
</result>
```

**Explanation:**
- `for $study in collection('DB2_covid_studies')//clinical_study`: This loop iterates over each `clinical_study` element in the `DB2_covid_studies` collection.
- `where $study/condition = 'COVID-19 Donors'`: This `where` clause filters the studies to include only those where the `condition` element is equal to 'COVID-19 Donors'.
- `return`: For each study that matches the condition, the query constructs a `<result>` element containing the study title and status.
  - `<StudyTitle>{ $study/official_title/text() }</StudyTitle>`: Extracts the text content of the `official_title` element and inserts it into the `<StudyTitle>` element.
  - `<StudyStatus>{ $study/overall_status/text() }</StudyStatus>`: Extracts the text content of the `overall_status` element and inserts it into the `<StudyStatus>` element.



---

<h2 id="step-6" style="text-align: center;">Step 6: Extract study summary</h2>


**The Problem:**
The entity needs to extract a brief summary from each clinical study document stored in the collection. This summary provides a concise overview of the study's objectives, methods, and findings, making it easier to quickly understand the content of each study.

**The Solution:**
To extract the study summary, we can use an XQuery expression that retrieves the `brief_summary` element from the XML documents. 

```xquery
(: Extract study summary :)
for $study in collection('DB2_covid_studies')//clinical_study
return 
<result>
    <Summary>{ $study/brief_summary/textblock/text() }</Summary>
</result>
```

**Explanation:**
- `for $study in collection('DB2_covid_studies')//clinical_study`: This loop iterates over each `clinical_study` element in the `DB2_covid_studies` collection.
- `return`: For each study, the query constructs a `<result>` element containing the summary.
  - `<Summary>{ $study/brief_summary/textblock/text() }</Summary>`: Extracts the text content of the `textblock` element within `brief_summary` and inserts it into the `<Summary>` element.



---

<h2 id="step-7" style="text-align: center;">Step 7: Extract study start and completion dates</h2>


**The Problem:**
The entity needs to extract the start and completion dates from each clinical study document stored in the collection. These dates are essential for understanding the timeline of each study.

**The Solution:**
To extract the study start and completion dates, we can use an XQuery expression that retrieves these elements from the XML documents. 

```xquery
(: Extract study start and completion dates :)
for $study in collection('DB2_covid_studies')//clinical_study
return 
<result>
    <StartDate>{ $study/start_date/text() }</StartDate>
    <CompletionDate>{ $study/completion_date/text() }</CompletionDate>
</result>
```

**Explanation:**
- `for $study in collection('DB2_covid_studies')//clinical_study`: This loop iterates over each `clinical_study` element in the `DB2_covid_studies` collection.
- `return`: For each study, the query constructs a `<result>` element containing the start date and completion date.
  - `<StartDate>{ $study/start_date/text() }</StartDate>`: Extracts the text content of the `start_date` element and inserts it into the `<StartDate>` element.
  - `<CompletionDate>{ $study/completion_date/text() }</CompletionDate>`: Extracts the text content of the `completion_date` element and inserts it into the `<CompletionDate>` element.



---


<h2 id="step-8" style="text-align: center;">Step 8: Update study completion date</h2>


**The Problem:**
The entity needs to update the completion date of a specific clinical study in the collection. This is essential for keeping the study records up-to-date with the latest information.

**The Solution:**
To update the completion date, we can use an XQuery expression that identifies the specific study based on its `id_info/nct_id` and then modifies the `completion_date` element. 

```xquery
(: Update study completion date :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT01087333'
let $new-completion-date := 'December 2025'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
return (
  replace value of node $study/completion_date/text() with $new-completion-date
)
```

**Explanation:**
- `let $collection-name := 'DB2_covid_studies'`: This defines the name of the collection containing the study.
- `let $study-id := 'NCT01087333'`: This specifies the unique ID of the study to be updated.
- `let $new-completion-date := 'December 2025'`: This sets the new completion date for the study.
- `for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]`: This loop iterates over the clinical studies in the collection and finds the one with the specified `nct_id`.
- `return (replace value of node $study/completion_date/text() with $new-completion-date)`: This command replaces the value of the `completion_date` element with the new date.



---

<h2 id="step-9" style="text-align: center;">Step 9: Add new completion date to a study</h2>


**The Problem:**
The entity needs to add a new completion date to a specific clinical study in the collection. This is essential for updating the study records with anticipated completion dates.

**The Solution:**
To add a new completion date, we can use an XQuery expression that identifies the specific study based on its `id_info/nct_id` and then inserts a new `completion_date` element. 

```xquery
(: Add new completion date to a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT01087333'
let $new-completion-date := 'December 2025'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
return (
  insert node <completion_date type="Anticipated">{$new-completion-date}</completion_date> into $study
)
```

**Explanation:**
- `let $collection-name := 'DB2_covid_studies'`: This defines the name of the collection containing the study.
- `let $study-id := 'NCT01087333'`: This specifies the unique ID of the study to be updated.
- `let $new-completion-date := 'December 2025'`: This sets the new completion date for the study.
- `for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]`: This loop iterates over the clinical studies in the collection and finds the one with the specified `nct_id`.
- `return (insert node <completion_date type="Anticipated">{$new-completion-date}</completion_date> into $study)`: This command inserts a new `completion_date` element with the type "Anticipated" and the new date into the study.



---
<h2 id="step-10" style="text-align: center;">Step 10: Update the official title of a study</h2>


**The Problem:**
The entity needs to update the official title of a specific clinical study in the collection. This is essential for ensuring the study records reflect the most current and accurate information.

**The Solution:**
To update the official title, we can use an XQuery expression that identifies the specific study based on its `id_info/nct_id` and then modifies the `official_title` element. 

```xquery
(: Update the official title of a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT00571389'
let $new-title := 'Updated Study Title'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
return (
  replace value of node $study/official_title/text() with $new-title
)
```

**Explanation:**
- `let $collection-name := 'DB2_covid_studies'`: This defines the name of the collection containing the study.
- `let $study-id := 'NCT00571389'`: This specifies the unique ID of the study to be updated.
- `let $new-title := 'Updated Study Title'`: This sets the new official title for the study.
- `for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]`: This loop iterates over the clinical studies in the collection and finds the one with the specified `nct_id`.
- `return (replace value of node $study/official_title/text() with $new-title)`: This command replaces the value of the `official_title` element with the new title.



---

<h2 id="step-11" style="text-align: center;">Step 11: Add a new condition to a study</h2>


**The Problem:**
The entity needs to add a new condition to a specific clinical study in the collection. This is essential for updating the study records with additional relevant information about the conditions being studied.

**The Solution:**
To add a new condition, we can use an XQuery expression that identifies the specific study based on its `id_info/nct_id` and then inserts a new `condition` element.

```xquery
(: Add a new condition to a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT00571389'
let $new-condition := 'New Condition Example'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
return (
  insert node <condition>{ $new-condition }</condition> into $study
)
```

**Explanation:**
- `let $collection-name := 'DB2_covid_studies'`: This defines the name of the collection containing the study.
- `let $study-id := 'NCT00571389'`: This specifies the unique ID of the study to be updated.
- `let $new-condition := 'New Condition Example'`: This sets the new condition to be added to the study.
- `for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]`: This loop iterates over the clinical studies in the collection and finds the one with the specified `nct_id`.
- `return (insert node <condition>{ $new-condition }</condition> into $study)`: This command inserts a new `condition` element with the specified condition into the study.



---
<h2 id="step-12" style="text-align: center;">Step 12: Remove a specific condition from a study</h2>


**The Problem:**
The entity needs to remove a specific condition from a clinical study document in the collection. This is essential for keeping the study records up-to-date and removing outdated or irrelevant information.

**The Solution:**
To remove a specific condition, we can use an XQuery expression that identifies the specific study based on its `id_info/nct_id`, then locates the condition to be removed, and deletes it. 

```xquery
(: Remove a specific condition from a study :)
let $collection-name := 'DB2_covid_studies'
let $study-id := 'NCT00571389'
let $condition-to-remove := 'New Condition Example'

for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]
where $study/condition = $condition-to-remove
return (
  delete node $study/condition[text() = $condition-to-remove]
)
```

**Explanation:**
- `let $collection-name := 'DB2_covid_studies'`: This defines the name of the collection containing the study.
- `let $study-id := 'NCT00571389'`: This specifies the unique ID of the study to be updated.
- `let $condition-to-remove := 'New Condition Example'`: This sets the condition that needs to be removed from the study.
- `for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]`: This loop iterates over the clinical studies in the collection and finds the one with the specified `nct_id`.
- `where $study/condition = $condition-to-remove`: This `where` clause filters to the specific study condition that needs to be removed.
- `return (delete node $study/condition[text() = $condition-to-remove])`: This command deletes the `condition` element that matches the specified condition.



---
<h2 id="step-13" style="text-align: center;">Step 13: Add new contact information to a study</h2>

**The Problem:**
The entity needs to add new contact information to a specific clinical study in the collection. This is essential for updating the study records with the latest contact details of the study personnel.

**The Solution:**
To add new contact information, we can use an XQuery expression that identifies the specific study based on its `id_info/nct_id` and then inserts a new `overall_contact` element. 

```xquery
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
```

**Explanation:**
- `let $collection-name := 'DB2_covid_studies'`: This defines the name of the collection containing the study.
- `let $study-id := 'NCT00571389'`: This specifies the unique ID of the study to be updated.
- `let $new-contact := <overall_contact>...<phone>123-456-7890</phone></overall_contact>`: This sets the new contact information to be added to the study, including last name and phone number.
- `for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]`: This loop iterates over the clinical studies in the collection and finds the one with the specified `nct_id`.
- `return (insert node $new-contact into $study)`: This command inserts the new `overall_contact` element with the specified contact information into the study.



---

<h2 id="step-14" style="text-align: center;">Step 14: Remove specific contact information from a study</h2>


**The Problem:**
The entity needs to remove specific contact information from a clinical study document in the collection. This is necessary for keeping the study records accurate by removing outdated or incorrect contact details.

**The Solution:**
To remove specific contact information, we can use an XQuery expression that identifies the specific study based on its `id_info/nct_id`, then locates the contact information to be removed, and deletes it.

```xquery
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
```

**Explanation:**
- `let $collection-name := 'DB2_covid_studies'`: This defines the name of the collection containing the study.
- `let $study-id := 'NCT00571389'`: This specifies the unique ID of the study to be updated.
- `let $contact-last-name := 'Marco Rossi'`: This sets the last name of the contact to be removed.
- `let $contact-phone := '123-456-7890'`: This sets the phone number of the contact to be removed.
- `for $study in collection($collection-name)//clinical_study[id_info/nct_id = $study-id]`: This loop iterates over the clinical studies in the collection and finds the one with the specified `nct_id`.
- `where $study/overall_contact/last_name = $contact-last-name and $study/overall_contact/phone = $contact-phone`: This `where` clause filters to the specific contact information that needs to be removed.
- `return (delete node $study/overall_contact[phone = $contact-phone and last_name = $contact-last-name])`: This command deletes the `overall_contact` element that matches the specified last name and phone number.



---

