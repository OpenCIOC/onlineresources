SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ContractSignature_i]
	@NUM varchar(8),
	@ContractSignatures [xml]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @SignatureTable TABLE (
	[GUID] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[SIGSTATUS] int NOT NULL,
	[SIGNATORY] nvarchar(255) NULL,
	[NOTES] nvarchar(255) NULL,
	[DATE] smalldatetime NULL
)

INSERT INTO @SignatureTable (
	[GUID],
	SIGSTATUS,
	SIGNATORY,
	NOTES,
	DATE
)
SELECT
	N.value('@GID', 'uniqueidentifier') AS [GUID],
	sig.SIG_ID AS SIGSTATUS,
	N.value('@SIGNAME', 'nvarchar(255)') AS SIGNATORY,
	N.value('@N', 'nvarchar(255)') AS NOTES, 
	N.value('@DATE', 'smalldatetime') AS DATE
FROM @ContractSignatures.nodes('//SIGNATURE') as T(N)
INNER JOIN GBL_SignatureStatus sig ON N.value('@STATUS', 'varchar(20)')=sig.Code

DELETE btcs
	FROM GBL_BT_CONTRACTSIGNATURE btcs
WHERE btcs.NUM=@NUM AND NOT EXISTS(SELECT * FROM @SignatureTable s WHERE s.GUID=btcs.GUID)

INSERT INTO GBL_BT_CONTRACTSIGNATURE (
	NUM,
	[GUID],
	SIGSTATUS,
	SIGNATORY,
	NOTES,
	DATE
) SELECT
	@NUM,
	[GUID],
	SIGSTATUS,
	SIGNATORY,
	NOTES,
	DATE
FROM @SignatureTable s
WHERE NOT EXISTS(SELECT * FROM GBL_BT_CONTRACTSIGNATURE btcs WHERE s.GUID=btcs.GUID)

UPDATE btcs SET 
	SIGSTATUS	= s.SIGSTATUS,
	SIGNATORY	= s.SIGNATORY,
	NOTES		= s.NOTES,
	DATE		= s.DATE
FROM GBL_BT_CONTRACTSIGNATURE btcs
INNER JOIN @SignatureTable s
	ON s.GUID=btcs.GUID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ContractSignature_i] TO [cioc_login_role]
GO
