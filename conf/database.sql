--
-- sudo -u postgres psql -p 55555 -d templatesite_db -f conf/database.sql
--

DROP TABLE IF EXISTS SM_DEVICE CASCADE;
-- delete from "SM_DEVICE";

CREATE TABLE SM_DEVICE (
  "ID" serial PRIMARY KEY,
  "NAME" VARCHAR NOT NULL,
  "LABEL" VARCHAR NOT NULL,
  "UID" VARCHAR NOT NULL,
  "SYNC_DATE" timestamp with time zone not null
);

DROP TABLE IF EXISTS SM_FILE_CARD CASCADE;
-- delete from "sm_file_card";

CREATE TABLE SM_FILE_CARD (
  "ID" VARCHAR PRIMARY KEY NOT NULL,
  "STORE_NAME" VARCHAR NOT NULL,
  "F_PARENT" VARCHAR NOT NULL,
  "F_NAME" VARCHAR NOT NULL,
  "F_EXTENSION" VARCHAR,
  --     "F_CREATION_DATE" TIMESTAMP NOT NULL,
  --     "F_LAST_MODIFIED_DATE" TIMESTAMP NOT NULL,
  "F_CREATION_DATE" timestamp with time zone not null ,
  "F_LAST_MODIFIED_DATE" timestamp with time zone not null,
  "F_SIZE" BIGINT,
  "F_MIME_TYPE_JAVA" VARCHAR,
  "SHA1" VARCHAR
);

CREATE INDEX sha1_idx
  ON public.sm_file_card USING btree
  ("SHA1" COLLATE pg_catalog."default" varchar_pattern_ops ASC NULLS LAST)
WITH (FILLFACTOR=100)
TABLESPACE pg_default;

CREATE INDEX f_parent_idx
  ON public.sm_file_card USING btree
  ("F_PARENT" COLLATE pg_catalog."default" varchar_pattern_ops ASC NULLS LAST)
WITH (FILLFACTOR=100)
TABLESPACE pg_default;

CREATE INDEX last_modified_idx
  ON public.sm_file_card USING btree
  ("F_LAST_MODIFIED_DATE" DESC NULLS LAST)
WITH (FILLFACTOR=100)
TABLESPACE pg_default;




CREATE TABLE SM_PATH_MOVE (
  "ID" serial PRIMARY KEY,
  "STORE_NAME" VARCHAR NOT NULL,
  "PATH_FROM" VARCHAR NOT NULL,
  "PATH_TO" VARCHAR NOT NULL
);

CREATE TABLE SM_CATEGORY_FC (
  "ID"            VARCHAR,
  "F_NAME"        VARCHAR,
  "CATEGORY_TYPE" VARCHAR,
  "DESCRIPTION"   VARCHAR,
  PRIMARY KEY ("ID", "F_NAME")
);


GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sm_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO sm_user;

