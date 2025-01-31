USE DB2_covid_studies;
GO

-- Create the log table if not already created
IF OBJECT_ID('dbo.ClinicalStudies_Log', 'U') IS NOT NULL
    DROP TABLE dbo.ClinicalStudies_Log;

CREATE TABLE ClinicalStudies_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    AutoIncrementID INT,
    ActionType VARCHAR(10),
    InsertedAt DATETIME DEFAULT GETDATE()
);
GO

-- Drop the existing trigger if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterInsert_ClinicalStudies')
BEGIN
    DROP TRIGGER trg_AfterInsert_ClinicalStudies;
END;
GO
-- Trigger AFTER INSERT on ClinicalStudies
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

-- Drop the existing trigger for DELETE if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterDelete_ClinicalStudies')
BEGIN
    DROP TRIGGER trg_AfterDelete_ClinicalStudies;
END;
GO
-- Trigger AFTER DELETE on ClinicalStudies
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

-- Drop the existing trigger for UPDATE if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterUpdate_ClinicalStudies')
BEGIN
    DROP TRIGGER trg_AfterUpdate_ClinicalStudies;
END;
GO
-- Trigger AFTER UPDATE on ClinicalStudies
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

-- Test Triggers

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

-- View the log
SELECT * FROM ClinicalStudies_Log;
