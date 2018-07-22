/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[SpmProduct_Insert]
    @ProductId INT OUTPUT
    ,@Name VARCHAR(100)
    ,@TagIds NVARCHAR(MAX) = NULL
    ,@IsActive BIT = 0
    ,@Description NVARCHAR(200) = NULL
    ,@CreatedBy INT

    ,@ErrCode INT = 0 OUTPUT
    ,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20150407@Tim.Trinh
Task: Insert new Product. 
DB: SPM
Original: 

Revisions:  
Param's Explanation:
@TagIds: '1,2'
*/
BEGIN
    SET NOCOUNT ON;
	DECLARE @Data NVARCHAR(MAX)
	DECLARE @ObjectTypeId INT = 6

    IF EXISTS (
	   SELECT 1
	   FROM [dbo].[SpmProduct] WITH (NOLOCK)
	   WHERE [Name] = @Name AND IsDeleted = 0)
	   BEGIN
		  SELECT @ErrCode = 100,
			 @ErrMsg = 'Product ''' + @Name + ''' has already existed.'
	   RETURN
    END

    SET XACT_ABORT ON
    BEGIN TRAN
    BEGIN TRY
        -- insert product
	   INSERT INTO [dbo].[SpmProduct]
		  ([Name]
		  ,[Description]
		  ,[IsActive]
		  ,[ModifiedBy]
		  ,[ModifiedDate])
	   VALUES
		  (@Name
		  ,@Description
		  ,@IsActive
		  ,@CreatedBy
		  ,GETDATE())

	   SELECT @ProductId = CAST(SCOPE_IDENTITY() AS INT)

	   -- insert tag detail
        EXEC [dbo].[SpmTag_InsertDetail] @ProductId, @TagIds, @ObjectTypeId

		EXEC @Data = [dbo].[fncGetDataForWriteLog] @ObjectId = @ProductId, @ObjectType = @ObjectTypeId
		EXEC dbo.SpmLog_Insert @UserId = @CreatedBy, @SpName = 'SpmProduct_Insert', @ObjectId = @ProductId, @ObjectTypeId = @ObjectTypeId, @Data = @Data, @OldData = NULL
		COMMIT
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK
            SELECT @ErrCode = 100
                ,@ErrMsg = 'There is an error when inserting product.'
        END
    END CATCH
END
GO


