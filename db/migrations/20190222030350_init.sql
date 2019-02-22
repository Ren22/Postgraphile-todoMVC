-- migrate:up
CREATE SCHEMA app;
CREATE SCHEMA app_private;
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM public;

CREATE FUNCTION app_private.set_updated_at() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$ language plpgsql;


CREATE TABLE app.todo (
    id SERIAL PRIMARY KEY,
    title TEXT,
    completed BOOLEAN NOT NULL DEFAULT false,
    "order" INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER todo_updated_at BEFORE UPDATE
  ON app.todo
  FOR EACH ROW
  EXECUTE PROCEDURE app_private.set_updated_at();

-- migrate:down
DROP SCHEMA app CASCADE;
DROP SCHEMA app_private CASCADE;
