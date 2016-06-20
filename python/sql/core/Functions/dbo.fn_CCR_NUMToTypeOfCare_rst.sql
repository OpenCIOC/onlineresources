SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CCR_NUMToTypeOfCare_rst](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS @TypeOfCare TABLE (
	[TOC_ID] int NULL,
	[TypeOfCare] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL,
	[Notes] nvarchar(255) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @TypeOfCare
SELECT toc.TOC_ID, tocn.Name, prn.Notes
	FROM CCR_BT_TOC pr
	LEFT JOIN CCR_BT_TOC_Notes prn
		ON pr.BT_TOC_ID=prn.BT_TOC_ID AND prn.LangID=@LangID
	INNER JOIN CCR_TypeOfCare toc
		ON pr.TOC_ID = toc.TOC_ID
	INNER JOIN CCR_TypeOfCare_Name tocn
		ON toc.TOC_ID=tocn.TOC_ID AND tocn.LangID=@LangID
WHERE NUM = @NUM
ORDER BY toc.DisplayOrder, tocn.Name

RETURN

END
GO
