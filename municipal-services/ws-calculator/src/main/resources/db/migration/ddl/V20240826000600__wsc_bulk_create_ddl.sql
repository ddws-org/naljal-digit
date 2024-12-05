
ALTER TABLE eg_ws_bulk_demand_batch DROP COLUMN createdTime;

ALTER TABLE eg_ws_bulk_demand_batch ADD COLUMN createdTime BIGINT NOT NULL;

ALTER TABLE eg_ws_bulk_demand_batch ALTER COLUMN lastModifiedBy TYPE VARCHAR(64);

ALTER TABLE eg_ws_bulk_demand_batch ALTER COLUMN lastModifiedTime SET NOT NULL;
