CREATE TABLE IF NOT EXISTS eg_ws_feedback
(
  id character varying(256) NOT NULL,
  connectionno character varying(256),
  paymentid character varying(256),
  billingcycle character varying(256),
  additionaldetails JSONB,
  tenantid character varying(256),
  createdby character varying(64),
  lastmodifiedby character varying(64),
  createdtime bigint,
  lastmodifiedtime bigint,
  CONSTRAINT uk_eg_ws_feedback PRIMARY KEY (id)
  
);


CREATE INDEX index_id_eg_ws_feedback ON eg_ws_feedback
(id);

CREATE INDEX index_connectionno_eg_ws_feedback ON eg_ws_feedback
(connectionno);