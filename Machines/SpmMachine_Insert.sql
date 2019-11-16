/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[SpmMachine_Insert]	
	@MachineId INT=NULL OUTPUT
	,@Name VARCHAR(50)
	,@IpAddresses NVARCHAR(500)
	,@EnvironmentIds VARCHAR(50)
	,@IsActive BIT=0
	,@Description NVARCHAR(200)=NULL
	,@CreatedDate DATETIME=NULL
	,@CreatedBy INT=NULL
	
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20150318@Josh.Phan
Task: Insert new Machine. 
DB: SPM
Original: 

Revisions:  
	-20191116@Larry: test
Param's Explanation:
	@IpAddresses: '192.168.1.1,192.168.1.2'
	@EnvironmentIds: '1,2'
*/
BEGIN
	SET NOCOUNT ON;	
	DECLARE @Data NVARCHAR(MAX)

	IF EXISTS( 
		SELECT TOP 1 1 
		FROM [dbo].[SpmMachine] WITH (NOLOCK)
		WHERE [Name] = @Name AND IsDeleted = 0)
		
	BEGIN
		SELECT @ErrCode = 100
			,@ErrMsg = 'Machine ''' + @Name + ''' has already existed. Please try again.'
		RETURN
	END		
	
	SET XACT_ABORT ON
	BEGIN TRAN
	BEGIN TRY	
		INSERT INTO [dbo].[SpmMachine]
			([Name]
			,[Description]
			,[IsActive]
			,[ModifiedBy]
			,[ModifiedDate])
		VALUES (
			@Name
			,@Description
			,@IsActive 
			,@CreatedBy
			,GETDATE())
	
		SELECT @MachineId = CAST(SCOPE_IDENTITY() AS INT)	
		
		CREATE TABLE #Environment (
			MachineId INT 
			,EnvironmentId  SMALLINT)

		IF ISNULL(@EnvironmentIds,'')<>''
		BEGIN
			INSERT INTO #Environment (
				MachineId
				,EnvironmentId )
			SELECT DISTINCT 
				@MachineId
				,val 
			FROM fnc_strSplit (@EnvironmentIds, ',')
		END
	
		CREATE TABLE #IPAddress (
			MachineId INT
			,IPAddress  VARCHAR(50))

		IF ISNULL(@IpAddresses,'')<>''
		BEGIN
			INSERT INTO #IPAddress (
				MachineId
				,IPAddress)
			SELECT DISTINCT 
				@MachineId
				,val 
			FROM fnc_strSplit (@IpAddresses, ',')
		END
	
		INSERT INTO [dbo].[SpmMachineEnvironment]
			([MachineId]
			,[EnvironmentId])
		SELECT 
			[MachineId]
			,[EnvironmentId]
		FROM #Environment
	
		INSERT INTO [dbo].[SpmMachineIPAddress]
			([MachineId]
			,[IPAddress])
		SELECT 
			[MachineId]
			,[IPAddress]
		FROM #IPAddress

		EXEC @Data = [dbo].[fncGetDataForWriteLog] @ObjectId = @MachineId, @ObjectType = 1
		EXEC dbo.SpmLog_Insert @UserId = @CreatedBy, @SpName = 'SpmMachine_Insert', @ObjectId = @MachineId, @ObjectTypeId = 1, @Data = @Data, @OldData = NULL

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

