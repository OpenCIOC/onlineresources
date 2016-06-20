SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Contact_PhoneType_lf]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 22-Jul-2012
	Action: NO ACTION REQUIRED
*/

SELECT pt.*, l.Culture, PhoneType AS OldValue 
	FROM GBL_Contact_PhoneType pt
	INNER JOIN STP_Language l
		ON pt.LangID=l.LangID
ORDER BY CASE WHEN pt.LangID=@@LANGID THEN 0 ELSE 1 END, PhoneType

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Contact_PhoneType_lf] TO [cioc_login_role]
GO
