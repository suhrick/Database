USE backup_archive;
-- Redmine 32713: Archive

-- Type II: Total Time 52 Min on Prod Slave 3 Port 3309
-- DBA: Please trun off DB Query Cache

-- UP Script
-- set global query_cache_size=10240000;

-- 0) Set Archive Months
-- a) Commented Drop, Create, Insert MUST be run ONCE
/*
DROP TABLE IF EXISTS backup_archive.xx_erx_archive_setting_32713;
CREATE TABLE backup_archive.xx_erx_archive_setting_32713 (PK INT NOT NULL AUTO_INCREMENT, ArchiveMonths INT, Exclusion_CD CHAR(2), Created_At DATETIME, Updated_At DATETIME,
        PRIMARY KEY (PK), KEY xx_02 (Exclusion_CD));
INSERT INTO backup_archive.xx_erx_archive_setting_32713 (ArchiveMonths, Exclusion_CD, Created_At, Updated_At) VALUES (45, 'IN', NOW(), NOW());

-- Dev Scripts
SELECT @vArchiveMonths;
SELECT * FROM backup_archive.xx_erx_archive_setting_32713;
*/
-- b) Grab Archive Months minus one
SELECT CASE WHEN ArchiveMonths-1 > 12 THEN ArchiveMonths-1 ELSE 12 END INTO @vArchiveMonths FROM backup_archive.xx_erx_archive_setting_32713 WHERE Exclusion_CD='IN';
START TRANSACTION;
UPDATE backup_archive.xx_erx_archive_setting_32713 SET Exclusion_CD='EX', Updated_At=NOW() WHERE Exclusion_CD='IN';
INSERT INTO backup_archive.xx_erx_archive_setting_32713 (ArchiveMonths, Exclusion_CD, Created_At, Updated_At) VALUES (@vArchiveMonths, 'IN', NOW(), NOW());
COMMIT;



-- 1) Prescription Tables
-- a) Prescription ID
SET @vRedmineNum := 32713;
-- SET @vArchiveMonths := 44;           -- NOTE: *** We need to work our way down to 12 Months ***
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'UP',                                   -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'Y',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription_ids',          -- vArchiveSourceTable
        'backup_archive.prescription_ids',      -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription_ids src ON src.ID=xx.ID',    -- vSelect
        100000,                                 -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 31236 Rows   -- 25 Sec

-- b) Prescription
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'UP',                                   -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription',              -- vArchiveSourceTable
        'backup_archive.prescription',          -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription src ON src.ID=xx.ID',        -- vSelect
        500,                                    -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 2617884 Rows -- 41 Min

-- c) Prescription Log
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'UP',                                   -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription_log',          -- vArchiveSourceTable
        'backup_archive.prescription_log',      -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription_log src ON src.ID=xx.ID',    -- vSelect
        500,                                    -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 0 Rows       -- 2 Sec

-- d) Prescription Event
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'UP',                                   -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'Prescription_ID',                      -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription_events',       -- vArchiveSourceTable
        'backup_archive.prescription_events',   -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription_events src ON src.Prescription_ID=xx.ID',    -- vSelect
        10000,                                  -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 9045 Rows            -- 11 Sec



-- 2) Patient Tables
-- a) Patient IDs
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'UP',                                   -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.patient_ids',               -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'Y',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.patient_ids',               -- vArchiveSourceTable
        'backup_archive.patient_ids',           -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.patient_ids src ON src.ID=xx.ID', -- vSelect
        1000,                                   -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 17067 Rows   -- 31 Sec

-- b) Patient
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'UP',                                   -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.patient_ids',               -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.patient',                   -- vArchiveSourceTable
        'backup_archive.patient',               -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.patient src ON src.ID=xx.ID',     -- vSelect
        5000,                                   -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 551206 Rows  -- 10 Min

-- c) Patient Logs
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'UP',                                   -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.patient_ids',               -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.patient_log',               -- vArchiveSourceTable
        'backup_archive.patient_log',           -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.patient_log src ON src.ID=xx.ID', -- vSelect
        1000,                                   -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 0 Rows       -- 2 Sec

