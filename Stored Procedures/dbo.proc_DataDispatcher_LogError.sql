SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_DataDispatcher_LogError]
	@component VARCHAR(MAX),
	@header VARCHAR(MAX),
	@message VARCHAR(MAX)
AS

INSERT INTO dbo.DataDispatchErrorLog
        ( Component,
          Header,
          Message,
          Timestamp
        )
VALUES  ( @component, 
          @header, 
          @message, 
          GETDATE() 
        )


GO
