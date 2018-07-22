/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[SpmStoredProcedure_InsertFunction]
	@StoredProcedureId		INT
	,@Functions				NVARCHAR(MAX) = NULL
	,@ModifiedBy			INT = NULL
AS
/*
Created: 20150420@Quinn.Vo
Task: Insert stored procedure function.
DB: SPM
Original: 

Revisions:  
Param's Explanation:
- @Functions: <ROOT>
					<Function FunctionId="1" SystemId="1" ProductId="1"><Function/>
			  </ROOT>
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @DocHandler INT
	IF OBJECT_ID('tempdb..#Functions') IS NOT NULL
	BEGIN
		DROP TABLE #Functions
	END 
	CREATE TABLE #Functions(FunctionId INT, SystemId INT, ProductId INT NULL)

	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @Functions
	INSERT INTO #Functions(SystemId, ProductId, FunctionId)
	SELECT SystemId, ProductId, FunctionId
	FROM OPENXML(@DocHandler, '/ROOT/Function', 1) 
	WITH (SystemId INT, ProductId INT, FunctionId INT) AS Data
	EXEC sp_xml_removedocument @DocHandler

	DELETE spf
	FROM dbo.SpmSpFunction AS spf WITH (NOLOCK)
	LEFT JOIN #Functions AS fn ON spf.FunctionId = fn.FunctionId 
		AND fn.SystemId = spf.SystemId
		AND fn.ProductId = spf.ProductId
	WHERE spf.StoredProcedureId = @StoredProcedureId
	AND fn.FunctionId IS NULL

	DELETE fn
	FROM dbo.SpmSpFunction AS spf WITH (NOLOCK)
	INNER JOIN #Functions AS fn ON spf.FunctionId = fn.FunctionId 
		AND fn.SystemId = spf.SystemId
		AND fn.ProductId = spf.ProductId
		AND spf.StoredProcedureId = @StoredProcedureId

	INSERT INTO dbo.SpmSpFunction(StoredProcedureId, FunctionId, SystemId, ProductId, ModifiedBy, ModifiedDate)
	SELECT @StoredProcedureId, fn.FunctionId, fn.SystemId, CASE WHEN ISNULL(fn.ProductId, 0) = 0 THEN -1 ELSE fn.ProductId END, @ModifiedBy, GETDATE()
	FROM #Functions AS fn

	DROP TABLE #Functions
END

GO