-- set global query_cache_size=30720000;

-- Dev Scripts
/*
SELECT * FROM xx_archive_log WHERE DATE(Created_At)=CURDATE() ORDER BY 1 DESC LIMIT 100000;
SELECT SUM(Seconds)/60 FROM xx_archive_log WHERE ArchiveSourceTable='erx_remedy.prescription' AND DATE(Created_At)=CURDATE();

SELECT Statement, ArchiveSourceTable, RowsAffected, Seconds, ROUND(Seconds/60,1) as Minutes, Round(Seconds/60/60,1) as Hours, Created_At
FROM xx_archive_log WHERE Statement='Total' AND DATE(Created_At)=CURDATE() ORDER BY RowNum DESC;

SELECT * FROM xx_archive_32713;
SELECT * FROM xx_archive_pk_driver_32713;

-- Control Queries
SELECT 'Prescription IDs' AS Table_NM, 'Source' AS Which, COUNT(*) FROM erx_remedy.prescription_ids                             -- 4155731
UNION ALL SELECT 'Prescription IDs' AS Table_NM, 'Archive' AS Which, COUNT(*) FROM backup_archive.prescription_ids              -- 0
UNION ALL
SELECT 'Prescription' AS Table_NM, 'Source' AS Which, COUNT(*) FROM erx_remedy.prescription                                     -- 370340632
UNION ALL SELECT 'Prescription' AS Table_NM, 'Archive' AS Which, COUNT(*) FROM backup_archive.prescription                      -- 0
UNION ALL
SELECT 'Prescription Log' AS Table_NM, 'Source' AS Which, COUNT(*) FROM erx_remedy.prescription_log                             -- 14143529
UNION ALL SELECT 'Prescription Log' AS Table_NM, 'Archive' AS Which, COUNT(*) FROM backup_archive.prescription_log              -- 0
UNION ALL
SELECT 'Prescription Events' AS Table_NM, 'Source' AS Which, COUNT(*) FROM erx_remedy.prescription_events                       -- 4290735
UNION ALL SELECT 'Prescription Events' AS Table_NM, 'Archive' AS Which, COUNT(*) FROM backup_archive.prescription_events        -- 0
UNION ALL
SELECT 'Patient IDs' AS Table_NM, 'Source' AS Which, COUNT(*) FROM erx_remedy.patient_ids                                       -- 2004446
UNION ALL SELECT 'Patient IDs' AS Table_NM, 'Archive' AS Which, COUNT(*) FROM backup_archive.patient_ids                        -- 0
UNION ALL
SELECT 'Patient' AS Table_NM, 'Source' AS Which, COUNT(*) FROM erx_remedy.patient                                               -- 51118208
UNION ALL SELECT 'Patient' AS Table_NM, 'Archive' AS Which, COUNT(*) FROM backup_archive.patient;                               -- 0
UNION ALL
SELECT 'Patient Log' AS Table_NM, 'Source' AS Which, COUNT(*) FROM erx_remedy.patient_log                                       -- 2799038
UNION ALL SELECT 'Patient Log' AS Table_NM, 'Archive' AS Which, COUNT(*) FROM backup_archive.patient_log;                       -- 0

-- Individual Queries
SELECT * FROM erx_remedy.prescription_ids;
SELECT * FROM backup_archive.prescription_ids;

SELECT * FROM erx_remedy.prescription;
SELECT * FROM backup_archive.prescription;

SELECT * FROM erx_remedy.prescription_log;
SELECT * FROM backup_archive.prescription_log;

SELECT * FROM erx_remedy.prescription_events;
SELECT * FROM backup_archive.prescription_events;

SELECT * FROM erx_remedy.patient_ids;
SELECT * FROM backup_archive.patient_ids;

SELECT * FROM erx_remedy.patient;
SELECT * FROM backup_archive.patient;

SELECT * FROM erx_remedy.patient_log;
SELECT * FROM backup_archive.patient_log;


-- Volume By Month
SELECT DATE_FORMAT(Created_At,'%Y-%m'), COUNT(*)
FROM teladoc_eds.serialized_data_snapshots
GROUP BY DATE_FORMAT(Created_At,'%Y-%m')
ORDER BY 1 DESC;

-- Check
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'CHECK',                                        -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'Y',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription_ids',          -- vArchiveSourceTable
        'backup_archive.prescription_ids',      -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription_ids src ON src.ID=xx.ID',    -- vSelect
        100000,                                 -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected

CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'CHECK',                                        -- vMode ('UP', 'DOWN', 'CHECK')
        'erx_remedy.patient_ids',               -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'Y',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.patient_ids',               -- vArchiveSourceTable
        'backup_archive.patient_ids',           -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.patient_ids src ON src.ID=xx.ID', -- vSelect
        100000,                                 -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
*/



