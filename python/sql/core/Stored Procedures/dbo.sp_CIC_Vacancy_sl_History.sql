SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Vacancy_sl_History]
	@User_ID int,
	@ViewType int,
	@BT_VUT_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 01-May-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @CanSeeHistory bit, @NUM varchar(8), @ServiceTitle nvarchar(100)

SELECT @NUM=NUM, @ServiceTitle=ServiceTitle
FROM CIC_BT_VUT pr
LEFT JOIN CIC_BT_VUT_Notes prn
	ON prn.BT_VUT_ID = pr.BT_VUT_ID AND prn.LangID=@@LANGID
WHERE pr.BT_VUT_ID=@BT_VUT_ID

IF @NUM IS NULL BEGIN
	SET @CanSeeHistory=0
END ELSE BEGIN
	SET @CanSeeHistory=dbo.fn_CIC_CanUpdateVacancy(@NUM,@User_ID,@ViewType,@@LANGID,GETDATE())
END

SELECT @CanSeeHistory AS CAN_SEE_HISTORY, @NUM + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @ServiceTitle AS RecordTitle

SELECT TOP 20 hst.*
FROM CIC_BT_VUT_History hst
WHERE hst.BT_VUT_ID=@BT_VUT_ID
	AND @CanSeeHistory=1
ORDER BY hst.MODIFIED_DATE DESC, hst.MODIFIED_BY, hst.BT_VUT_HIST_ID DESC

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_sl_History] TO [cioc_login_role]
GO
