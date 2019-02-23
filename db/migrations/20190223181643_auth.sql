-- migrate:up
CREATE ROLE todo_anonymous;
CREATE ROLE todo_user;

GRANT USAGE ON SCHEMA app TO todo_anonymous, todo_user;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app.todo TO todo_user;
GRANT USAGE ON SEQUENCE app.todo_id_seq to todo_user;

-- migrate:down
DROP OWNED BY todo_anonymous CASCADE;
DROP ROLE todo_anonymous;

DROP OWNED BY todo_user CASCADE;
DROP ROLE todo_user;
