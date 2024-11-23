USE DB2_covid_studies;
GO

-- Create the log table if not already created
IF OBJECT_ID('dbo.Studies_Log', 'U') IS NOT NULL
    DROP TABLE dbo.Studies_Log;

CREATE TABLE Studies_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    StudyID NVARCHAR(50),
    ActionType VARCHAR(10),
    InsertedAt DATETIME DEFAULT GETDATE()
);
GO

-- Drop the existing trigger for INSERT if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterInsert_Studies')
BEGIN
    DROP TRIGGER trg_AfterInsert_Studies;
END;
GO
-- Trigger AFTER INSERT on Studies
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

-- Drop the existing trigger for DELETE if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterDelete_Studies')
BEGIN
    DROP TRIGGER trg_AfterDelete_Studies;
END;

GO
-- Trigger AFTER DELETE on Studies
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

-- Drop the existing trigger for UPDATE if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_AfterUpdate_Studies')
BEGIN
    DROP TRIGGER trg_AfterUpdate_Studies;
END;

GO
-- Trigger AFTER UPDATE on Studies
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

-- Test Triggers
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

-- View the log
SELECT * FROM Studies_Log;
