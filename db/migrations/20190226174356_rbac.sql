-- migrate:up
GRANT todo_user TO todo_graphile;
GRANT todo_anonymous TO todo_graphile;


REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLE app.todo FROM todo_user;

GRANT SELECT ON app.todo TO todo_user;
GRANT INSERT (title, completed, "order") ON app.todo TO todo_user;
GRANT UPDATE (title, completed, "order") ON app.todo TO todo_user;
GRANT DELETE ON app.todo TO todo_user;

COMMENT ON COLUMN app.todo.id IS E'';
COMMENT ON COLUMN app.todo.created_at IS E'';
COMMENT ON COLUMN app.todo.updated_at IS E'';
COMMENT ON COLUMN app.todo.user_id IS E'';

-- migrate:down
REVOKE todo_user FROM todo_graphile;
REVOKE todo_anonymous FROM todo_graphile;

REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLE app.todo FROM todo_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app.todo TO todo_user;
