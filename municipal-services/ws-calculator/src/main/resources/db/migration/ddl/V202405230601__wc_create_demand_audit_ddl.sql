CREATE TABLE IF NOT EXISTS  eg_ws_demand_auditchange (
    id bigint NOT NULL,
    consumercode VARCHAR(30) NOT NULL,
    tenant_id VARCHAR(50),
    status VARCHAR(50),
    action VARCHAR(100),
    data JSONB,
    createdby VARCHAR(250),
    createdtime  bigint

);
CREATE SEQUENCE seq_eg_ws_demand_auditchange
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE eg_ws_demand_auditchange ADD CONSTRAINT eg_ws_demand_auditchange_pkey PRIMARY KEY (id);