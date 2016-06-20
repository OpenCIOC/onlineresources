SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[fn_VOL_VNUMToSocialMedia_rst](
	@VNUM varchar(10)
)
RETURNS @SocialMedia TABLE (
	Name nvarchar(255),
	Protocol varchar(10),
	URL nvarchar(200),
	IconURL16 varchar(200),
	IconURL24 varchar(200)
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

INSERT INTO @SocialMedia
SELECT	ISNULL(smn.Name,sm.DefaultName) AS Name, pr.Protocol, pr.URL, sm.IconURL16, sm.IconURL24
	FROM VOL_OP_SM pr
	INNER JOIN GBL_SocialMedia sm
		ON pr.SM_ID=sm.SM_ID
	LEFT JOIN GBL_SocialMedia_Name smn
		ON sm.SM_ID=smn.SM_ID AND smn.LangID=@@LANGID
WHERE VNUM=@VNUM AND pr.LangID=@@LANGID
ORDER BY ISNULL(smn.Name,sm.DefaultName)

RETURN

END

GO
