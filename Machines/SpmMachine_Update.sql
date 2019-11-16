/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[SpmMachine_Update]	
	@MachineId INT
	,@Name VARCHAR(50)
	,@IpAddresses NVARCHAR(500)
	,@EnvironmentIds VARCHAR(50)
	,@IsActive BIT=0
	,@Description NVARCHAR(200)=NULL
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
	@IpAddresses: '192.168.1.1,192.168.1.2'
	@EnvironmentIds: '1,2'
*/
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE @Data NVARCHAR(MAX), @OldData NVARCHAR(MAX)

	IF EXISTS( 
		SELECT 1 
		FROM [dbo].[SpmMachine] WITH (NOLOCK)
		WHERE [MachineId] <> @MachineId 
			AND [Name] = @Name AND IsDeleted = 0)
		
	BEGIN
		SELECT @ErrCode = 100
			,@ErrMsg = 'Machine ''' + @Name + ''' has already existed. Please try again.'
		RETURN
	END		

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

	EXEC @OldData = [dbo].[fncGetDataForWriteLog] @ObjectId = @MachineId, @ObjectType = 1

	SET XACT_ABORT ON
	BEGIN TRAN
	BEGIN TRY
		UPDATE [dbo].[SpmMachine] WITH(ROWLOCK,UPDLOCK)
		SET [Name] = @Name
			,[Description] = @Description
			,[IsActive] = @IsActive
			,[ModifiedBy] = @ModifiedBy
			,[ModifiedDate] = GETDATE()
		WHERE [MachineId] = @MachineId
	
		CREATE TABLE #Environment (EnvironmentId  SMALLINT)

		IF ISNULL(@EnvironmentIds,'')<>''
		BEGIN
			INSERT INTO #Environment (EnvironmentId)
			SELECT DISTINCT val 
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

		DELETE mev 
		FROM [dbo].[SpmMachineEnvironment] AS mev
		WHERE MachineId = @MachineId 
			AND NOT EXISTS(SELECT 1 FROM #Environment WHERE EnvironmentId = mev.EnvironmentId)
		
		INSERT INTO [dbo].[SpmMachineEnvironment]
			([MachineId]
			,[EnvironmentId])
		SELECT 
			@MachineId
			,envi.[EnvironmentId]
		FROM #Environment AS envi	
		WHERE NOT EXISTS(
			SELECT 1 FROM [dbo].[SpmMachineEnvironment] WITH (NOLOCK)
			WHERE [MachineId] = @MachineId AND [EnvironmentId] = envi.[EnvironmentId])
	
		DELETE mip 
		FROM [dbo].[SpmMachineIPAddress] AS mip 
		WHERE [MachineId] = @MachineId
		AND NOT EXISTS(SELECT 1 FROM #IPAddress WHERE [IPAddress] = mip.[IPAddress])

		INSERT INTO [dbo].[SpmMachineIPAddress]
			([MachineId]
			,[IPAddress])
		SELECT 
			ipAdd.[MachineId]
			,ipAdd.[IPAddress]
		FROM #IPAddress AS ipAdd	
		WHERE NOT EXISTS(
			SELECT 1
			FROM [dbo].[SpmMachineIPAddress] WITH (NOLOCK)
			WHERE [MachineId] = @MachineId AND [IPAddress] = ipAdd.[IPAddress])

		EXEC @Data = [dbo].[fncGetDataForWriteLog] @ObjectId = @MachineId, @ObjectType = 1
		EXEC dbo.SpmLog_Insert @UserId = @ModifiedBy, @SpName = 'SpmMachine_Update', @ObjectId = @MachineId, @ObjectTypeId = 1, @Data = @Data, @OldData = @OldData

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

