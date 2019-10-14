USE backup_archive;
-- Redmine 33671: Archive

-- Type II: Total Time 26 Min on Prod Slave 2 Port 3308


-- UP Script
SET @vRedmineNum := 33671;
CALL p_xx_archive_loop(
        @vRedmineNum,                                   -- vRedmineNum
        'UP',                                           -- vMode ('UP', 'DOWN', 'CHECK')
        'teladoc_eds.serialized_data_snapshots',        -- vArchiveDriverTable
        'Serialized_Data_Snapshot_ID',                  -- vArchiveDriverPK
        'Serialized_Data_Snapshot_ID',                  -- vSourcePK
        'Created_At',                                   -- vDateColumn
        4,                                              -- vArchiveMonths
        'Y',                                            -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_28896',                   -- vTempDriverTable
        'teladoc_eds.serialized_data_snapshots',        -- vArchiveSourceTable
        'backup_archive.serialized_data_snapshots',     -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_28896 xx
        INNER JOIN teladoc_eds.serialized_data_snapshots src ON src.Serialized_Data_Snapshot_ID=xx.ID', -- vSelect
        10000,                                          -- vLimitIncrement
        @vRowsAffected);                                -- vRowsAffected
SELECT @vRowsAffected;          -- 15 Min -- 251222 Rows



-- Dev Scripts
/*
CALL p_xx_archive_loop(
        @vRedmineNum,                                   -- vRedmineNum
        'CHECK',                                                -- vMode ('UP', 'DOWN', 'CHECK')
        'teladoc_eds.serialized_data_snapshots',        -- vArchiveDriverTable
        'Serialized_Data_Snapshot_ID',                  -- vArchiveDriverPK
        'Serialized_Data_Snapshot_ID',                  -- vSourcePK
        'Created_At',                                   -- vDateColumn
        4,                                              -- vArchiveMonths
        'Y',                                            -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_28896',                   -- vTempDriverTable
        'teladoc_eds.serialized_data_snapshots',        -- vArchiveSourceTable
        'backup_archive.serialized_data_snapshots',     -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_28896 xx
        INNER JOIN teladoc_eds.serialized_data_snapshots src ON src.Serialized_Data_Snapshot_ID=xx.ID', -- vSelect
        10000,                                          -- vLimitIncrement
        @vRowsAffected);                                -- vRowsAffected
*/



-- DOWN Script
/*
SET @vRedmineNum := 33671;
CALL p_xx_archive_loop(
        @vRedmineNum,                                   -- vRedmineNum
        'DOWN',                                         -- vMode ('UP', 'DOWN', 'CHECK')
        'teladoc_eds.serialized_data_snapshots',        -- vArchiveDriverTable
        'Serialized_Data_Snapshot_ID',                  -- vArchiveDriverPK
        'Serialized_Data_Snapshot_ID',                  -- vSourcePK
        'Created_At',                                   -- vDateColumn
        4,                                              -- vArchiveMonths
        'Y',                                            -- vBuildDriverFLG (Y, N, R-Rebuild)
        'xx_archive_pk_driver_28896',                   -- vTempDriverTable
        'teladoc_eds.serialized_data_snapshots',        -- vArchiveSourceTable
        'backup_archive.serialized_data_snapshots',     -- vArchiveTargetTable
        'SELECT src.*
        FROM xx_archive_pk_driver_28896 xx
        INNER JOIN teladoc_eds.serialized_data_snapshots src ON src.Serialized_Data_Snapshot_ID=xx.ID', -- vSelect
        10000,                                          -- vLimitIncrement
        @vRowsAffected);                                -- vRowsAffected
SELECT @vRowsAffected;          -- xx Min -- xx Rows
*/
