ALTER TABLE egbs_bill_v1 ADD COLUMN IF NOT EXISTS consumercode CHARACTER VARYING(256);

UPDATE egbs_bill_v1 b SET consumerCode = bd.consumercode FROM egbs_billdetail_v1 bd WHERE bd.billid = b.id and b.consumercode is null;

ALTER TABLE egbs_bill_v1 ALTER COLUMN consumercode SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS index_egbs_UNIQUE_ACTIVE_BILL ON egbs_bill_v1 (consumercode, tenantid, status) where status='ACTIVE';
