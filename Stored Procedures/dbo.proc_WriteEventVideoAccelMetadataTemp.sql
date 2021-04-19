SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[proc_WriteEventVideoAccelMetadataTemp]
    @evid BIGINT,
    
    @metadatadt DATETIME,
    @x FLOAT,
    @y FLOAT,
    @z FLOAT   
AS 


	INSERT INTO dbo.EventVideoAccelMetadataTemp
	        ( EventVideoId ,
	          MetadataDateTime ,
	          x ,
	          y ,
	          z
	        )
	VALUES  ( @evid , -- EventVideoId - bigint
	          @metadatadt , -- MetadataDateTime - datetime
	          @x , -- x - float
	          @y , -- y - float
	          @z   -- z - float
	        )


GO
