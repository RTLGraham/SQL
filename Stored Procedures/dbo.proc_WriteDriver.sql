SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteDriver] 
	@did UNIQUEIDENTIFIER, @dintid INT = NULL OUTPUT, @customerid UNIQUEIDENTIFIER, @drivernumber varchar(32), @drivername varchar(50)
AS	
	INSERT INTO Driver (DriverId, Number, Surname)
	VALUES (@did, @drivernumber, @drivername)
	SET @dintid = SCOPE_IDENTITY()

	INSERT INTO CustomerDriver (CustomerId, DriverId, StartDate, EndDate)
	VALUES (@customerid, @did, GETDATE(), NULL)

	/* Create Driver Chatroom if doesn't already exist */
	DECLARE @chatid INT
	INSERT INTO dbo.MSG_Chatroom
		    (OwnerId,
		        ChatroomName,
		        Archived,
		        LastModified
		    )
	SELECT @did, 'Chatroom for ' + @drivername, 0, GETDATE()
	WHERE NOT EXISTS (SELECT 1 FROM dbo.MSG_Chatroom WHERE OwnerId = @did)
	SET @chatid = SCOPE_IDENTITY()

	/* Add driver to the chatroom as a participant */
	INSERT INTO dbo.MSG_ChatroomParticipant
		    (ChatroomId,
		        ParticipantId,
		        LastRequestedId,
		        Archived,
		        LastModified
		    )
	SELECT @chatid, @did, 0, 0, GETDATE()
	WHERE NOT EXISTS (SELECT 1 FROM dbo.MSG_ChatroomParticipant WHERE ChatroomId = @chatid AND ParticipantId = @did)

	/* Create a welcome message */
	EXECUTE dbo.[proc_MSG_SendChatroomMessage] 
	   @chatid
	  ,@did
	  ,'Welcome to your chatroom!'

GO
