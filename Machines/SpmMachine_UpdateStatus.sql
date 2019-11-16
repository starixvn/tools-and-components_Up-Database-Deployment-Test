/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[SpmMachine_UpdateStatus]	
	@MachineId INT,
	@IsActive BIT=0

	,@ModifiedDate DATETIME=NULL
	,@ModifiedBy INT=NULL
	
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20150318@Josh.Phan
Task: Edit Machine. 
DB: SPM
Original: 

Revisions:  
	-20191116@Larry: test
Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE @Data NVARCHAR(MAX), @OldData NVARCHAR(MAX)

	IF @IsActive = 0 AND EXISTS(SELECT 1
	     FROM [dbo].[SpmDbServer] AS sv WITH (NOLOCK)
	     WHERE sv.MachineId = @MachineId
	        AND sv.[IsDeleted] = 0
			AND sv.IsActive = 1)
	BEGIN
	     SELECT @ErrCode = 100
	           ,@ErrMsg = 'You can not deactivate this Machine because it is being used by one or more DB Server.'
	     RETURN
	END

	EXEC @OldData = [dbo].[fncGetDataForWriteLogStatus] @ObjectId = @MachineId, @ObjectType = 1

	UPDATE [dbo].[SpmMachine] WITH(ROWLOCK,UPDLOCK)
	SET [IsActive] = @IsActive
		,[ModifiedBy] = @ModifiedBy
		,[ModifiedDate] = GETDATE()		
	WHERE [MachineId] = @MachineId	

	EXEC @Data = [dbo].[fncGetDataForWriteLogStatus] @ObjectId = @MachineId, @ObjectType = 1
	EXEC dbo.SpmLog_Insert @UserId = @ModifiedBy, @SpName = 'SpmMachine_UpdateStatus', @ObjectId = @MachineId, @ObjectTypeId = 1, @Data = @Data, @OldData = @OldData
END

