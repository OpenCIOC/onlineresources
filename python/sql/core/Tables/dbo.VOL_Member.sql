CREATE TABLE [dbo].[VOL_Member]
(
[VMEM_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[MemberSince] [smalldatetime] NULL,
[NextRenewalDate] [smalldatetime] NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_VOL_Member_Active] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member] ADD CONSTRAINT [PK_VOL_Membership] PRIMARY KEY CLUSTERED  ([VMEM_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Member] ON [dbo].[VOL_Member] ([NUM]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Member] ADD CONSTRAINT [FK_VOL_Member_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Member] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Member_GBL_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Member] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Member] TO [cioc_vol_search_role]
GO
