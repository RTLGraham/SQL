SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Vehicle_DataExport]
	@cid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
AS
          EXEC dbo.proc_DataExport_Vehicles @cid, @uid

GO
