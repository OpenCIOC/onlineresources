CREATE TABLE [dbo].[CIC_Accreditation_Name]
(
[ACR_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_Accreditation_Name_d] ON [dbo].[CIC_Accreditation_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE acr
	FROM CIC_Accreditation acr
	INNER JOIN Deleted d
		ON acr.ACR_ID=d.ACR_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_Accreditation_Name acrn WHERE acrn.ACR_ID=acr.ACR_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.ACCREDITED=acr.ACR_ID)

INSERT INTO CIC_Accreditation_Name (ACR_ID,LangID,[Name])
	SELECT d.ACR_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CIC_Accreditation_Name acrn WHERE acrn.ACR_ID=d.ACR_ID)
			AND EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.ACCREDITED=d.ACR_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_Accreditation_Name] ADD CONSTRAINT [PK_CIC_Accreditation_Name] PRIMARY KEY CLUSTERED  ([ACR_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Accreditation_Name] ADD CONSTRAINT [FK_CIC_Accreditation_Name_CIC_Accreditation] FOREIGN KEY ([ACR_ID]) REFERENCES [dbo].[CIC_Accreditation] ([ACR_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Accreditation_Name] ADD CONSTRAINT [FK_CIC_Accreditation_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_Accreditation_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Accreditation_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Accreditation_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Accreditation_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Accreditation_Name] TO [cioc_login_role]
GO
