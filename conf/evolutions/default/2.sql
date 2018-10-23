# --- !Ups

ALTER TABLE sm_device ADD "DESCRIBE" VARCHAR NULL;
ALTER TABLE sm_device ADD "VISIBLE" boolean DEFAULT false not null ;


# --- !Downs
ALTER TABLE sm_device DROP "DESCRIBE";
ALTER TABLE sm_device DROP "VISIBLE";
