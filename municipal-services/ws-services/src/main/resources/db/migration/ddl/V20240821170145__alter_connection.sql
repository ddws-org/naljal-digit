ALTER TABLE eg_ws_connection ADD COLUMN IF NOT EXISTS imisNumber character varying(64);

ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS imisNumber character varying(64);

ALTER TABLE eg_ws_connection ADD COLUMN IF NOT EXISTS villageId character varying(64);

ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS villageId character varying(64);
