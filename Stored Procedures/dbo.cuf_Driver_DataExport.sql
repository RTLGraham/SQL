SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_DataExport]
	@cid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
AS
          EXEC dbo.proc_DataExport_Drivers @cid, @uid

GO
