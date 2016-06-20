CREATE TABLE [dbo].[VOL_CommitmentLength_Name]
(
[CL_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_CommitmentLength_Name_d] ON [dbo].[VOL_CommitmentLength_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE cl
	FROM VOL_CommitmentLength cl
	INNER JOIN Deleted d
		ON cl.CL_ID=d.CL_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_CommitmentLength_Name cln WHERE cln.CL_ID=cl.CL_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_CL pr WHERE pr.CL_ID=cl.CL_ID)

INSERT INTO VOL_CommitmentLength_Name (CL_ID,LangID,[Name])
	SELECT d.CL_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM VOL_CommitmentLength_Name cln WHERE cln.CL_ID=d.CL_ID)
			AND EXISTS(SELECT * FROM VOL_OP_CL pr WHERE pr.CL_ID=d.CL_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[VOL_CommitmentLength_Name] ADD CONSTRAINT [PK_VOL_CommitmentLength_Name] PRIMARY KEY CLUSTERED  ([CL_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_CommitmentLength_Name_UniqueName] ON [dbo].[VOL_CommitmentLength_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommitmentLength_Name] ADD CONSTRAINT [FK_VOL_CommitmentLength_Name_VOL_CommitmentLength] FOREIGN KEY ([CL_ID]) REFERENCES [dbo].[VOL_CommitmentLength] ([CL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_CommitmentLength_Name] ADD CONSTRAINT [FK_VOL_CommitmentLength_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[VOL_CommitmentLength_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_CommitmentLength_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_CommitmentLength_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_CommitmentLength_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_CommitmentLength_Name] TO [cioc_vol_search_role]
GO
