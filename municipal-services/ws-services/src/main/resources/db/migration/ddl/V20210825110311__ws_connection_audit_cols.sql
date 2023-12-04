ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS arrears numeric(12,3);

ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS previousReadingDate bigint;