/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[SpmProduct_Delete]	
	@ProductId INT
	,@ModifiedBy INT = NULL
	
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Original: 

Revisions:  
	- 20180911@Vivian: test
Param's Explanation:
*/
BEGIN
    SET NOCOUNT ON;
	DECLARE @OldData NVARCHAR(MAX)
	DECLARE @ObjectTypeId INT = 6

    IF NOT EXISTS (SELECT 1 
	   FROM [dbo].[SpmProduct] WITH (NOLOCK)
	   WHERE [ProductId] = @ProductId)		
    BEGIN
	   SELECT @ErrCode = 100
		  ,@ErrMsg = 'The Product is not exist.'
	   RETURN
    END

    IF (EXISTS (SELECT 1
		   FROM [dbo].[SpmFunction] AS fnc WITH (NOLOCK)
		   INNER JOIN [dbo].[SpmFunctionSystemProduct] AS sfs WITH(NOLOCK) ON fnc.FunctionId = sfs.FunctionId AND fnc.IsDeleted = 0
		   WHERE [ProductId] = @ProductId)
	   OR 
	   EXISTS (SELECT 1
		   FROM [dbo].[SpmFunction] AS fnc WITH (NOLOCK)
		   INNER JOIN [dbo].[SpmSpFunction] AS sfs WITH(NOLOCK) ON fnc.FunctionId = sfs.FunctionId AND fnc.IsDeleted = 0
		   WHERE [ProductId] = @ProductId)
	   )
    BEGIN
	   SELECT @ErrCode = 100
		  ,@ErrMsg = 'Cannot delete this Product because it is being used.'
	   RETURN
    END

	EXEC @OldData = [dbo].[fncGetDataForWriteLog] @ObjectId = @ProductId, @ObjectType = @ObjectTypeId

    SET XACT_ABORT ON
    BEGIN TRAN
    BEGIN TRY
		IF (EXISTS (SELECT 1
			   FROM [dbo].[SpmFunction] AS fnc WITH (NOLOCK)
			   INNER JOIN [dbo].[SpmFunctionSystemProduct] AS sfs WITH(NOLOCK) ON fnc.FunctionId = sfs.FunctionId AND fnc.IsDeleted = 0
			   WHERE [ProductId] = @ProductId)
		   OR 
		   EXISTS (SELECT 1
			   FROM [dbo].[SpmFunction] AS fnc WITH (NOLOCK)
			   INNER JOIN [dbo].[SpmSpFunction] AS sfs WITH(NOLOCK) ON fnc.FunctionId = sfs.FunctionId AND fnc.IsDeleted = 0
			   WHERE [ProductId] = @ProductId)
		   )
		BEGIN
			UPDATE [dbo].[SpmProduct] WITH (UPDLOCK, ROWLOCK)
			SET IsDeleted = 1,
				ModifiedBy = @ModifiedBy,
				ModifiedDate = GETDATE()
			WHERE ProductId = @ProductId
		END
		ELSE
		BEGIN
			DELETE FROM [dbo].[SpmProduct] WHERE [ProductId] = @ProductId
			DELETE FROM [dbo].[SpmTagDetail] WHERE [ObjectId] = @ProductId AND [Type] = @ObjectTypeId
		END
		EXEC dbo.SpmLog_Insert @UserId = @ModifiedBy, @SpName = 'SpmProduct_Delete', @ObjectId = @ProductId, @ObjectTypeId = @ObjectTypeId, @Data = NULL, @OldData = @OldData
		COMMIT
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
	       ROLLBACK
	       SELECT @ErrCode = 100
		      ,@ErrMsg = 'There is an error when deleting product.'
	   END
    END CATCH  
END
GO


