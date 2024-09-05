CREATE TABLE IF NOT EXISTS  eg_notification_sms (
    id bigint NOT NULL,
    mobile_no VARCHAR(20) NOT NULL,
    message TEXT,
    category VARCHAR(50),
    template_id VARCHAR(50),
    createdtime bigint,
    tenant_id VARCHAR(50)
);

