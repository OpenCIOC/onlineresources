CREATE TABLE [dbo].[GBL_PrivacyProfile_Fld]
(
[PrivacyFieldID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NOT NULL,
[FieldID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_GBL_PrivacyProfile_Fld_iud] ON [dbo].[GBL_PrivacyProfile_Fld] 
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

UPDATE fo
		SET PrivacyProfileIDList = dbo.fn_GBL_PrivacyProfile_Fld_l(fo.FieldID)
	FROM GBL_FieldOption fo
	WHERE
		(
			fo.PrivacyProfileIDList<>dbo.fn_GBL_PrivacyProfile_Fld_l(fo.FieldID)
			OR (fo.PrivacyProfileIDList IS NULL AND dbo.fn_GBL_PrivacyProfile_Fld_l(fo.FieldID) IS NOT NULL)
			OR (fo.PrivacyProfileIDList IS NOT NULL AND dbo.fn_GBL_PrivacyProfile_Fld_l(fo.FieldID) IS NULL)
		)
		AND (
			EXISTS(SELECT * FROM inserted i WHERE i.FieldID=fo.FieldID)
			OR EXISTS(SELECT * FROM deleted d WHERE d.FieldID=fo.FieldID)
		)

SET NOCOUNT OFF

GO
ALTER TABLE [dbo].[GBL_PrivacyProfile_Fld] ADD CONSTRAINT [PK_CIC_PrivacyProfile_Fld] PRIMARY KEY CLUSTERED  ([PrivacyFieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrivacyProfile_Fld] ADD CONSTRAINT [IX_GBL_PrivacyProfile_Fld_UniquePair] UNIQUE NONCLUSTERED  ([ProfileID], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrivacyProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_CIC_PrivacyProfile_Fld_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_PrivacyProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_CIC_PrivacyProfile_Fld_CIC_PrivacyProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_PrivacyProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_PrivacyProfile_Fld] TO [cioc_login_role]
GO
