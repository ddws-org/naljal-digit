ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS ihlDetail varchar(256);
ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS sbmAccountno varchar(256);
ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS schemeId varchar(256);
ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS schemeName varchar(256);
