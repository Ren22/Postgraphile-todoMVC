-- migrate:up
COMMENT ON COLUMN app.todo.id IS E'@omit create,update';
COMMENT ON COLUMN app.todo.created_at IS E'@omit create,update';
COMMENT ON COLUMN app.todo.updated_at IS E'@omit create,update';
COMMENT ON COLUMN app.todo.user_id IS E'@omit create,update';

-- migrate:down
COMMENT ON COLUMN app.todo.id IS E'';
COMMENT ON COLUMN app.todo.created_at IS E'';
COMMENT ON COLUMN app.todo.updated_at IS E'';
COMMENT ON COLUMN app.todo.user_id IS E'';
