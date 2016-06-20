CREATE TABLE [dbo].[CIC_EmployeeRange]
(
[ER_ID] [int] NOT NULL IDENTITY(1, 1),
[MinNumber] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_EmployeeRange] ADD CONSTRAINT [PK_CIC_EmployeeRange] PRIMARY KEY CLUSTERED  ([ER_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CIC_EmployeeRange] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_EmployeeRange] TO [cioc_login_role]
GO