-- DOWN Script
/*
-- 1) Prescription Tables
-- a) Prescription ID
SET @vRedmineNum := 32713;
SET @vArchiveMonths := 55;
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'DOWN',                                 -- vMode ('DOWN', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'Y',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription_ids',          -- vArchiveSourceTable
        'backup_archive.prescription_ids',      -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription_ids src ON src.ID=xx.ID',    -- vSelect
        100000,                                 -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 121499 Rows  -- 60 Sec

-- b) Prescription
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'DOWN',                                 -- vMode ('DOWN', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        NULL,                                   -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription',              -- vArchiveSourceTable
        'backup_archive.prescription',          -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription src ON src.ID=xx.ID',        -- vSelect
        1000,                                   -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 9960294 Rows -- 2:41 Hour

-- c) Prescription Log
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'DOWN',                                 -- vMode ('DOWN', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        NULL,                                   -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription_log',          -- vArchiveSourceTable
        'backup_archive.prescription_log',      -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription_log src ON src.ID=xx.ID',    -- vSelect
        10000,                                  -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 10222632 Rows        -- 1:54 Hour

-- d) Prescription Event
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'DOWN',                                 -- vMode ('DOWN', 'DOWN', 'CHECK')
        'erx_remedy.prescription_ids',          -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'Prescription_ID',                      -- vSourcePK
        NULL,                                   -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.prescription_events',       -- vArchiveSourceTable
        'backup_archive.prescription_events',   -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.prescription_events src ON src.Prescription_ID=xx.ID',    -- vSelect
        10000,                                  -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 8279 Rows            -- 25 Sec


-- 2) Patient Tables
-- a) Patient IDs
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'DOWN',                                 -- vMode ('DOWN', 'DOWN', 'CHECK')
        'erx_remedy.patient_ids',               -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        'Created_At',                           -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'Y',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.patient_ids',               -- vArchiveSourceTable
        'backup_archive.patient_ids',           -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.patient_ids src ON src.ID=xx.ID', -- vSelect
        100000,                                 -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 64653 Rows   -- 19 Sec

-- b) Patient
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'DOWN',                                 -- vMode ('DOWN', 'DOWN', 'CHECK')
        'erx_remedy.patient_ids',               -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        NULL,                                   -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.patient',                   -- vArchiveSourceTable
        'backup_archive.patient',               -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.patient src ON src.ID=xx.ID',     -- vSelect
        5000,                                   -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 1236343 Rows -- 11 Min

-- c) Patient Logs
CALL p_xx_archive_loop(
        @vRedmineNum,                           -- vRedmineNum
        'DOWN',                                 -- vMode ('DOWN', 'DOWN', 'CHECK')
        'erx_remedy.patient_ids',               -- vArchiveDriverTable
        'ID',                                   -- vArchiveDriverPK
        'ID',                                   -- vSourcePK
        NULL,                                   -- vDateColumn
        @vArchiveMonths,                        -- vArchiveMonths
        'N',                                    -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_32713',           -- vTempDriverTable
        'erx_remedy.patient_log',               -- vArchiveSourceTable
        'backup_archive.patient_log',           -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_32713 xx
        INNER JOIN erx_remedy.patient_log src ON src.ID=xx.ID', -- vSelect
        1000,                                   -- vLimitIncrement
        @vRowsAffected);                        -- vRowsAffected
SELECT @vRowsAffected;          -- 2014127 Rows -- 27 Min
*/
