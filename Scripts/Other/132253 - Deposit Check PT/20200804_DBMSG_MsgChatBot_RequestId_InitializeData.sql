/*<info serverAlias="DBMSG-bodb_Message"></info>*/

/*
	Created: 20200804@Percy
	DB: DBMSG.bodb_Message
	Task: Initialize data for new column RequestId
	
	Revisions:
	20240701@Larry: test 
*/

USE bodb_Message
GO

INSERT INTO dbo.MsgChatBot (MessageId, TargetId, JobIdentify, Environment, IsFinished, RequestId)
SELECT DISTINCT vh.MessageId, 0, 2, 'Production', 1, vh.RequestId
FROM DBACC.bodb02.dbo.TicketVoiding_VoidingHistory vh WITH (NOLOCK)
	INNER JOIN DBACC.bodb02.dbo.TicketVoiding_Request r WITH (NOLOCK) ON vh.RequestId = r.RequestId AND r.IssueTypeId = 11 -- abnormal bets
WHERE vh.CreatedDate >= GETDATE() - 1
	AND vh.StatusId = 2 -- tickets void successfully
GO