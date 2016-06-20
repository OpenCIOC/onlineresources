CREATE TABLE [dbo].[CIC_GeneralHeading_Name]
(
[GH_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_GeneralHeading_Name_d] ON [dbo].[CIC_GeneralHeading_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE gh
	FROM CIC_GeneralHeading gh
	INNER JOIN Deleted d
		ON gh.GH_ID=d.GH_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_GeneralHeading_Name ghn WHERE ghn.GH_ID=gh.GH_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH pr WHERE pr.GH_ID=gh.GH_ID)

INSERT INTO CIC_GeneralHeading_Name (GH_ID,LangID,[Name])
	SELECT d.GH_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CIC_GeneralHeading_Name ghn WHERE ghn.GH_ID=d.GH_ID)
			AND EXISTS(SELECT * FROM CIC_BT_PB_GH pr WHERE pr.GH_ID=d.GH_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Name] ADD CONSTRAINT [PK_CIC_GeneralHeading_Name] PRIMARY KEY CLUSTERED  ([GH_ID], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_GeneralHeading_Name_UniqueName] ON [dbo].[CIC_GeneralHeading_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Name] ADD CONSTRAINT [FK_CIC_GeneralHeading_Name_CIC_GeneralHeading] FOREIGN KEY ([GH_ID]) REFERENCES [dbo].[CIC_GeneralHeading] ([GH_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Name] ADD CONSTRAINT [FK_CIC_GeneralHeading_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_GeneralHeading_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_GeneralHeading_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_GeneralHeading_Name] TO [cioc_login_role]
GO
