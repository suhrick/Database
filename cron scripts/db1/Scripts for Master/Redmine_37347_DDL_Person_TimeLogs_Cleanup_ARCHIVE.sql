USE backup_archive;
-- Redmine 37347: Archive

-- Type II: Total Time 37 Min on Prod Slave 2 Port 3308


-- UP Script

-- 1) Set Variable
SET @vRedmineNum := 37347;



-- 2) Find Max (Latest) TimeLog per Provider
-- a) Find Max
DROP TABLE IF EXISTS xx_timelog_37347;
CREATE TABLE xx_timelog_37347 (Timelogable_Person_ID INT, Timelogable_Person_Type VARCHAR(40), In_Out_Type VARCHAR(40), Transaction_DT DATETIME, KEY xx_02 (Timelogable_Person_ID, Timelogable_Person_Type));

INSERT INTO xx_timelog_37347 (Timelogable_Person_ID, Timelogable_Person_Type, In_Out_Type, Transaction_DT)
SELECT Timelogable_Person_ID, Timelogable_Person_Type, In_Out_Type, MAX(Transaction_DT) AS Transaction_DT                                               -- 78 Sec -- 4428 Rows
FROM teladoc_eds.person_timelogs
GROUP BY Timelogable_Person_ID, Timelogable_Person_Type,In_Out_Type;


-- b) Find corresponding PK to Whitelist
DROP TABLE IF EXISTS xx_keep_37347;
CREATE TABLE xx_keep_37347 (Person_TimeLog_ID INT, Timelogable_Person_ID INT, Timelogable_Person_Type VARCHAR(40), Transaction_DT DATETIME, In_Out_Type VARCHAR(40), In_Out_FLG CHAR(1),
        PRIMARY KEY (Person_TimeLog_ID), KEY xx_02 (Timelogable_Person_ID));


INSERT INTO xx_keep_37347 (Person_TimeLog_ID, Timelogable_Person_ID, Timelogable_Person_Type, Transaction_DT, In_Out_Type, In_Out_FLG)
SELECT pt.Person_TimeLog_ID, pt.Timelogable_Person_ID, pt.Timelogable_Person_Type, pt.Transaction_DT, pt.In_Out_Type, pt.In_Out_FLG     -- 4 Sec -- 8488 Rows
FROM xx_timelog_37347 xx
INNER JOIN teladoc_eds.person_timelogs pt ON pt.Timelogable_Person_ID=xx.Timelogable_Person_ID AND pt.Timelogable_Person_Type=xx.Timelogable_Person_Type
        AND pt.In_Out_Type=xx.In_Out_Type AND pt.Transaction_DT=xx.Transaction_DT;


-- c) Setup for Rest to be Archived
DROP TABLE IF EXISTS xx_timelog_pk_37347;
CREATE TABLE xx_timelog_pk_37347 (Person_Timelog_ID INT, In_Out_Type VARCHAR(40), Transaction_DT DATETIME, PRIMARY KEY (Person_Timelog_ID));

INSERT INTO xx_timelog_pk_37347 (Person_Timelog_ID, In_Out_Type, Transaction_DT)
SELECT pt.Person_Timelog_ID, pt.In_Out_Type, pt.Transaction_DT                                                                                          -- 1:22 Min -- 3464219 Rows
FROM teladoc_eds.person_timelogs pt
LEFT OUTER JOIN xx_keep_37347 xx ON xx.Person_Timelog_ID=pt.Person_Timelog_ID
WHERE xx.Person_Timelog_ID IS NULL;


-- d) Set Drive Table for Archive Proc
DROP TABLE IF EXISTS xx_archive_pk_driver_37347;
CREATE TABLE xx_archive_pk_driver_37347 (RowNum INT NOT NULL AUTO_INCREMENT, ID CHAR(20) NOT NULL, PRIMARY KEY (RowNum), KEY xx_01 (ID));
INSERT INTO  xx_archive_pk_driver_37347 (ID)
SELECT Person_Timelog_ID                                                                                                                -- 1 Min -- 3468067 Rows
FROM backup_archive.xx_timelog_pk_37347;



-- 3) Archive Rest
CALL p_xx_archive_loop(
        @vRedmineNum,                                   -- vRedmineNum
        'UP',                                           -- vMode ('UP', 'DOWN', 'CHECK')
        'backup_archive.xx_timelog_pk_37347',           -- vArchiveDriverTable
        'Person_Timelog_ID',                            -- vArchiveDriverPK
        'Person_Timelog_ID',                            -- vSourcePK
        'Transaction_DT',                               -- vDateColumn
        0,                                              -- vArchiveMonths
        'N',                                            -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_37347',                   -- vTempDriverTable
        'teladoc_eds.person_timelogs',                  -- vArchiveSourceTable
        'backup_archive.person_timelogs',               -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_37347 xx
        INNER JOIN teladoc_eds.person_timelogs src ON src.Person_Timelog_ID=xx.ID',     -- vSelect
        100000,                                         -- vLimitIncrement
        @vRowsAffected);                                -- vRowsAffected
