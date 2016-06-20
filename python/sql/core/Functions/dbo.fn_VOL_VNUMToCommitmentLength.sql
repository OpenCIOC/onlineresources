SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToCommitmentLength](
	@VNUM varchar(10),
	@Notes nvarchar(max)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') 
		+ cln.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + prn.Notes END
	FROM VOL_OP_CL pr
	LEFT JOIN VOL_OP_CL_Notes prn
		ON pr.OP_CL_ID=prn.OP_CL_ID AND prn.LangID=@@LANGID
	INNER JOIN VOL_CommitmentLength cl
		ON pr.CL_ID=cl.CL_ID
	INNER JOIN VOL_CommitmentLength_Name cln
		ON cl.CL_ID=cln.CL_ID AND cln.LangID=@@LANGID
WHERE pr.VNUM = @VNUM
ORDER BY cl.DisplayOrder, cln.Name

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToCommitmentLength] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToCommitmentLength] TO [cioc_vol_search_role]
GO
