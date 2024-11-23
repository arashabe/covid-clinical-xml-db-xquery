--Switch to the target database
USE DB2_covid_studies;
GO

--Create the stored procedure

CREATE PROCEDURE InsertAndUpdateTables
AS
BEGIN
    DECLARE @FilePath NVARCHAR(255);
    DECLARE @FolderPath NVARCHAR(255) = 'J:\DB2-project\COVID-19\\';
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @StudyID NVARCHAR(50);

    -- Create a temporary table to list files
    CREATE TABLE #Files (FileName NVARCHAR(255));

    -- Use xp_cmdshell to get the list of files in the folder (ensure xp_cmdshell is enabled)
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
        SET @FilePath = @FolderPath + @CurrentFile;
        
        -- Extract StudyID from the XML file
        SET @SQL = '
            SELECT @StudyID_OUT = StudyXML.value(''(//nct_id)[1]'', ''NVARCHAR(50)'')
            FROM OPENROWSET(
                BULK ''' + @FilePath + ''',
                SINGLE_CLOB
            ) AS XMLDATA(StudyXML)';
        
        DECLARE @StudyID_OUT NVARCHAR(50);
        EXEC sp_executesql @SQL, N'@StudyID_OUT NVARCHAR(50) OUTPUT', @StudyID_OUT OUTPUT;

        -- Check if the StudyID already exists
        IF NOT EXISTS (SELECT 1 FROM ClinicalStudies WHERE StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') = @StudyID_OUT)
        BEGIN
            -- Insert the XML file into the table if it does not already exist
            SET @SQL = '
                INSERT INTO ClinicalStudies (StudyXML)
                SELECT CAST(BULK_COLUMN AS XML)
                FROM OPENROWSET(
                    BULK ''' + @FilePath + ''',
                    SINGLE_CLOB
                ) AS XMLDATA(BULK_COLUMN);
            ';
            EXEC sp_executesql @SQL;
        END
        
        FETCH NEXT FROM FileCursor INTO @CurrentFile;
    END;

    CLOSE FileCursor;
    DEALLOCATE FileCursor;

    -- Drop the temporary table
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

    INSERT INTO Sponsors (StudyID, Agency, AgencyClass)
    SELECT
        StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
        sponsor.value('(agency)[1]', 'NVARCHAR(255)') AS Agency,
        sponsor.value('(agency_class)[1]', 'NVARCHAR(50)') AS AgencyClass
    FROM ClinicalStudies
    CROSS APPLY StudyXML.nodes('//sponsors/lead_sponsor') AS S(sponsor);

    INSERT INTO Conditions (StudyID, Condition)
    SELECT
        StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
        condition.value('.', 'NVARCHAR(255)') AS Condition
    FROM ClinicalStudies
    CROSS APPLY StudyXML.nodes('//condition') AS C(condition);

    INSERT INTO Eligibility (StudyID, Gender, MinimumAge, MaximumAge, HealthyVolunteers, CriteriaText)
    SELECT
        StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
        StudyXML.value('(//eligibility/gender)[1]', 'NVARCHAR(10)') AS Gender,
        StudyXML.value('(//eligibility/minimum_age)[1]', 'NVARCHAR(20)') AS MinimumAge,
        StudyXML.value('(//eligibility/maximum_age)[1]', 'NVARCHAR(20)') AS MaximumAge,
        StudyXML.value('(//eligibility/healthy_volunteers)[1]', 'NVARCHAR(50)') AS HealthyVolunteers,
        StudyXML.value('(//eligibility/criteria/textblock)[1]', 'NVARCHAR(MAX)') AS CriteriaText
    FROM ClinicalStudies;

    -- Extract contact information
    INSERT INTO Contacts (StudyID, LastName, Phone, Email)
    SELECT
        StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
        overall_contact.value('(last_name)[1]', 'NVARCHAR(255)') AS LastName,
        overall_contact.value('(phone)[1]', 'NVARCHAR(20)') AS Phone,
        overall_contact.value('(email)[1]', 'NVARCHAR(255)') AS Email
    FROM ClinicalStudies
    CROSS APPLY StudyXML.nodes('//overall_contact') AS OC(overall_contact);

    -- Insert contact information from location/contact node 
    INSERT INTO Contacts (StudyID, LastName, Phone, Email)
    SELECT
        StudyXML.value('(//nct_id)[1]', 'NVARCHAR(50)') AS StudyID,
        location_contact.value('(last_name)[1]', 'NVARCHAR(255)') AS LastName,
        location_contact.value('(phone)[1]', 'NVARCHAR(20)') AS Phone,
        location_contact.value('(email)[1]', 'NVARCHAR(255)') AS Email
    FROM ClinicalStudies
    CROSS APPLY StudyXML.nodes('//location/contact') AS LC(location_contact);

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

END;
GO

-------------------Step 2: Execute the stored procedure-------------------------
--EXEC InsertAndUpdateTables;


----------------------Drop the stored procedure!-------------------------------
--DROP PROCEDURE InsertAndUpdateTables;
