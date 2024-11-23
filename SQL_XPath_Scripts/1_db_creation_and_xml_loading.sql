-- 1. Change to master database to avoid being in the target database when dropping it
USE master;

-- 2. If the database exists, disconnect users and drop the database
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DB2_covid_studies')
BEGIN
    ALTER DATABASE DB2_covid_studies SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DB2_covid_studies;
END

-- 3. Create a new database
CREATE DATABASE DB2_covid_studies;

-- 4. Switch to the new database
USE DB2_covid_studies;

-- Enable xp_cmdshell to interact with the OS
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- Table for storing XML data from studies
CREATE TABLE ClinicalStudies (
    StudyID INT IDENTITY PRIMARY KEY,
    StudyXML XML
);

-- Temporary table to hold XML file names
CREATE TABLE #TempFiles (FileName NVARCHAR(4000));

-- Insert XML file names into the temporary table
INSERT INTO #TempFiles (FileName)
EXEC xp_cmdshell 'dir J:\DB2-project\COVID-19\*.xml /b';

-- Verify the file names were inserted
SELECT * FROM #TempFiles;

-- Variables to handle file loading
DECLARE @folderPath NVARCHAR(4000) = 'J:\DB2-project\COVID-19\\';
DECLARE @fileName NVARCHAR(4000);
DECLARE @fullPath NVARCHAR(4000);
DECLARE @sql NVARCHAR(MAX);

-- Cursor to iterate over file names
DECLARE file_cursor CURSOR FOR 
SELECT FileName FROM #TempFiles;

OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @fileName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Construct the full file path
    SET @fullPath = @folderPath + @fileName;

    -- Build dynamic SQL to load the XML file into ClinicalStudies
    SET @sql = 'INSERT INTO ClinicalStudies (StudyXML) 
                 SELECT CAST(BULK_COLUMN AS XML) 
                 FROM OPENROWSET(BULK ''' + @fullPath + ''', SINGLE_BLOB) AS T(BULK_COLUMN);';

    -- Execute the dynamic SQL
    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        PRINT 'Error loading file: ' + @fileName;
        PRINT ERROR_MESSAGE();
    END CATCH;

    -- Move to the next file
    FETCH NEXT FROM file_cursor INTO @fileName;
END

-- Close and deallocate the cursor
CLOSE file_cursor;
DEALLOCATE file_cursor;

-- Drop the temporary table
DROP TABLE #TempFiles;

-- Verify data load
SELECT COUNT(*) AS TotalRecords FROM ClinicalStudies;
