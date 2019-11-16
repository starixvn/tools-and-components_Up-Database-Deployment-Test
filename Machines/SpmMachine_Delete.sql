/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[SpmMachine_Delete]	
	@MachineId INT
	,@ModifiedDate DATETIME=NULL
	,@ModifiedBy INT=NULL
	
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20150318@Josh.Phan
Task: Delete Machine. 
DB: SPM
Original: 

Revisions:  
	-20191116@Larry: test
Param's Explanation:

*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @OldData NVARCHAR(MAX)

	IF EXISTS(
		SELECT TOP 1 1
		FROM [dbo].[SpmDbServer] WITH (NOLOCK)
		WHERE [MachineId] = @MachineId AND IsDeleted = 0)
		
	BEGIN
		 SELECT @ErrCode = 100
		  ,@ErrMsg = 'Cannot delete this Machine because it is being used.'
	   RETURN
	END

	EXEC @OldData = [dbo].[fncGetDataForWriteLog] @ObjectId = @MachineId, @ObjectType = 1

	SET XACT_ABORT ON
    BEGIN TRAN
    BEGIN TRY
		IF EXISTS(SELECT TOP 1 1
			FROM [dbo].[SpmDbServer] WITH (NOLOCK)
			WHERE [MachineId] = @MachineId AND IsDeleted = 1)
		BEGIN
			UPDATE [dbo].[SpmMachine] WITH (UPDLOCK, ROWLOCK)
			SET IsDeleted = 1,
				ModifiedBy = @ModifiedBy,
				ModifiedDate = GETDATE()
			WHERE [MachineId] = @MachineId	
		END
		ELSE
		BEGIN
			DELETE FROM [dbo].[SpmMachine] WHERE [MachineId] = @MachineId		 
			DELETE FROM [dbo].[SpmMachineEnvironment] WHERE [MachineId] = @MachineId
			DELETE FROM [dbo].[SpmMachineIPAddress] WHERE [MachineId] = @MachineId
		END

		EXEC dbo.SpmLog_Insert @UserId = @ModifiedBy, @SpName = 'SpmMachine_Delete', @ObjectId = @MachineId, @ObjectTypeId = 1, @Data = NULL, @OldData = @OldData

		COMMIT
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
	       ROLLBACK
	       SELECT @ErrCode = 100
		      ,@ErrMsg = ERROR_MESSAGE()
	   END
    END CATCH
END

