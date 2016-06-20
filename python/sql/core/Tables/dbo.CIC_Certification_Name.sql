CREATE TABLE [dbo].[CIC_Certification_Name]
(
[CRT_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_Certification_Name_d] ON [dbo].[CIC_Certification_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE crt
	FROM CIC_Certification crt
	INNER JOIN Deleted d
		ON crt.CRT_ID=d.CRT_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_Certification_Name crtn WHERE crtn.CRT_ID=crt.CRT_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.CERTIFIED=crt.CRT_ID)

INSERT INTO CIC_Certification_Name (CRT_ID,LangID,[Name])
	SELECT d.CRT_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CIC_Certification_Name crtn WHERE crtn.CRT_ID=d.CRT_ID)
			AND EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.CERTIFIED=d.CRT_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_Certification_Name] ADD CONSTRAINT [PK_CIC_Certification_Name] PRIMARY KEY CLUSTERED  ([CRT_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Certification_Name] ADD CONSTRAINT [FK_CIC_Certification_Name_CIC_Certification] FOREIGN KEY ([CRT_ID]) REFERENCES [dbo].[CIC_Certification] ([CRT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Certification_Name] ADD CONSTRAINT [FK_CIC_Certification_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_Certification_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Certification_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Certification_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Certification_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Certification_Name] TO [cioc_login_role]
GO
