/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="1" isNested="1"></info>*/
CREATE FUNCTION [dbo].[fncGetDataForWriteLogStatus]
(
	@ObjectId INT,
	@ObjectType INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Data NVARCHAR(MAX)

	IF(@ObjectType = 1)
	BEGIN
		SELECT @Data = CONCAT('<r><n>', mc.Name, '</n><a>', mc.IsActive,'</a></r>')
		FROM dbo.SpmMachine AS mc WITH (NOLOCK)
		WHERE [MachineId] = @ObjectId
	END
	ELSE IF(@ObjectType = 2)
	BEGIN
		SELECT @Data = CONCAT('<r><n>', sv.Name,'</n><a>', sv.IsActive,'</a></r>')
		FROM [dbo].[SpmDbServer] AS sv WITH (NOLOCK)
		WHERE [DbServerId] = @ObjectId
	END
	ELSE IF(@ObjectType = 3)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].[SpmDatabase] WITH (NOLOCK)
		WHERE DatabaseId = @ObjectId
	END
	ELSE IF(@ObjectType = 4)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].[SpmAliasServer] WITH (NOLOCK)
		WHERE AliasServerId = @ObjectId
	END
	ELSE IF(@ObjectType = 5)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].[SpmSystem] WITH (NOLOCK)
		WHERE SystemId = @ObjectId
	END
	ELSE IF(@ObjectType = 6)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].[SpmProduct] WITH (NOLOCK)
		WHERE ProductId = @ObjectId
	END
	ELSE IF(@ObjectType = 7)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].[SpmFunction] WITH (NOLOCK)
		WHERE FunctionId = @ObjectId
	END
	ELSE IF(@ObjectType = 8)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].[SpmStoredProcedure] WITH (NOLOCK)
		WHERE StoredProcedureId = @ObjectId
	END
	ELSE IF(@ObjectType = 9)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].[SpmTag] WITH (NOLOCK)
		WHERE TagId = @ObjectId
	END
	ELSE IF(@ObjectType = 11)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].[SpmFunctionGroup] WITH (NOLOCK)
		WHERE FunctionGroupId = @ObjectId
	END
     ELSE IF(@ObjectType = 12)
	BEGIN
		SELECT @Data = '<r><n>'+ Name + '</n>'+  '<a>' + CAST(IsActive AS VARCHAR(10)) + '</a></r>'
		FROM [dbo].SpmSystemGroup WITH (NOLOCK)
		WHERE GroupId = @ObjectId
	END
	RETURN @Data
END


GO


