ALTER USER root IDENTIFIED WITH mysql_native_password BY 'passwd';

ALTER USER '[USERNAME]'@'[HOST]'  IDENTIFIED WITH mysql_native_password  BY '[PASSWORD]';


-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS rvrbt;

-- Use the created database
USE rvrbt;

-- Create version table
CREATE TABLE IF NOT EXISTS `version` (
    `id` INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL,
    `table_name` VARCHAR(32) NOT NULL,
    `table_version` INT UNSIGNED DEFAULT 0 NOT NULL,
    CONSTRAINT table_name_idx UNIQUE (`table_name`)
);

-- Insert initial version info for the version table
INSERT INTO version (table_name, table_version)
VALUES ('version', '1')
ON DUPLICATE KEY UPDATE table_version = '1';

-- Create sip_trace table
CREATE TABLE IF NOT EXISTS `sip_trace` (
    `id` INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL,
    `time_stamp` DATETIME DEFAULT '2000-01-01 00:00:01' NOT NULL,
    `time_us` INT UNSIGNED DEFAULT 0 NOT NULL,
    `callid` VARCHAR(255) DEFAULT '' NOT NULL,
    `traced_user` VARCHAR(255) DEFAULT '' NOT NULL,
    `msg` MEDIUMTEXT NOT NULL,
    `method` VARCHAR(50) DEFAULT '' NOT NULL,
    `status` VARCHAR(255) DEFAULT '' NOT NULL,
    `fromip` VARCHAR(64) DEFAULT '' NOT NULL,
    `toip` VARCHAR(64) DEFAULT '' NOT NULL,
    `fromtag` VARCHAR(128) DEFAULT '' NOT NULL,
    `totag` VARCHAR(128) DEFAULT '' NOT NULL,
    `direction` VARCHAR(4) DEFAULT '' NOT NULL
);

-- Create indexes for sip_trace table
CREATE INDEX IF NOT EXISTS traced_user_idx ON sip_trace (`traced_user`);
CREATE INDEX IF NOT EXISTS date_idx ON sip_trace (`time_stamp`);
CREATE INDEX IF NOT EXISTS fromip_idx ON sip_trace (`fromip`);
CREATE INDEX IF NOT EXISTS callid_idx ON sip_trace (`callid`);

-- Insert version info for the sip_trace table
INSERT INTO version (table_name, table_version)
VALUES ('sip_trace', '4')
ON DUPLICATE KEY UPDATE table_version = '4';
