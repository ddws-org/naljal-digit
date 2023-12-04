CREATE TABLE IF NOT EXISTS  eg_notification_sms (
    id bigint NOT NULL,
    mobile_no VARCHAR(20) NOT NULL,
    message TEXT,
    category VARCHAR(50),
    template_id VARCHAR(50),
    createdtime bigint,
    tenant_id VARCHAR(50)
);
CREATE SEQUENCE seq_eg_notification_sms
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE eg_notification_sms ADD CONSTRAINT eg_notification_sms_pkey PRIMARY KEY (id);