SELECT @vRowsAffected;          -- 34 Min -- 3468067 Rows



-- 4) Clean Up
DROP TABLE IF EXISTS xx_timelog_37347;
DROP TABLE IF EXISTS xx_keep_37347;
DROP TABLE IF EXISTS xx_timelog_pk_37347;
DROP TABLE IF EXISTS xx_archive_pk_driver_37347;



-- Dev Scripts
/*
CALL p_xx_archive_loop(
        @vRedmineNum,                                   -- vRedmineNum
        'CHECK',                                        -- vMode ('UP', 'DOWN', 'CHECK')
        'teladoc_eds.person_timelogs',                  -- vArchiveDriverTable
        'Person_Timelog_ID',                            -- vArchiveDriverPK
        'Person_Timelog_ID',                            -- vSourcePK
        'Transaction_DT',                               -- vDateColumn
        0,                                              -- vArchiveMonths
        'Y',                                            -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_37347',                   -- vTempDriverTable
        'teladoc_eds.person_timelogs',                  -- vArchiveSourceTable
        'backup_archive.person_timelogs',               -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_37347 xx
        INNER JOIN teladoc_eds.person_timelogs src ON src.Person_Timelog_ID=xx.ID',     -- vSelect
        100000,                                         -- vLimitIncrement
        @vRowsAffected);                                -- vRowsAffected

-- Row Count
SELECT 'Backup' AS Which, MIN(Transaction_DT), MAX(Transaction_DT), COUNT(*) FROM backup_archive.person_timelogs
UNION ALL
SELECT 'EDS' AS Which, MIN(Transaction_DT), MAX(Transaction_DT), COUNT(*) FROM teladoc_eds.person_timelogs;

-- Extract for QA Test
SELECT cp.Provider_ID, p.First_NM, p.Last_NM, rpr.Provider_Role_CD, xx.Transaction_DT AS Last_Clock_In_DT, xx.In_Out_Type, p.User_NM, cp.NPI, cp.DEA, cp.Last_Active_DT
FROM xx_keep_37347 xx
INNER JOIN teladoc_eds.providers cp ON cp.Provider_ID=xx.Timelogable_Person_ID
INNER JOIN teladoc_eds.persons p ON p.Person_ID=cp.Person_ID AND p.Exclusion_CD='IN'
INNER JOIN teladoc_eds.provider_role_relations prr ON prr.Provider_ID=cp.Provider_ID AND prr.Exclusion_CD='IN'
INNER JOIN teladoc_eds.ref_provider_roles rpr ON rpr.Provider_Role_CD=prr.Provider_Role_CD AND rpr.Internal_Role_FLG<>'Z';

-- Other Queries
SELECT * FROM backup_archive.person_timelogs;
SELECT * FROM teladoc_eds.person_timelogs;
SELECT TIMESTAMPDIFF(MONTH, MIN(Transaction_DT), CURDATE()) FROM teladoc_eds.person_timelogs;
SELECT @vStmt;
SELECT * FROM xx_archive_log WHERE RedmineNum=@vRedmineNum ORDER BY 1 DESC;
SELECT * FROM xx_archive_33289;
*/



-- DOWN Script
/*
SET @vRedmineNum := 37347;
CALL p_xx_archive_loop(
        @vRedmineNum,                                   -- vRedmineNum
        'DOWN',                                         -- vMode ('UP', 'DOWN', 'CHECK')
        'teladoc_eds.person_timelogs',                  -- vArchiveDriverTable
        'Person_Timelog_ID',                            -- vArchiveDriverPK
        'Person_Timelog_ID',                            -- vSourcePK
        'Transaction_DT',                               -- vDateColumn
        1,                                              -- vArchiveMonths
        'Y',                                            -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_37347',                   -- vTempDriverTable
        'teladoc_eds.person_timelogs',                  -- vArchiveSourceTable
        'backup_archive.person_timelogs',               -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_37347 xx
        INNER JOIN teladoc_eds.person_timelogs src ON src.Person_Timelog_ID=xx.ID',     -- vSelect
        100000,                                         -- vLimitIncrement
        @vRowsAffected);                                -- vRowsAffected
SELECT @vRowsAffected;          -- 15 Min -- 3468067 Rows
*/
