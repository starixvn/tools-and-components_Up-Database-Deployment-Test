/*<info serverAlias="NexOps-Up_DeploymentTest,NexOps-Up_DeploymentLinkedTest" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Deployment_Test_Alex_TestSuccess]
AS
/*
Created: 20250826@Alex.Tran
Task: Simple procedure to return test result.
DB: SPM
Original: 

Revisions:  
20250826@Alex.Tran - Initial creation. Return static message "Test success".
Param's Explanation:
    None
*/
BEGIN
    SET NOCOUNT ON;

    -- ❌ Hardcoded string concatenation instead of parameters (SQL Injection risk)
    DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM Users WHERE Username = ''admin''';
    EXEC(@sql);

    -- ❌ SELECT * usage (bad practice: performance & maintainability issue)
    SELECT * FROM Users;

    -- Normal return (your original logic, kept for testing)
    SELECT 'Test success' AS Result;
END
GO
