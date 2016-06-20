SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToContractSignature_rst](
	@NUM varchar(8)
)
RETURNS @ContractSignature TABLE (
	[SIGSTATUS] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL,
	[SIGNATORY] nvarchar(255) COLLATE Latin1_General_100_CI_AI NULL,
	[NOTES] nvarchar(255) COLLATE Latin1_General_100_CI_AI NULL,
	[DATE] smalldatetime NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @ContractSignature 
	SELECT [sign].Name, cts.SIGNATORY, cts.NOTES, cts.DATE
	FROM GBL_BT_CONTRACTSIGNATURE cts
	INNER JOIN GBL_SignatureStatus sig
		ON cts.SIGSTATUS=sig.SIG_ID
	INNER JOIN GBL_SignatureStatus_Name [sign]
		ON sig.SIG_ID=[sign].SIG_ID AND [sign].LangID=(SELECT TOP 1 LangID FROM GBL_SignatureStatus_Name WHERE SIG_ID=sig.SIG_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE NUM = @NUM
ORDER BY CASE WHEN DATE IS NULL THEN 1 ELSE 0 END, DATE

RETURN

END
GO
