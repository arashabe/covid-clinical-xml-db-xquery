## Index

1. [Introduction](#introduction)
2. [Step 1: Load XML Files](#step-1)
3. [Step 2: Store Clinical Study Info](#step-2)
4. [Step 3: Store Sponsor Info](#step-3)
5. [Step 4: Store Condition Info](#step-4)
6. [Step 5: Store Eligibility Info](#step-5)
7. [Step 6: Store Contact Info](#step-6)
8. [Step 7: Store Location Info](#step-7)
9. [Step 8: Trigger for ClinicalStudies](#step-8)
10. [Step 9: Trigger on Studies](#step-9)
11. [Step 10: Update XML Data](#step-10)
12. [Step 11: Automate Data Insert and Update](#step-11)
13. [Step 12: Backup Job Configuration and Management](#step-12)


---


<h1 id="introduction" style="text-align: center;">Introduction</h1>

During the **Database 2** university course, we delved into numerous topics, including Transactional Systems, Internal Architecture of a Relational Server, Distributed and Parallel Architectures, Active Databases, and XML Databases. This project aims to bridge the gap between theory and practice regarding:

**Description of the ECA (Event/Condition/Action) Paradigm for Active Rules:**
- Mechanisms for executing active rules.
- Analysis techniques for active rules.
- Triggers in relational systems.
- Applications of active databases.

**XML Databases:**
- Introduction to XML as an interoperability standard for data exchange.
- Relational-XML databases and native XML databases.
- Query languages for XML: XPath, XQuery.

The XML data is sourced from [Kaggle](https://www.kaggle.com/datasets/parulpandey/covid19-clinical-trials-dataset/data?select=COVID-19+CLinical+trials+studies). The XML files in my case are saved in the folder J:\DB2-project\COVID-19.
This file aims to explain the problems and solutions with a comprehensive description of all the steps related to the scripts present in the **SQL_XPath_Scripts** folder in the repository.


Prerequisite: We need **SQL Server Management Studio (SSMS)** installed to execute the steps outlined in this document.


---
<h2 id="step-1" style="text-align: center;">Step 1: Load XML Files</h2>

**The Problem:**
Suppose there are various clinical studies conducted by researchers and healthcare personnel in different locations. These studies are provided in XML format to a main entity. This entity, which intends to use the studies, faces a key problem: the files are in XML format, while the entity uses a relational database to store, update, analyze, and prepare the information for future research. The entity seeks a solution that allows them to load the XML documents into the database and divide the information contained in each file into various tables, such as `Studies`, `Sponsors`, `Conditions`, `Contacts`, `Locations`, etc. This way, a researcher at the entity can access the database, search for information of interest, and process it.

**The Solution:**
The `1_db_creation_and_xml_loading` file provides an SQL script that performs the following operations to solve the problem:

1. **Switch to the master database**: This step ensures that the database drop operation is performed safely.
   ```sql
   USE master;
   ```

2. **Drop the existing database if it exists**: If the `DB2_covid_studies` database exists, it is disconnected and dropped to ensure a clean setup.
   ```sql
   IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DB2_covid_studies')
   BEGIN
       ALTER DATABASE DB2_covid_studies SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
       DROP DATABASE DB2_covid_studies;
   END
   ```

3. **Create a new database**: The `DB2_covid_studies` database is created.
   ```sql
   CREATE DATABASE DB2_covid_studies;
   USE DB2_covid_studies;
   ```

4. **Enable xp_cmdshell**: This command allows interaction with the operating system to execute shell commands.
   ```sql
   EXEC sp_configure 'show advanced options', 1;
   RECONFIGURE;
   EXEC sp_configure 'xp_cmdshell', 1;
   RECONFIGURE;
   ```

5. **Create the table for XML data**: The `ClinicalStudies` table is created to store the XML data from the studies.
   ```sql
   CREATE TABLE ClinicalStudies (
       AUTO_INCREMENT INT IDENTITY PRIMARY KEY,
       StudyXML XML
   );
   ```

6. **Insert XML file names into a temporary table**: A temporary table is created to store the names of the XML files located in a specific folder.
   ```sql
   -- Drop the temporary table if it exists 
   IF OBJECT_ID('tempdb..#TempFiles', 'U') IS NOT NULL DROP TABLE #TempFiles;
   CREATE TABLE #TempFiles (FileName NVARCHAR(4000));
   INSERT INTO #TempFiles (FileName)
   EXEC xp_cmdshell 'dir J:\DB2-project\COVID-19\*.xml /b';
   -- Remove NULL values
   DELETE FROM #TempFiles WHERE FileName IS NULL;

   ```

7. **Load the XML files into the database**: Using a cursor, the XML files are loaded into the `ClinicalStudies` table.
   ```sql
    --The cursor `file_cursor` is declared to select the file names from the temporary table `#TempFiles`.
   DECLARE file_cursor CURSOR FOR 
   SELECT FileName FROM #TempFiles;

    --The cursor `file_cursor` is opened and made ready for use.
   OPEN file_cursor;
   
    --The first file name from the result set is fetched and assigned to the variable `@fileName`.
   FETCH NEXT FROM file_cursor INTO @fileName;

   WHILE @@FETCH_STATUS = 0
   BEGIN
       SET @fullPath = @folderPath + @fileName;
       SET @sql = 'INSERT INTO ClinicalStudies (StudyXML) 
                    SELECT CAST(BULK_COLUMN AS XML) 
                    FROM OPENROWSET(BULK ''' + @fullPath + ''', SINGLE_BLOB) AS T(BULK_COLUMN);';
       BEGIN TRY
           EXEC sp_executesql @sql;
       END TRY
       BEGIN CATCH
           PRINT 'Error loading file: ' + @fileName;
           PRINT ERROR_MESSAGE();
       END CATCH;
       FETCH NEXT FROM file_cursor INTO @fileName;
   END

    -- Close and deallocate the cursor
    CLOSE file_cursor;
    DEALLOCATE file_cursor;

    -- Drop the temporary table
    DROP TABLE #TempFiles;
   ```
The variable @sql is used to create a dynamic SQL query, constructing the query content on the fly based on the value of the variable @fullPath. The query inserts data into the ClinicalStudies table, specifically into the StudyXML column. The OPENROWSET instruction reads data from a specified file using the BULK parameter, which indicates bulk loading of data from the file. The full path of the file to be loaded, stored in the @fullPath variable, is included in the query. The SINGLE_BLOB parameter indicates that the file should be read as a single large binary object (BLOB). The alias T is assigned to the generated temporary table and BULK_COLUMN to the column containing the file data. Finally, the SELECT CAST(BULK_COLUMN AS XML) instruction converts the data read from the file (BLOB) into XML format and inserts it into the StudyXML column of the ClinicalStudies table.

8. **Verify the data load**: After loading, the total number of records in the `ClinicalStudies` table is verified.
   ```sql
   SELECT COUNT(*) AS TotalRecords FROM ClinicalStudies;
   ```

This solution automates the loading of over 50,000 XML files related to COVID-19 studies into the relational database, making the data easily accessible and usable for further analysis and research.

![Loading xml](/Images/step01.PNG)

---
<h2 id="step-2" style="text-align: center;">Step 2: Store Clinical Study Info</h2>

**The Problem:**
The main entity needs to extract key information from the XML files and store it in a structured format within the relational database. This allows for efficient querying, updating, and analysis of the clinical study data. The challenge is to parse the relevant details from the XML format and populate a relational table with this information.

**The Solution:**
The `2_create_studies_table_from_xml` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   ```

2. **Drop the existing `Studies` table if it exists**: To avoid conflicts, the existing `Studies` table is dropped if it already exists.
   ```sql
   IF OBJECT_ID('dbo.Studies', 'U') IS NOT NULL
       DROP TABLE dbo.Studies;
   ```

3. **Create the `Studies` table with extracted XML data**: The script extracts key data from the `StudyXML` field in the `ClinicalStudies` table and inserts it into the new `Studies` table. This table holds general information about clinical studies.
   ```sql
   SELECT 
       StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
       StudyXML.value('(//org_study_id)[1]', 'NVARCHAR(50)') AS OrgStudyID,
       StudyXML.value('(//brief_title)[1]', 'NVARCHAR(500)') AS BriefTitle,
       StudyXML.value('(//official_title)[1]', 'NVARCHAR(1000)') AS OfficialTitle,
       StudyXML.value('(//overall_status)[1]', 'NVARCHAR(50)') AS Status,
       StudyXML.value('(//study_type)[1]', 'NVARCHAR(50)') AS StudyType,
       TRY_CAST(StudyXML.value('(//start_date)[1]', 'NVARCHAR(50)') AS DATE) AS StartDate,
       TRY_CAST(StudyXML.value('(//completion_date)[1]', 'NVARCHAR(50)') AS DATE) AS CompletionDate,
       TRY_CAST(StudyXML.value('(//primary_completion_date)[1]', 'NVARCHAR(50)') AS DATE) AS PrimaryCompletionDate
   INTO Studies
   FROM ClinicalStudies;
   ```

    **Add the primary key to the StudyID column**: This command will define StudyID as the primary key for the Studies table, ensuring that each value in the **StudyID** column is **unique** and cannot be NULL.
   ```sql
   ALTER TABLE Studies 
   ADD CONSTRAINT PK_Studies PRIMARY KEY (StudyID);
   ```

4. **Verify the data load**: The script verifies the data extraction and loading process by selecting the top 10 records from the `Studies` table.
   ```sql
   SELECT TOP 10 * FROM Studies;
   ```


![Loading xml](/Images/step02.PNG)
---

<h2 id="step-3" style="text-align: center;">Step 3: Store Sponsor Info</h2>

**The Problem:**
The main entity needs to extract information about the sponsors of clinical studies from the XML files and store it in a structured format within the relational database. This allows for efficient querying and analysis of the sponsor data. The challenge is to parse the relevant details from the XML format and populate a relational table with this information.

**The Solution:**
The `3_create_sponsors_table_from_xml` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   ```

2. **Drop the existing `Sponsors` table if it exists**: To avoid conflicts, the existing `Sponsors` table is dropped if it already exists.
   ```sql
   IF OBJECT_ID('dbo.Sponsors', 'U') IS NOT NULL
       DROP TABLE dbo.Sponsors;
   ```

3. **Create the `Sponsors` table with extracted XML data**: The script extracts key data about sponsors from the `StudyXML` field in the `ClinicalStudies` table and inserts it into the new `Sponsors` table. This table holds information about the sponsors related to each clinical study.
   ```sql
   SELECT
       StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
       sponsor.value('(agency)[1]', 'NVARCHAR(255)') AS Agency,
       sponsor.value('(agency_class)[1]', 'NVARCHAR(50)') AS AgencyClass
   INTO Sponsors
   FROM ClinicalStudies
   CROSS APPLY StudyXML.nodes('//sponsors/lead_sponsor') AS S(sponsor);
   ```

4. **Verify the data load**: The script verifies the data extraction and loading process by selecting the top 10 records from the `Sponsors` table.
   ```sql
   SELECT TOP 10 * FROM Sponsors;
   ```
![Loading xml](/Images/step03.PNG)
This solution allows the entity to efficiently parse and store crucial sponsor information from clinical studies in a relational format, making it easier to query and analyze the data.

---

<h2 id="step-4" style="text-align: center;">Step 4: Store Condition Info</h2>


**The Problem:**
The main entity needs to extract information about the conditions and diseases that are the focus of each clinical study from the XML files and store it in a structured format within the relational database. This allows for efficient querying and analysis of the conditions data. The challenge is to parse the relevant details from the XML format and populate a relational table with this information.

**The Solution:**
The `4_create_conditions_table_from_xml` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   ```

2. **Drop the existing `Conditions` table if it exists**: To avoid conflicts, the existing `Conditions` table is dropped if it already exists.
   ```sql
   IF OBJECT_ID('dbo.Conditions', 'U') IS NOT NULL
       DROP TABLE dbo.Conditions;
   ```

3. **Create the `Conditions` table with extracted XML data**: The script extracts key data about conditions from the `StudyXML` field in the `ClinicalStudies` table and inserts it into the new `Conditions` table. This table holds information about the conditions and diseases that are the focus of each clinical study.
   ```sql
   SELECT
       StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
       condition.value('.', 'NVARCHAR(255)') AS Condition
   INTO Conditions
   FROM ClinicalStudies
   CROSS APPLY StudyXML.nodes('//condition') AS C(condition);
   ```

4. **Verify the data load**: The script verifies the data extraction and loading process by selecting the top 10 records from the `Conditions` table.
   ```sql
   SELECT TOP 10 * FROM Conditions;
   ```

![Loading xml](/Images/step04.PNG)

---

<h2 id="step-5" style="text-align: center;">Step 5: Store Eligibility Info</h2>


**The Problem:**
The main entity needs to extract information about the eligibility criteria for participants in each clinical study from the XML files and store it in a structured format within the relational database. This allows for efficient querying and analysis of the eligibility data. The challenge is to parse the relevant details from the XML format and populate a relational table with this information.

**The Solution:**
The `5_create_eligibility_table_from_xml` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   ```

2. **Drop the existing `Eligibility` table if it exists**: To avoid conflicts, the existing `Eligibility` table is dropped if it already exists.
   ```sql
   IF OBJECT_ID('dbo.Eligibility', 'U') IS NOT NULL
       DROP TABLE dbo.Eligibility;
   ```

3. **Create the `Eligibility` table with extracted XML data**: The script extracts key data about eligibility criteria from the `StudyXML` field in the `ClinicalStudies` table and inserts it into the new `Eligibility` table. This table holds information about the eligibility criteria for participants in each clinical study.
   ```sql
   SELECT
       StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
       StudyXML.value('(//eligibility/gender)[1]', 'NVARCHAR(10)') AS Gender,
       StudyXML.value('(//eligibility/minimum_age)[1]', 'NVARCHAR(20)') AS MinimumAge,
       StudyXML.value('(//eligibility/maximum_age)[1]', 'NVARCHAR(20)') AS MaximumAge,
       StudyXML.value('(//eligibility/healthy_volunteers)[1]', 'NVARCHAR(50)') AS HealthyVolunteers,
       StudyXML.value('(//eligibility/criteria/textblock)[1]', 'NVARCHAR(MAX)') AS CriteriaText
   INTO Eligibility
   FROM ClinicalStudies;
   ```

4. **Verify the data load**: The script verifies the data extraction and loading process by selecting the top 10 records from the `Eligibility` table.
   ```sql
   SELECT TOP 10 * FROM Eligibility;
   ```


![Loading xml](/Images/step05.PNG)
---
<h2 id="step-6" style="text-align: center;">Step 6: Store Contact Info</h2>


**The Problem:**
The main entity needs to extract contact information for clinical study participants and store it in a structured format within the relational database. This allows for efficient querying and analysis of the contact data. The challenge is to parse the relevant details from the XML format and populate a relational table with this information.

**The Solution:**
The `6_create_contacts_table_from_xml` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   ```

2. **Drop the existing `Contacts` table if it exists**: To avoid conflicts, the existing `Contacts` table is dropped if it already exists.
   ```sql
   IF OBJECT_ID('dbo.Contacts', 'U') IS NOT NULL
       DROP TABLE dbo.Contacts;
   ```

3. **Create the `Contacts` table with extracted XML data**: The script extracts key contact information from the `StudyXML` field in the `ClinicalStudies` table and inserts it into the new `Contacts` table. This includes the overall contact information for each study.
   ```sql
   SELECT
       StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
       overall_contact.value('(last_name)[1]', 'NVARCHAR(255)') AS LastName,
       overall_contact.value('(phone)[1]', 'NVARCHAR(20)') AS Phone,
       overall_contact.value('(email)[1]', 'NVARCHAR(255)') AS Email
   INTO Contacts
   FROM ClinicalStudies
   CROSS APPLY StudyXML.nodes('//overall_contact') AS OC(overall_contact);
   ```

4. **Insert additional contact information from location/contact nodes**: The script also extracts contact information from the `location/contact` nodes and inserts it into the `Contacts` table.
   ```sql
   INSERT INTO Contacts (StudyID, LastName, Phone, Email)
   SELECT
       StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
       location_contact.value('(last_name)[1]', 'NVARCHAR(255)') AS LastName,
       location_contact.value('(phone)[1]', 'NVARCHAR(20)') AS Phone,
       location_contact.value('(email)[1]', 'NVARCHAR(255)') AS Email
   FROM ClinicalStudies
   CROSS APPLY StudyXML.nodes('//location/contact') AS LC(location_contact);
   ```

5. **Verify the data load**: The script verifies the data extraction and loading process by selecting the top 50 records from the `Contacts` table where the phone number is not null.
   ```sql
   SELECT TOP 50 * FROM Contacts WHERE phone IS NOT NULL;
   ```

![Loading xml](/Images/step06.PNG)

---

<h2 id="step-7" style="text-align: center;">Step 7: Store Location Info</h2>


**The Problem:**
The main entity needs to extract information about the locations where clinical studies are being conducted from the XML files and store it in a structured format within the relational database. This allows for efficient querying and analysis of the location data. The challenge is to parse the relevant details from the XML format and populate a relational table with this information.

**The Solution:**
The `7_create_locations_table_from_xml` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   ```

2. **Drop the existing `Locations` table if it exists**: To avoid conflicts, the existing `Locations` table is dropped if it already exists.
   ```sql
   IF OBJECT_ID('dbo.Locations', 'U') IS NOT NULL
       DROP TABLE dbo.Locations;
   ```

3. **Create the `Locations` table with extracted XML data**: The script extracts key data about locations from the `StudyXML` field in the `ClinicalStudies` table and inserts it into the new `Locations` table. This table holds information about the facilities and their addresses where the clinical studies are being conducted.
   ```sql
   SELECT
       StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
       location.value('(facility/name)[1]', 'NVARCHAR(255)') AS FacilityName,
       location.value('(facility/address/city)[1]', 'NVARCHAR(100)') AS City,
       location.value('(facility/address/state)[1]', 'NVARCHAR(100)') AS State,
       location.value('(facility/address/country)[1]', 'NVARCHAR(100)') AS Country,
       location.value('(status)[1]', 'NVARCHAR(50)') AS Status
   INTO Locations
   FROM ClinicalStudies
   CROSS APPLY StudyXML.nodes('//location') AS L(location);
   ```

4. **Verify the data load**: The script verifies the data extraction and loading process by selecting the top 10 records from the `Locations` table.
   ```sql
   SELECT TOP 10 * FROM Locations;
   ```

![Loading xml](/Images/step07.PNG)

---

<h2 id="step-8" style="text-align: center;">Step 8: Trigger for ClinicalStudies</h2>


**The Problem:**
The main entity needs to keep track of changes (inserts, updates, and deletes) made to the `ClinicalStudies` table. This is essential for audit purposes, ensuring data integrity, and maintaining a log of all actions performed on the clinical study records. The challenge is to create a mechanism that automatically records these changes without manual intervention.

**The Solution:**
The `8_clinical_studies_trigger_log_operations` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   GO
   ```

2. **Create the `ClinicalStudies_Log` table if not already created**: This table will store the log entries for changes made to the `ClinicalStudies` table.
   ```sql
   IF OBJECT_ID('dbo.ClinicalStudies_Log', 'U') IS NOT NULL
       DROP TABLE dbo.ClinicalStudies_Log;

   CREATE TABLE ClinicalStudies_Log (
       LogID INT IDENTITY(1,1) PRIMARY KEY,
       AutoIncrementID INT,
       ActionType VARCHAR(10),
       InsertedAt DATETIME DEFAULT GETDATE()
   );
   GO
   ```

3. **Drop the existing insert trigger if it exists**: If a trigger for inserts already exists, it is dropped to avoid conflicts.
   ```sql
   IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterInsert_ClinicalStudies')
   BEGIN
       DROP TRIGGER trg_AfterInsert_ClinicalStudies;
   END;
   GO
   ```

4. **Create the insert trigger**: This trigger automatically logs insert actions on the `ClinicalStudies` table.
   ```sql
   CREATE TRIGGER trg_AfterInsert_ClinicalStudies
   ON ClinicalStudies
   AFTER INSERT
   AS
   BEGIN
       INSERT INTO ClinicalStudies_Log (AutoIncrementID, ActionType)
       SELECT 
           i.AUTO_INCREMENT, 'INSERT'
       FROM inserted AS i;
   END;
   GO
   ```

5. **Drop the existing delete trigger if it exists**: If a trigger for deletes already exists, it is dropped to avoid conflicts.
   ```sql
   IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterDelete_ClinicalStudies')
   BEGIN
       DROP TRIGGER trg_AfterDelete_ClinicalStudies;
   END;
   GO
   ```

6. **Create the delete trigger**: This trigger automatically logs delete actions on the `ClinicalStudies` table.
   ```sql
   CREATE TRIGGER trg_AfterDelete_ClinicalStudies
   ON ClinicalStudies
   AFTER DELETE
   AS
   BEGIN
       INSERT INTO ClinicalStudies_Log (AutoIncrementID, ActionType)
       SELECT 
           d.AUTO_INCREMENT, 'DELETE'
       FROM deleted AS d;
   END;
   GO
   ```

7. **Drop the existing update trigger if it exists**: If a trigger for updates already exists, it is dropped to avoid conflicts.
   ```sql
   IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterUpdate_ClinicalStudies')
   BEGIN
       DROP TRIGGER trg_AfterUpdate_ClinicalStudies;
   END;
   GO
   ```

8. **Create the update trigger**: This trigger automatically logs update actions on the `ClinicalStudies` table.
   ```sql
   CREATE TRIGGER trg_AfterUpdate_ClinicalStudies
   ON ClinicalStudies
   AFTER UPDATE
   AS
   BEGIN
       INSERT INTO ClinicalStudies_Log (AutoIncrementID, ActionType)
       SELECT 
           u.AUTO_INCREMENT, 'UPDATE'
       FROM inserted AS u;
   END;
   GO
   ```

9. **Test the triggers**: The script includes examples of insert, update, and delete operations to test if the triggers are working correctly.
   ```sql
   -- Update example
    UPDATE ClinicalStudies
    SET StudyXML.modify('
        replace value of (//completion_date/text())[1]
        with "August 02, 2022"
    ')
    WHERE AUTO_INCREMENT = 5783;

   -- Delete example
   DELETE FROM ClinicalStudies
   WHERE AUTO_INCREMENT = 5783;
   ```

10. **View the log**: The script retrieves the entries from the `ClinicalStudies_Log` table to verify that the triggers are logging the actions correctly.
    ```sql
    SELECT * FROM ClinicalStudies_Log;
    ```
![Loading xml](/Images/step08.PNG)

This solution ensures that any insert, update, or delete actions performed on the `ClinicalStudies` table are automatically logged, providing a robust audit trail for the clinical study data.

---

<h2 id="step-9" style="text-align: center;">Step 9: Trigger on Studies</h2>


**The Problem:**
The main entity needs to keep track of changes (inserts, updates, and deletes) made to the `Studies` table. This is essential for audit purposes, ensuring data integrity, and maintaining a log of all actions performed on the study records. The challenge is to create a mechanism that automatically records these changes without manual intervention.

**The Solution:**
The `9_studies_trigger_log_operations` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   GO
   ```

2. **Create the `Studies_Log` table if not already created**: This table will store the log entries for changes made to the `Studies` table.
   ```sql
   IF OBJECT_ID('dbo.Studies_Log', 'U') IS NOT NULL
       DROP TABLE dbo.Studies_Log;

   CREATE TABLE Studies_Log (
       LogID INT IDENTITY(1,1) PRIMARY KEY,
       StudyID NVARCHAR(50),
       ActionType VARCHAR(10),
       InsertedAt DATETIME DEFAULT GETDATE()
   );
   GO
   ```

3. **Drop the existing insert trigger if it exists**: If a trigger for inserts already exists, it is dropped to avoid conflicts.
   ```sql
   IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterInsert_Studies')
   BEGIN
       DROP TRIGGER trg_AfterInsert_Studies;
   END;
   GO
   ```

4. **Create the insert trigger**: This trigger automatically logs insert actions on the `Studies` table.
   ```sql
   CREATE TRIGGER trg_AfterInsert_Studies
   ON Studies
   AFTER INSERT
   AS
   BEGIN
       INSERT INTO Studies_Log (StudyID, ActionType)
       SELECT 
           i.StudyID, 'INSERT'
       FROM inserted AS i;
   END;
   GO
   ```

5. **Drop the existing delete trigger if it exists**: If a trigger for deletes already exists, it is dropped to avoid conflicts.
   ```sql
   IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterDelete_Studies')
   BEGIN
       DROP TRIGGER trg_AfterDelete_Studies;
   END;
   GO
   ```

6. **Create the delete trigger**: This trigger automatically logs delete actions on the `Studies` table.
   ```sql
   CREATE TRIGGER trg_AfterDelete_Studies
   ON Studies
   AFTER DELETE
   AS
   BEGIN
       INSERT INTO Studies_Log (StudyID, ActionType)
       SELECT 
           d.StudyID, 'DELETE'
       FROM deleted AS d;
   END;
   GO
   ```

7. **Drop the existing update trigger if it exists**: If a trigger for updates already exists, it is dropped to avoid conflicts.
   ```sql
   IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterUpdate_Studies')
   BEGIN
       DROP TRIGGER trg_AfterUpdate_Studies;
   END;
   GO
   ```

8. **Create the update trigger**: This trigger automatically logs update actions on the `Studies` table.
   ```sql
   CREATE TRIGGER trg_AfterUpdate_Studies
   ON Studies
   AFTER UPDATE
   AS
   BEGIN
       INSERT INTO Studies_Log (StudyID, ActionType)
       SELECT 
           u.StudyID, 'UPDATE'
       FROM inserted AS u;
   END;
   GO
   ```

9. **Test the triggers**: The script includes examples of insert, update, and delete operations to test if the triggers are working correctly.
   ```sql
   -- Insert example
   INSERT INTO Studies (StudyID, OrgStudyID, BriefTitle, OfficialTitle, Status, StudyType, StartDate, CompletionDate, PrimaryCompletionDate)
   VALUES ('NCT001', 'ORG001', 'Test Study', 'Official Test Study', 'Completed', 'Interventional', '2023-01-01', '2023-12-31', '2023-11-30');
   GO
   -- Update example
   UPDATE Studies
   SET Status = 'Active'
   WHERE StudyID = 'NCT001';
   GO
   -- Delete example
   DELETE FROM Studies
   WHERE StudyID = 'NCT001';
   ```

10. **View the log**: The script retrieves the entries from the `Studies_Log` table to verify that the triggers are logging the actions correctly.
    ```sql
    SELECT * FROM Studies_Log;
    ```

This solution ensures that any insert, update, or delete actions performed on the `Studies` table are automatically logged, providing a robust audit trail for the study data.

---

<h2 id="step-10" style="text-align: center;">Step 10: Update XML Data</h2>


**The Problem:**
The main entity needs to perform various operations on the XML data stored in the `ClinicalStudies` table. These operations include verifying the data load, extracting specific information, filtering studies based on certain conditions, and updating XML data. The challenge is to write SQL queries that can handle these tasks efficiently and accurately.

**The Solution:**
The `10_clinical_studies_data_operations` file provides an SQL script that performs the following operations to address the problem:

1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   GO
   ```

2. **Verify the data load**: The script verifies the total number of records in the `ClinicalStudies` table.
   ```sql
   SELECT COUNT(*) AS TotalRecords FROM ClinicalStudies;
   GO
   ```

3. **Extract study name and status**: The script extracts the official title and overall status of each clinical study from the XML data.
   ```sql
   SELECT 
       StudyXML.value('(/clinical_study/official_title)[1]', 'NVARCHAR(MAX)') AS StudyTitle,
       StudyXML.value('(/clinical_study/overall_status)[1]', 'NVARCHAR(MAX)') AS StudyStatus
   FROM 
       ClinicalStudies;
   GO
   ```

4. **Extract conditions and researchers**: The script extracts the conditions and the researchers' last names and roles for each clinical study.
   ```sql
   SELECT 
       StudyXML.value('(/clinical_study/condition)[1]', 'NVARCHAR(MAX)') AS Condition,
       StudyXML.value('(/clinical_study/overall_official/last_name)[1]', 'NVARCHAR(MAX)') AS InvestigatorLastName,
       StudyXML.value('(/clinical_study/overall_official/role)[1]', 'NVARCHAR(MAX)') AS InvestigatorRole
   FROM 
       ClinicalStudies;
   GO
   ```

5. **Filter studies based on conditions**: The script filters studies where the condition is "COVID-19" and extracts their titles and statuses.
   ```sql
   SELECT 
       StudyXML.value('(/clinical_study/official_title)[1]', 'NVARCHAR(MAX)') AS StudyTitle,
       StudyXML.value('(/clinical_study/overall_status)[1]', 'NVARCHAR(MAX)') AS StudyStatus
   FROM 
       ClinicalStudies
   WHERE 
       StudyXML.exist('/clinical_study/condition[text()="COVID-19"]') = 1;
   GO
   ```

6. **Update XML data**: The script updates the overall status of a specific study identified by its `nct_id`.
   ```sql
   DECLARE @newStatus NVARCHAR(MAX) = 'Completed';
   DECLARE @studyId NVARCHAR(50) = 'NCT00571389'; 

   UPDATE ClinicalStudies
   SET StudyXML.modify('replace value of (/clinical_study/overall_status/text())[1] with sql:variable("@newStatus")')
   WHERE StudyXML.exist('/clinical_study/nct_id[text()=sql:variable("@studyId")]') = 1; 
   GO
   ```

7. **Example query**: The script provides an example query to extract various details about studies with a null completion date and a specific start date.
   ```sql
   SELECT 
       StudyXML.value('(/clinical_study/id_info/nct_id)[1]', 'NVARCHAR(MAX)') AS StudyID,
       StudyXML.value('(/clinical_study/official_title)[1]', 'NVARCHAR(MAX)') AS StudyTitle,
       StudyXML.value('(/clinical_study/overall_status)[1]', 'NVARCHAR(MAX)') AS StudyStatus,
       StudyXML.value('(/clinical_study/start_date)[1]', 'NVARCHAR(MAX)') AS StartDate,
       StudyXML.value('(/clinical_study/completion_date)[1]', 'NVARCHAR(MAX)') AS CompletionDate
   FROM 
       ClinicalStudies
   WHERE 
       StudyXML.value('(/clinical_study/completion_date)[1]', 'NVARCHAR(MAX)') IS NULL
       AND StudyXML.value('(/clinical_study/start_date)[1]', 'NVARCHAR(MAX)') = 'March 15, 2011';
   GO
   ```

![Loading xml](/Images/step10.PNG)

---

<h2 id="step-11" style="text-align: center;">Step 11: Automate Data Insert and Update</h2>


**The Problem:**
The main entity needs an efficient way to insert and update clinical study data from multiple XML files into the relational database. Given that new XML files may periodically arrive in the folder on the server, the solution must account for these new files and automatically import them into the database, inserting them into the already created tables. In the real world, it's impractical to drop and recreate the entire database each time new data arrives. Therefore, a method must be found to address this challenge. This is where the use of stored procedures comes into play, allowing us to identify new XML files that are not already present in our database and insert them.

**The Solution:**
The `11_stored_procedure_creation` file provides an SQL script that performs the following operations to address the problem:

### Step 1: Creation of a stored procedure for insertion and updating
1. **Switch to the target database**: Ensure the script operates within the correct database, `DB2_covid_studies`.
   ```sql
   USE DB2_covid_studies;
   GO
   ```

2. **Create the stored procedure**: The `InsertAndUpdateTables` stored procedure handles the insertion and updating of clinical study data from XML files.
   ```sql
   CREATE PROCEDURE InsertAndUpdateTables
   AS
   BEGIN
       DECLARE @FilePath NVARCHAR(255);
       DECLARE @FolderPath NVARCHAR(255) = 'J:\DB2-project\COVID-19\\';
       DECLARE @SQL NVARCHAR(MAX);
       DECLARE @StudyID NVARCHAR(50);

       -- Create a temporary table to list files
       CREATE TABLE #Files (FileName NVARCHAR(255));
       CREATE TABLE #NewStudies (StudyID NVARCHAR(50));

       -- Use xp_cmdshell to get the list of files in the folder 
       INSERT INTO #Files (FileName)
       EXEC xp_cmdshell 'dir J:\DB2-project\COVID-19\*.xml /b';

       -- Remove any NULL values from the temporary table
       DELETE FROM #Files WHERE FileName IS NULL;

       -- Iterate over each file and insert its content into the table
       DECLARE @CurrentFile NVARCHAR(255);
       DECLARE FileCursor CURSOR FOR SELECT FileName FROM #Files;
       OPEN FileCursor;

       FETCH NEXT FROM FileCursor INTO @CurrentFile;
       WHILE @@FETCH_STATUS = 0
       BEGIN
            SET @FileName = LEFT(@CurrentFile, LEN(@CurrentFile) - 4); -- To get filename we remove '.xml' 
            SET @FilePath = @FolderPath + @CurrentFile;
            -- Check if the file name 'StudyID' already exists
            IF NOT EXISTS (SELECT 1 FROM ClinicalStudies WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') = @FileName)
            BEGIN
                -- Insert the XML file into the table if it does not already exist
                SET @SQL = '
                    INSERT INTO ClinicalStudies (StudyXML)
                    SELECT CAST(BULK_ROW AS XML)
                    FROM OPENROWSET(
                        BULK ''' + @FilePath + ''',
                        SINGLE_CLOB
                    ) AS XMLDATA(BULK_ROW);';
                EXEC sp_executesql @SQL;

                -- Insert the new StudyIDs into the temporary table
                INSERT INTO #NewStudies (StudyID)
                VALUES (@FileName);
            END
            FETCH NEXT FROM FileCursor INTO @CurrentFile;
        END;

        CLOSE FileCursor;
        DEALLOCATE FileCursor;

        -- Drop the temporary table for files
        DROP TABLE #Files;

       -- Update the derived tables

       -- Insert data into the derived tables
       INSERT INTO Studies (StudyID, OrgStudyID, BriefTitle, OfficialTitle, Status, StudyType, StartDate, CompletionDate, PrimaryCompletionDate)
       SELECT 
           StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
           StudyXML.value('(//org_study_id)[1]', 'NVARCHAR(50)') AS OrgStudyID,
           StudyXML.value('(//brief_title)[1]', 'NVARCHAR(500)') AS BriefTitle,
           StudyXML.value('(//official_title)[1]', 'NVARCHAR(1000)') AS OfficialTitle,
           StudyXML.value('(//overall_status)[1]', 'NVARCHAR(50)') AS Status,
           StudyXML.value('(//study_type)[1]', 'NVARCHAR(50)') AS StudyType,
           TRY_CAST(StudyXML.value('(//start_date)[1]', 'NVARCHAR(50)') AS DATE) AS StartDate,
           TRY_CAST(StudyXML.value('(//completion_date)[1]', 'NVARCHAR(50)') AS DATE) AS CompletionDate,
           TRY_CAST(StudyXML.value('(//primary_completion_date)[1]', 'NVARCHAR(50)') AS DATE) AS PrimaryCompletionDate
       FROM ClinicalStudies;
       WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') IN (SELECT StudyID FROM #NewStudies);

       INSERT INTO Sponsors (StudyID, Agency, AgencyClass)
       SELECT
           StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
           sponsor.value('(agency)[1]', 'NVARCHAR(255)') AS Agency,
           sponsor.value('(agency_class)[1]', 'NVARCHAR(50)') AS AgencyClass
       FROM ClinicalStudies
       CROSS APPLY StudyXML.nodes('//sponsors/lead_sponsor') AS S(sponsor);
       WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') IN (SELECT StudyID FROM #NewStudies);

       INSERT INTO Conditions (StudyID, Condition)
       SELECT
           StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
           condition.value('.', 'NVARCHAR(255)') AS Condition
       FROM ClinicalStudies
       CROSS APPLY StudyXML.nodes('//condition') AS C(condition);
       WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') IN (SELECT StudyID FROM #NewStudies);

       INSERT INTO Eligibility (StudyID, Gender, MinimumAge, MaximumAge, HealthyVolunteers, CriteriaText)
       SELECT
           StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
           StudyXML.value('(//eligibility/gender)[1]', 'NVARCHAR(10)') AS Gender,
           StudyXML.value('(//eligibility/minimum_age)[1]', 'NVARCHAR(20)') AS MinimumAge,
           StudyXML.value('(//eligibility/maximum_age)[1]', 'NVARCHAR(20)') AS MaximumAge,
           StudyXML.value('(//eligibility/healthy_volunteers)[1]', 'NVARCHAR(50)') AS HealthyVolunteers,
           StudyXML.value('(//eligibility/criteria/textblock)[1]', 'NVARCHAR(MAX)') AS CriteriaText
       FROM ClinicalStudies;
       WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') IN (SELECT StudyID FROM #NewStudies);

       -- Extract contact information
       INSERT INTO Contacts (StudyID, LastName, Phone, Email)
       SELECT
           StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
           overall_contact.value('(last_name)[1]', 'NVARCHAR(255)') AS LastName,
           overall_contact.value('(phone)[1]', 'NVARCHAR(20)') AS Phone,
           overall_contact.value('(email)[1]', 'NVARCHAR(255)') AS Email
       FROM ClinicalStudies
       CROSS APPLY StudyXML.nodes('//overall_contact') AS OC(overall_contact);
       WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') IN (SELECT StudyID FROM #NewStudies);

       -- Insert contact information from location/contact node 
       INSERT INTO Contacts (StudyID, LastName, Phone, Email)
       SELECT
           StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
           location_contact.value('(last_name)[1]', 'NVARCHAR(255)') AS LastName,
           location_contact.value('(phone)[1]', 'NVARCHAR(20)') AS Phone,
           location_contact.value('(email)[1]', 'NVARCHAR(255)') AS Email
       FROM ClinicalStudies
       CROSS APPLY StudyXML.nodes('//location/contact') AS LC(location_contact);
       WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') IN (SELECT StudyID FROM #NewStudies);

       INSERT INTO Locations (StudyID, FacilityName, City, State, Country, Status)
       SELECT
           StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
           location.value('(facility/name)[1]', 'NVARCHAR(255)') AS FacilityName,
           location.value('(facility/address/city)[1]', 'NVARCHAR(100)') AS City,
           location.value('(facility/address/state)[1]', 'NVARCHAR(100)') AS State,
           location.value('(facility/address/country)[1]', 'NVARCHAR(100)') AS Country,
           location.value('(status)[1]', 'NVARCHAR(50)') AS Status
       FROM ClinicalStudies
       CROSS APPLY StudyXML.nodes('//location') AS L(location);
       WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') IN (SELECT StudyID FROM #NewStudies);

       
       -- Drop the temporary table for new studies
       DROP TABLE #NewStudies;

   END;
   GO
   ```

### Step 2: Execute the stored procedure
   ```sql
   EXEC InsertAndUpdateTables;
   ```

### Step 3: Drop the stored procedure
   ```sql
   DROP PROCEDURE InsertAndUpdateTables;
   ```

This solution automates the process of inserting and updating clinical study data from multiple XML files into the relational database.

---


<h2 id="step-12" style="text-align: center;">Step 12: Backup Job Configuration and Management</h2>

**The Problem:**
To ensure the integrity and availability of the `DB2_covid_studies` database, it is essential to configure and manage regular backup jobs. This includes creating, scheduling, enabling, disabling, deleting, and verifying backup jobs. The challenge is to ensure that these operations are performed efficiently and without conflicts.

**The Solution:**
The `12_backup_job_management` file provides an SQL script that performs the following operations to address the problem:

1. **Use the msdb Database:**
   The SQL Server Agent uses the `msdb` database for scheduling and job management.

   ```sql
   USE msdb;
   GO
   ```

2. **Create a New Job:**
   Create a job named 'Backup Complete DB2_covid_studies' to perform the backup operation.

   ```sql
   -- Create a new job named 'Backup Complete DB2_covid_studies'
   EXEC dbo.sp_add_job
       @job_name = N'Backup Complete DB2_covid_studies';
   GO
   ```

3. **Add a New Step to the Job:**
   Add a step to the job that performs the actual backup operation.

   ```sql
   -- Add a new step to the job which performs the backup operation
   EXEC sp_add_jobstep
       @job_name = N'Backup Complete DB2_covid_studies',
       @step_name = N'Execute Backup',
       @subsystem = N'TSQL', -- the step is a T-SQL script
       @command = N'BACKUP DATABASE [DB2_covid_studies] TO DISK = ''J:\Backups\DB2_covid_studies_'' + CONVERT(NVARCHAR, GETDATE(), 112) + ''.bak'' WITH FORMAT, MEDIANAME = ''SQLServerBackups'', NAME = ''Full Backup of DB2_covid_studies'';',
       @retry_attempts = 0, -- Number of retry attempts if the step fails
       @retry_interval = 1; -- Interval between retry attempts in minutes
   GO
   ```

4. **Create a Schedule for the Job:**
   Schedule the job to run daily at 2:00 AM.

   ```sql
   -- Create a schedule named 'Backup Daily' to run the job daily at 2 AM
   EXEC sp_add_schedule
       @schedule_name = N'Backup Daily',
       @freq_type = 4,  -- 4 Specifies a daily schedule -- ex. 8 is weekly -- 16 is monthly
       @freq_interval = 1, -- Frequency interval of 1 day
       @active_start_time = 020000;  -- Start time in HHMMSS format -- 02:00:00 AM
   GO
   ```

5. **Attach the Schedule to the Job:**
   Attach the 'Backup Daily' schedule to the job.

   ```sql
   -- Attach the schedule 'Backup Daily' to the job 'Backup Complete DB2_covid_studies'
   EXEC sp_attach_schedule
       @job_name = N'Backup Complete DB2_covid_studies',
       @schedule_name = N'Backup Daily';
   GO
   ```

6. **Add the Job to the Local Server:**
   Add the job to the SQL Server Agent on the local server.

   ```sql
   -- Add the job to the SQL Server Agent on the local server
   EXEC sp_add_jobserver
       @job_name = N'Backup Complete DB2_covid_studies',
       @server_name = N'(local)';
   GO
   ```

7. **Disable the Job:**
   Disable the job if necessary.

   ```sql
   -- Disable the job named 'Backup Complete DB2_covid_studies'
   EXEC sp_update_job
       @job_name = N'Backup Complete DB2_covid_studies',
       @enabled = 0;  -- 0 means disabled
   GO
   ```

8. **Enable the Job:**
   Re-enable the job when needed.

   ```sql
   -- Enable the job named 'Backup Complete DB2_covid_studies'
   EXEC sp_update_job
       @job_name = N'Backup Complete DB2_covid_studies',
       @enabled = 1;  -- 1 means enabled
   GO
   ```

9. **Delete the Existing Job:**
   Remove the job if it is no longer required.

   ```sql
   -- Delete the existing job
   EXEC sp_delete_job
       @job_name = N'Backup Complete DB2_covid_studies';
   GO
   ```

10. **Verify Active Backup Jobs:**
    Check the status of active backup jobs.

    ```sql
    -- Verify active Backup jobs
    SELECT
        name AS JobName,
        enabled AS IsEnabled
    FROM
        sysjobs
    WHERE
        name LIKE '%Backup%' AND
        enabled = 1;
    GO
    ```



