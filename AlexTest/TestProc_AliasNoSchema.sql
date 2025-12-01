/*<info serverAlias="NexOps-Up_DeploymentTest,NexOps-Up_DeploymentLinkedTest"></info>*/
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
CREATE PROC alex-test_TestProc2
AS
BEGIN
    SELECT 'OK2';
END
GO