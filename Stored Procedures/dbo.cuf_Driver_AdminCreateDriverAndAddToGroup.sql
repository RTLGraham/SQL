SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_AdminCreateDriverAndAddToGroup]
    (
		@cid UNIQUEIDENTIFIER,
		@Surname VARCHAR(50) = NULL,
		@Firstname VARCHAR(50) = NULL,
		@Middlenames VARCHAR(250) = NULL,
		@Number VARCHAR(32) = NULL,
		@NumberAlternate VARCHAR(32) = NULL,
		@NumberAlternate2 VARCHAR(32) = NULL,
		@gid UNIQUEIDENTIFIER = NULL,
		@LanguageCultureId SMALLINT,
		@password VARCHAR(32) = NULL,
		@playInd BIT = NULL,
		@driverType VARCHAR(100) = NULL,
		@empNumber VARCHAR(30) = NULL,
		@email VARCHAR(100) = NULL 
    )
AS 
    BEGIN
        BEGIN TRAN
	
        DECLARE @did UNIQUEIDENTIFIER
        SET @did = NEWID()
        
        INSERT INTO dbo.Driver
                ( DriverId ,
                  Number ,
                  NumberAlternate ,
                  NumberAlternate2 ,
                  FirstName ,
                  Surname ,
                  MiddleNames ,
                  LastOperation ,
                  Archived,
                  LanguageCultureId,
				  [Password],
				  PlayInd,
				  DriverType,
				  EmpNumber,
				  Email
                )
        VALUES  ( @did , -- DriverId - uniqueidentifier
                  @Number , -- Number - varchar(32)
                  @NumberAlternate , -- NumberAlternate - varchar(32)
                  @NumberAlternate2 , -- NumberAlternate2 - varchar(32)
                  @Firstname , -- FirstName - varchar(50)
                  @Surname , -- Surname - varchar(50)
                  @Middlenames , -- MiddleNames - varchar(250)
                  GETDATE() , -- LastOperation - smalldatetime
                  0,  -- Archived - bit
                  @LanguageCultureId, -- LanguageCultureId - smallint
				  @password,
				  @playInd,
				  @driverType,
				  @empNumber,
				  @email
                )
                
        INSERT INTO dbo.CustomerDriver
                ( DriverId ,
                  CustomerId ,
                  StartDate ,
                  EndDate ,
                  LastOperation ,
                  Archived
                )
        VALUES  ( @did , -- DriverId - uniqueidentifier
                  @cid , -- CustomerId - uniqueidentifier
                  GETDATE() , -- StartDate - datetime
                  NULL , -- EndDate - datetime
                  GETDATE() , -- LastOperation - smalldatetime
                  0  -- Archived - bit
                )
        
        /*Archive UNKNOW driver is there is any*/
		UPDATE dbo.Driver
		SET Archived = 1
		WHERE DriverId IN	(
							SELECT d.DriverId
							FROM dbo.Driver d
								INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
							WHERE d.Number IN (@Number, @NumberAlternate, @NumberAlternate2)
								AND d.Surname = 'UNKNOWN' AND d.Archived = 0
								AND cd.CustomerId = @cid
							)
        UPDATE dbo.CustomerDriver
		SET Archived = 1
		WHERE DriverId IN	(
							SELECT d.DriverId
							FROM dbo.Driver d
								INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
							WHERE d.Number IN (@Number, @NumberAlternate, @NumberAlternate2)
								AND d.Surname = 'UNKNOWN' AND d.Archived = 0
								AND cd.CustomerId = @cid
							)
			AND CustomerId = @cid
							
        IF @gid IS NOT NULL
        BEGIN    
			INSERT INTO dbo.GroupDetail
					( GroupId ,
					  GroupTypeId ,
					  EntityDataId
					)
			VALUES  ( @gid , -- GroupId - uniqueidentifier
					  2 , -- GroupTypeId - int
					  @did  -- EntityDataId - uniqueidentifier
					)
        END    

		/* Create Driver Chatroom if doesn't already exist */
		DECLARE @chatid INT
		INSERT INTO dbo.MSG_Chatroom
				(OwnerId,
					ChatroomName,
					Archived,
					LastModified
				)
		SELECT @did, 'Chatroom for ' + @Surname, 0, GETDATE()
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

        COMMIT TRAN
    END

GO
