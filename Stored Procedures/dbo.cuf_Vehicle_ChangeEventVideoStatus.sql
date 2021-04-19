SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ChangeEventVideoStatus]
(
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER,
	@newStatus INT,
	@comment NVARCHAR(MAX)
)
AS

	EXEC dbo.proc_ChangeEventVideoStatus @evid, @uid, @newStatus, @comment
	


GO
