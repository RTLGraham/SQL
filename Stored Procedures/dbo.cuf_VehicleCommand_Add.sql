SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_VehicleCommand_Add]
(
	@ivhId UNIQUEIDENTIFIER,     
	@Commandtring VARCHAR(1024),  
	@estEndTime SMALLDATETIME = NULL
)
AS
BEGIN
	EXECUTE dbo.proc_AddCommand @ivhId, @estEndTime, @Commandtring
END


GO
