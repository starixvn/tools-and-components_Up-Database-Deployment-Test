/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[SpmTag_InsertDetail]
    @ObjectId INT
    ,@TagIds NVARCHAR(MAX) = NULL
    ,@Type TINYINT
AS
/*
Created: 20240717@Larry.Tran
Task: Insert stored procedure function.
DB: SPM
Original: 

Revisions: 
    - 20240717@Larry: Changed the way to insert/update SpmTagDetail
Param's Explanation:
    @Type:  5 - System
            6 - Product
            7 - Function
            8 - Stored Procedure
*/
BEGIN
    SET NOCOUNT ON;
    
    CREATE TABLE #Tag (TagId INT)

    IF ISNULL(@TagIds, '') <> ''
    BEGIN
        INSERT INTO #Tag(TagId)
        SELECT DISTINCT val 
        FROM fnc_strSplit (@TagIds, ',')
    END
    
    -- Delete old SpmTagDetail of Object & Type
    DELETE
    FROM [dbo].[SpmTagDetail]
    WHERE [ObjectId] = @ObjectId 
        AND [Type] = @Type
	   
    --Insert new SpmTagDetail    Test by Larry
    INSERT INTO [dbo].[SpmTagDetail]
        ([ObjectId]
        ,[TagId]
        ,[Type])
    SELECT DISTINCT
        @ObjectId
        ,[TagId]
        ,@Type
    FROM #Tag
	    
END