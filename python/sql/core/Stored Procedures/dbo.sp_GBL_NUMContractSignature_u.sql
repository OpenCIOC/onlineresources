SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMContractSignature_u]
	@CTS_ID int,
	@NUM varchar(8),
	@SigStatus int,
	@Signatory nvarchar(255),
	@DateSigned smalldatetime,
	@Notes nvarchar(255)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

IF NOT EXISTS(SELECT * FROM GBL_SignatureStatus WHERE SIG_ID=@SigStatus) BEGIN
	IF @CTS_ID IS NOT NULL BEGIN
		SELECT @SigStatus = NULL
	END ELSE BEGIN
		SELECT @SigStatus = SIG_ID FROM GBL_SignatureStatus WHERE Code='N'
	END
END

IF EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=@@LANGID) BEGIN
	IF @CTS_ID IS NOT NULL BEGIN
		UPDATE GBL_BT_CONTRACTSIGNATURE SET
			SIGSTATUS = ISNULL(@SigStatus,SIGSTATUS),
			SIGNATORY = @Signatory,
			DATE = @DateSigned,
			NOTES = @Notes
		WHERE CTS_ID=@CTS_ID
	END ELSE BEGIN
		INSERT INTO GBL_BT_CONTRACTSIGNATURE (
			NUM,
			SIGSTATUS,
			SIGNATORY,
			DATE,
			NOTES
		) VALUES (
			@NUM,
			@SigStatus,
			@Signatory,
			@DateSigned,
			@Notes
		)
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMContractSignature_u] TO [cioc_login_role]
GO
