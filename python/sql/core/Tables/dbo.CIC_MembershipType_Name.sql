CREATE TABLE [dbo].[CIC_MembershipType_Name]
(
[MT_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_MembershipType_Name_d] ON [dbo].[CIC_MembershipType_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE mt
	FROM CIC_MembershipType mt
	INNER JOIN Deleted d
		ON mt.MT_ID=d.MT_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_MembershipType_Name mtn WHERE mtn.MT_ID=mt.MT_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_MT pr WHERE pr.MT_ID=mt.MT_ID)

INSERT INTO CIC_MembershipType_Name (MT_ID,LangID,[Name])
	SELECT d.MT_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CIC_MembershipType_Name mtn WHERE mtn.MT_ID=d.MT_ID)
			AND EXISTS(SELECT * FROM CIC_BT_MT pr WHERE pr.MT_ID=d.MT_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_MembershipType_Name] ADD CONSTRAINT [PK_CIC_MembershipType_Name] PRIMARY KEY CLUSTERED  ([MT_ID], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_MembershipType_Name_UniqueName] ON [dbo].[CIC_MembershipType_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_MembershipType_Name] ADD CONSTRAINT [FK_CIC_MembershipType_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_MembershipType_Name] ADD CONSTRAINT [FK_CIC_MembershipType_Name_CIC_MembershipType] FOREIGN KEY ([MT_ID]) REFERENCES [dbo].[CIC_MembershipType] ([MT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_MembershipType_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_MembershipType_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_MembershipType_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_MembershipType_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_MembershipType_Name] TO [cioc_login_role]
GO
