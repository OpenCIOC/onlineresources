CREATE TABLE [dbo].[VOL_Feedback_Extra]
(
[EX_FB_ID] [int] NOT NULL IDENTITY(1, 1),
[FB_ID] [int] NOT NULL,
[FieldName] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Value] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Feedback_Extra] ADD CONSTRAINT [PK_VOL_Feedback_Extra] PRIMARY KEY CLUSTERED  ([EX_FB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Feedback_Extra] ADD CONSTRAINT [FK_VOL_Feedback_Extra_VOL_Feedback] FOREIGN KEY ([FB_ID]) REFERENCES [dbo].[VOL_Feedback] ([FB_ID]) ON DELETE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Feedback_Extra] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Feedback_Extra] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Feedback_Extra] TO [cioc_vol_search_role]
GRANT INSERT ON  [dbo].[VOL_Feedback_Extra] TO [cioc_vol_search_role]
GO
