/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[SpmLog_UpdateByUser]
	@UserId INT, 
	@SpName VARCHAR(50), 
	@ObjectId INT, 
	@ObjectTypeId INT, 
	@Data VARCHAR(MAX), 
	@OldData VARCHAR(MAX),
	@ObjectIds VARCHAR(200) = '',
	@ActionId INT
AS
/*
Created: 20251006@Larry
Task: Update log detail.
DB: SPM
Original: 

Revisions:  
- 20251006@Larry: update some text
Param's Explanation:

*/
BEGIN
	SET NOCOUNT ON;
	
	UPDATE [dbo].[LogDetail]
	   SET [SpName] = @SpName
		  ,[LogDate] = GETDATE()
		  ,[ObjectId] = @ObjectId
		  ,[ObjectTypeId] = @ObjectTypeId
		  ,[ActionId] = @ActionId
		  ,[Data] = @Data
		  ,[OldData] = @OldData
		  ,[ObjectIds] = @ObjectIds
	 WHERE UserId = @UserId

END

GO
