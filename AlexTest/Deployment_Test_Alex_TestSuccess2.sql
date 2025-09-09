/*<info serverAlias="NexOps-Up_DeploymentTest" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Deployment_Test_Alex_TestSuccess2]
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

    SELECT 'Test success 2' AS Result;
END
GO
