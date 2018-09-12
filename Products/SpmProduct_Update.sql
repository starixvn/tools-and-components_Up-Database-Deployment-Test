/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam"></info>*/
CREATE PROCEDURE [dbo].[SpmProduct_Update]
    @ProductId INT
    ,@Name VARCHAR(100)
    ,@TagIds NVARCHAR(MAX) = NULL
    ,@IsActive BIT = 0
    ,@Description NVARCHAR(200) = NULL
    ,@ModifiedBy INT = NULL

    ,@ErrCode INT = 0 OUTPUT
    ,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20150408@Tim.Trinh
Task: Update Product. 
DB: SPM
Original: 

Revisions:  
	- 20180912@Vivian: test
Param's Explanation:

*/
BEGIN
    SET NOCOUNT ON;
	DECLARE @Data NVARCHAR(MAX), @OldData NVARCHAR(MAX)
	DECLARE @ObjectTypeId INT = 6

    IF NOT EXISTS (SELECT 1
	   FROM [dbo].[SpmProduct] WITH(NOLOCK)
	   WHERE [ProductId] = @ProductId)
    BEGIN
	   SELECT @ErrCode = 100
		  ,@ErrMsg = 'The Product is not exist.'
	   RETURN
    END

    IF EXISTS (SELECT 1
	   FROM [dbo].[SpmProduct] WITH(NOLOCK)
	   WHERE [ProductId] <> @ProductId
	   AND [Name] = @Name AND IsDeleted = 0)
    BEGIN
	   SELECT @ErrCode = 100
		  ,@ErrMsg = 'Product ''' + @Name + ''' has already existed.'
	   RETURN
    END

	IF @IsActive = 0 AND EXISTS(SELECT 1
	     FROM [dbo].[SpmFunctionSystemProduct] AS fsp WITH (NOLOCK)
		 INNER JOIN [dbo].[SpmFunction] AS fn WITH (NOLOCK) ON fsp.FunctionId = fn.FunctionId
	     WHERE fsp.ProductId = @ProductId
	        AND fn.[IsDeleted] = 0
			AND fn.IsActive = 1)
	BEGIN
	     SELECT @ErrCode = 100
	           ,@ErrMsg = 'You can not deactivate this Product because it is being used by one or more Function.'
	     RETURN
	END

	EXEC @OldData = [dbo].[fncGetDataForWriteLog] @ObjectId = @ProductId, @ObjectType = @ObjectTypeId

    SET XACT_ABORT ON
    BEGIN TRAN
    BEGIN TRY	   
	   -- update product
	   UPDATE [dbo].[SpmProduct] WITH(ROWLOCK,UPDLOCK)
	   SET [Name] = @Name
		  ,[Description] = @Description
		  ,[IsActive] = @IsActive
		  ,[ModifiedBy] = @ModifiedBy
		  ,[ModifiedDate] = GETDATE()
	   WHERE [ProductId] = @ProductId
        
        -- update tag detail
        EXEC [dbo].[SpmTag_InsertDetail] @ProductId, @TagIds, @ObjectTypeId

		EXEC @Data = [dbo].[fncGetDataForWriteLog] @ObjectId = @ProductId, @ObjectType = @ObjectTypeId
		EXEC dbo.SpmLog_Insert @UserId = @ModifiedBy, @SpName = 'SpmProduct_Update', @ObjectId = @ProductId, @ObjectTypeId = @ObjectTypeId, @Data = @Data, @OldData = @OldData
		COMMIT
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK
            SELECT @ErrCode = 100
                ,@ErrMsg = 'There is an error when updating product.'
        END
    END CATCH  
END
GO


