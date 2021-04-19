SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_ChangeVideoDriver]
(
	@evid BIGINT,
	@oldDriverId UNIQUEIDENTIFIER,
	@newDriverId UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
AS

	EXEC proc_ChangeVideoDriver @evid, @oldDriverId, @newDriverId, @uid
	



GO
