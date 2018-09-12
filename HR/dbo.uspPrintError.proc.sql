SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
-- uspPrintError prints error information about the error that caused
-- execution to jump to the CATCH block of a TRY...CATCH construct.
-- Should be executed from within the scope of a CATCH block otherwise
-- it will return without printing any error information.
ALTER PROCEDURE	dbo.uspPrintError
AS
/*
Created: 20180911@Vivian
Original: 

Revisions:  
	- 20180911@Vivian: test
Param's Explanation:
*/
BEGIN;
	SET NOCOUNT ON;

	-- Print error information.
	PRINT 'Error ' + CONVERT(VARCHAR(50), ERROR_NUMBER())
		+ ', Severity ' + CONVERT(VARCHAR(5), ERROR_SEVERITY())
		+ ', State ' + CONVERT(VARCHAR(5), ERROR_STATE())
		+ ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-')
		+ ', Line ' + CONVERT(VARCHAR(5), ERROR_LINE())
		;
	PRINT ERROR_MESSAGE();
END;
GO
/*<info serverAlias="NexOps-Up_DeploymentTest" executers="" viewers="" isFunction="0" isNested="1"></info>*/