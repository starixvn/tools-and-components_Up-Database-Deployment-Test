/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[SpmProduct_Get]
    @SystemId INT = NULL
    ,@FunctionId INT = NULL
    ,@IsActive BIT = NULL
AS
/*
Created: 20150420@Quinn.Vo
Task: Insert stored procedure function.
DB: SPM
Original: 

Revisions:  
	- 20180911@Vivian: test
Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT pro.[ProductId]
		,pro.[Name]
		,pro.[Description]
		,pro.[IsActive]
	FROM [dbo].[SpmProduct] AS pro WITH(NOLOCK)
	LEFT JOIN [dbo].[SpmFunctionSystemProduct] AS sfs WITH (NOLOCK) ON pro.ProductId = sfs.ProductId	
	WHERE pro.IsDeleted = 0
	   AND (@IsActive IS NULL OR pro.[IsActive] = @IsActive)
	   AND (@SystemId IS NULL OR sfs.[SystemId] = @SystemId)
	   AND (@FunctionId IS NULL OR sfs.FunctionId = @FunctionId)
	ORDER BY pro.[Name]
	
	SELECT DISTINCT pro.[ProductId]
		,tag.[TagId]
		,tag.[Name]
	FROM [dbo].[SpmProduct] AS pro WITH(NOLOCK)
	LEFT JOIN [dbo].[SpmFunctionSystemProduct] AS sfs WITH (NOLOCK) ON pro.ProductId = sfs.ProductId	
	INNER JOIN [dbo].[SpmTagDetail] AS td WITH(NOLOCK) 
	   ON pro.[ProductId] = td.[ObjectId] AND td.[Type] = 6 -- product
	INNER JOIN [dbo].[SpmTag] AS tag WITH(NOLOCK) 
	   ON td.[TagId] = tag.[TagId]
	WHERE pro.IsDeleted = 0
		AND (@IsActive IS NULL OR pro.[IsActive] = @IsActive)
		AND (@SystemId IS NULL OR sfs.[SystemId] = @SystemId)
		AND (@FunctionId IS NULL OR sfs.FunctionId = @FunctionId)
	ORDER BY pro.[ProductId], tag.[Name]
END
GO


