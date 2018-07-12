/*<info serverAlias="NexOps-Up_DeploymentTest" executers="bodbAdminNet" viewers="vnteam" isFunction="1" isNested="1"></info>*/
CREATE FUNCTION [dbo].[fncEncodeXmlSpecialCharacter]
(
	@Data VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN	
    DECLARE @EncodedData VARCHAR(MAX)
    DECLARE @XmlDoc XML
    
    SET @XmlDoc = '<root/>'

    SET @XmlDoc.modify('insert text{sql:variable("@Data")} as first into (/root)[1]')

    SET @EncodedData = CAST(@XmlDoc.query('/root/text()') AS VARCHAR(MAX))
   
    RETURN @EncodedData
END


GO


