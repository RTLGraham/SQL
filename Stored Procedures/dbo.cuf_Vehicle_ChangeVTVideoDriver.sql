SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ChangeVTVideoDriver]
(
	@evid BIGINT,
	@oldDriverId UNIQUEIDENTIFIER,
	@newDriverId UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
AS

	EXEC proc_ChangeVTVideoDriver @evid, @oldDriverId, @newDriverId, @uid

GO
