SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToOtherAddress_rst](
	@NUM varchar(8),
	@WebEnable bit
)
RETURNS @OtherAddress TABLE (
	[TITLE] nvarchar(100) COLLATE Latin1_General_100_CI_AI NULL,
	[SITE_CODE] varchar(100) COLLATE Latin1_General_100_CI_AI NULL,
	[Address] nvarchar(max) COLLATE Latin1_General_100_CI_AI NULL,
	[MAP_LINK] nvarchar(1500) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @OtherAddress 
	SELECT TITLE,
		SITE_CODE,
		dbo.fn_GBL_FullAddress(
				NUM,
				NULL,
				BUILDING,
				STREET_NUMBER,
				STREET,
				STREET_TYPE,
				STREET_TYPE_AFTER,
				STREET_DIR,
				SUFFIX,
				CITY,
				PROVINCE,
				COUNTRY,
				POSTAL_CODE,
				CARE_OF,
				BOX_TYPE,
				PO_BOX,
				NULL,
				NULL,
				LangID,
				0
			),
		CASE WHEN @WebEnable=1 THEN dbo.fn_GBL_Link_Map(
			NUM,
			NULL,
			MAP_LINK, 
			STREET_NUMBER,
			STREET,
			STREET_TYPE,
			STREET_TYPE_AFTER,
			STREET_DIR,
			CITY,
			PROVINCE,
			COUNTRY,
			POSTAL_CODE,
			NULL,
			NULL,
			LangID
		) ELSE NULL END
	FROM CIC_BT_OTHERADDRESS
WHERE NUM = @NUM AND LangID=@@LANGID
ORDER BY TITLE

RETURN

END
GO
