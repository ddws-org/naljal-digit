ALTER TABLE eg_ws_connection ADD COLUMN IF NOT EXISTS penalty numeric(12,3);

ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS penalty numeric(12,3);

ALTER TABLE eg_ws_connection ADD COLUMN IF NOT EXISTS advance numeric(12,3);

ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS advance numeric(12,3);

ALTER TABLE eg_ws_connection ADD COLUMN IF NOT EXISTS paymenttype character varying(64);

ALTER TABLE eg_ws_connection_audit ADD COLUMN IF NOT EXISTS paymenttype character varying(64);
