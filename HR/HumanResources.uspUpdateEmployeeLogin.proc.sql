SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE	HumanResources.uspUpdateEmployeeLogin
						@BusinessEntityID	INT
					,	@OrganizationNode	HIERARCHYID
					,	@LoginID			NVARCHAR(256)
					,	@JobTitle			NVARCHAR(50)
					,	@HireDate			DATETIME
					,	@CurrentFlag		dbo.Flag
WITH EXECUTE AS CALLER
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

	BEGIN TRY
		UPDATE	HumanResources.Employee WITH (ROWLOCK)
		SET	OrganizationNode	= @OrganizationNode 
		,	LoginID				= @LoginID 	
		,	HireDate			= @HireDate 
		,	CurrentFlag			= @CurrentFlag 
		WHERE	BusinessEntityID = @BusinessEntityID;
	END TRY
	BEGIN CATCH
		EXEC dbo.uspLogError;
	END CATCH;
END;
GO
/*<info serverAlias="NexOps-Up_DeploymentTest" executers="" viewers="" isFunction="0" isNested="0"></info>*/