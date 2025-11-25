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
CREATE FUNCTION analytics.Calculate-Score-11()
RETURNS INT
AS
BEGIN
    RETURN 11;
END
GO