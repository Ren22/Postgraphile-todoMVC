-- migrate:up
CREATE SCHEMA app_hidden;
GRANT USAGE ON SCHEMA app_hidden TO todo_anonymous, todo_user;

CREATE OR REPLACE FUNCTION app_hidden.current_user_id() RETURNS text AS $$
  SELECT nullif(current_setting('user.id', true), '')::text;
$$ LANGUAGE sql STABLE;
GRANT EXECUTE ON FUNCTION app_hidden.current_user_id() TO todo_anonymous, todo_user;

DELETE FROM "app"."todo";
ALTER TABLE "app"."todo" ADD COLUMN "user_id" text NOT NULL DEFAULT app_hidden.current_user_id();

-- migrate:down
ALTER TABLE "app"."todo" DROP COLUMN "user_id";
DROP FUNCTION app_hidden.current_user_id();
DROP SCHEMA app_hidden;
