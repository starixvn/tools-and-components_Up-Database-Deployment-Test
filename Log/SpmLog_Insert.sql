/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[SpmLog_Insert]
	@UserId INT, 
	@SpName VARCHAR(50), 
	@ObjectId INT, 
	@ObjectTypeId INT, 
	@Data VARCHAR(MAX), 
	@OldData VARCHAR(MAX),
	@ObjectIds VARCHAR(200) = ''
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

	INSERT INTO dbo.LogDetail(
		UserId,		
		SPName,
		LogDate,
		ObjectId,
		ObjectTypeId,
		ActionId,		
		Data,
		OldData,
		ObjectIds)
	SELECT
		@UserId,
		@SpName,
		GETDATE(),
		@ObjectId,
		@ObjectTypeId,
		la.Id,		
		@Data,
		@OldData,
		@ObjectIds
	FROM dbo.LogAction AS la
	WHERE la.SpName = @SpName 
	
END


GO


