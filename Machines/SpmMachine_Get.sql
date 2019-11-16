/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[SpmMachine_Get]
	@EnvironmentIds VARCHAR(300)=NULL,
	@IsActive BIT=0 
AS
/*
Created: 20150318@Josh.Phan
Task: Get machine info from SPM.
DB: SPM
Original: 

Revisions:  
	-20191116@Larry: test
Param's Explanation:

*/
BEGIN
	SET NOCOUNT ON;	

	CREATE TABLE #Environment (
		EnvironmentId  SMALLINT)

	IF ISNULL(@EnvironmentIds,'')<>''
	BEGIN
		INSERT INTO #Environment (
			EnvironmentId )
		SELECT DISTINCT val FROM fnc_strSplit (@EnvironmentIds, ',')
	END	
	
	SELECT 
		 ma.[MachineId]
		,ma.[Name] AS MachineName
		,maAdd.[IPAddress]
		,ma.[Description]
		,ma.[IsActive]
		,ma.[ModifiedBy]
		,ma.[ModifiedDate]
		,maEn.[EnvironmentId]
		,env.[Name]
	FROM [dbo].[SpmMachine] AS ma WITH (NOLOCK)
		INNER JOIN [dbo].[SpmMachineIPAddress] AS maAdd  WITH (NOLOCK) 
			ON ma.[MachineId] = maAdd.[MachineId]
		INNER JOIN [dbo].[SpmMachineEnvironment] AS maEn WITH (NOLOCK)
			ON ma.[MachineId] = maEn.[MachineId]
		INNER JOIN dbo.LookupData AS env WITH (NOLOCK) ON env.LookupId = 1 AND env.Value = maEn.EnvironmentId
	WHERE ( ISNULL(@EnvironmentIds,'') = '' OR 
			 ma.[MachineId] IN (
			     SELECT DISTINCT maEnTemp.[MachineId] 
				FROM [dbo].[SpmMachineEnvironment] AS maEnTemp WITH (NOLOCK)
				INNER JOIN #Environment AS enviTemp 
				    ON maEnTemp.[EnvironmentId] = enviTemp.[EnvironmentId])
		  ) 
		  AND ( @IsActive IS NULL OR ma.[IsActive] = @IsActive)
		  AND ma.[IsDeleted] = 0
	ORDER BY ma.[Name]
	
	SELECT DISTINCT
		 dbSer.[MachineId]
		,dbSer.[DbServerId]
		,dbSer.[Name] AS DbServerName
	FROM [dbo].[SpmMachine] AS ma WITH (NOLOCK)
		INNER JOIN [dbo].[SpmDbServer] AS dbSer WITH (NOLOCK) 
			ON ma.[MachineId] = dbSer.[MachineId] 
	WHERE (ISNULL(@EnvironmentIds,'') = '' OR 
			ma.[MachineId] IN (
				SELECT DISTINCT maEnTemp.[MachineId] 
				FROM [dbo].[SpmMachineEnvironment] AS maEnTemp WITH (NOLOCK)
				INNER JOIN #Environment AS enviTemp 
				    ON maEnTemp.[EnvironmentId] = enviTemp.[EnvironmentId])
		) 
		AND (@IsActive IS NULL OR ma.[IsActive] = @IsActive)
		AND ma.[IsDeleted] = 0		
END

