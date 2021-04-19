SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_RecipientNotification table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_RecipientNotification_Insert]
(

	@NotificationTemplateId uniqueidentifier   ,

	@RecipientName varchar (200)  ,

	@RecipientAddress varchar (200)  ,

	@Disabled bit   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS
	-- =============================================
	-- Author:		<Dmitrijs Jurins>
	-- Create date: <2018-10-26>
	-- Description:	<As the Name+Address for the key and have to be unique, name randomisation has to be applied on insert. This cannot be done in the app.>
	-- =============================================
	DECLARE @cnt INT

	SELECT @cnt = ISNULL(COUNT(*), 0)
	FROM dbo.TAN_RecipientNotification
	WHERE RecipientName = @RecipientName AND RecipientAddress = @RecipientAddress

	IF @cnt > 0
	BEGIN
		SET @RecipientName = @RecipientName + ' ' + CAST(NEWID() AS NVARCHAR(MAX))
	END
				
				INSERT INTO [dbo].[TAN_RecipientNotification]
					(
					[NotificationTemplateId]
					,[RecipientName]
					,[RecipientAddress]
					,[Disabled]
					,[Archived]
					,[LastOperation]
					,[Count]
					)
				VALUES
					(
					@NotificationTemplateId
					,@RecipientName
					,@RecipientAddress
					,@Disabled
					,@Archived
					,@LastOperation
					,@Count
					)
				

GO
