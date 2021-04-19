SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_IVH_SendBulkOTA]
          @vids nvarchar(MAX),
	@custid uniqueidentifier,
	@software varchar(20),
	@testversion varchar(20) = NULL,
	@rptonly bit = 1,
	@force bit = 0
AS
	SET NOCOUNT ON;

          EXEC proc_SendBulkOTA @vids, @custid, @software, @testversion, @rptonly, @force;
GO
