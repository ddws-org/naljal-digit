CREATE TABLE IF NOT EXISTS eg_ws_bulk_demand_batch
(
  id VARCHAR(64) PRIMARY KEY,
  tenantId VARCHAR(64) NOT NULL,
  billingPeriod VARCHAR(64) NOT NULL,
  createdTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(50) NOT NULL,
  createdBy character varying(64) NOT NULL,
  lastModifiedBy bigint NOT NULL,
  lastModifiedTime bigint
);
CREATE SEQUENCE seq_eg_ws_bulk_demand_batch
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE eg_ws_bulk_demand_batch ALTER COLUMN id SET DEFAULT nextval('seq_eg_ws_bulk_demand_batch'::regclass);

CREATE INDEX IF NOT EXISTS index_eg_ws_bulk_demand_batch_tenantId ON eg_ws_bulk_demand_batch (tenantId);
CREATE INDEX IF NOT EXISTS index_eg_ws_bulk_demand_batch_billingPeriod ON eg_ws_bulk_demand_batch (billingPeriod);
