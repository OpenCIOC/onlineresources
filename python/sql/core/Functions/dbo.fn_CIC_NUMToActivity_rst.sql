SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToActivity_rst](
	@NUM varchar(8)
)
RETURNS @UnitType TABLE (
	[Status] nvarchar(100) COLLATE Latin1_General_100_CI_AI NULL,
	[ActivityName] nvarchar(100) COLLATE Latin1_General_100_CI_AI NULL,
	[ActivityDescription] nvarchar(max) COLLATE Latin1_General_100_CI_AI NULL,
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

INSERT INTO @UnitType
SELECT	astatn.Name,
		ISNULL(prn.ActivityName,cioc_shared.dbo.fn_SHR_STP_ObjectName('#') + CAST(ROW_NUMBER() OVER(ORDER BY prn.ActivityName, pr.MODIFIED_DATE) AS varchar)),
		prn.ActivityDescription,
		prn.Notes
	FROM CIC_BT_ACT pr
	LEFT JOIN CIC_BT_ACT_Notes prn
		ON pr.BT_ACT_ID=prn.BT_ACT_ID
			AND prn.LangID=@@LANGID
	LEFT JOIN CIC_Activity_Status_Name astatn
		ON pr.ASTAT_ID=astatn.ASTAT_ID
			AND astatn.LangID=@@LANGID
WHERE NUM = @NUM
ORDER BY prn.ActivityName, pr.MODIFIED_DATE

RETURN

END
GO
