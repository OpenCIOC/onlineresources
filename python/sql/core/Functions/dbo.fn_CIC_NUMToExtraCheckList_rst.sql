
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToExtraCheckList_rst](
	@FieldName varchar(100),
	@NUM varchar(8),
	@LangID smallint
)
RETURNS @ExtraCheckList TABLE (
	[EXC_ID] int NULL,
	[ExtraCheckList] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 27-Sep-2014
	Action: NO ACTION REQUIRED
*/

INSERT INTO @ExtraCheckList
SELECT exc.EXC_ID, ISNULL(excn.Name,exc.Code)
	FROM CIC_BT_EXC pr
	INNER JOIN CIC_ExtraCheckList exc
		ON pr.EXC_ID=exc.EXC_ID AND exc.FieldName=@FieldName
	LEFT JOIN CIC_ExtraCheckList_Name excn
		ON exc.EXC_ID=excn.EXC_ID AND excn.LangID=@LangID
WHERE NUM = @NUM
	AND COALESCE(excn.Name,exc.Code) IS NOT NULL
ORDER BY exc.DisplayOrder, ISNULL(excn.Name,exc.Code)

RETURN

END

GO
