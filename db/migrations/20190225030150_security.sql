-- migrate:up
ALTER TABLE app.todo ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_todo ON app.todo FOR SELECT TO todo_user
  USING (user_id = app_hidden.current_user_id());

CREATE POLICY insert_todo ON app.todo FOR INSERT TO todo_user
  with check (user_id = app_hidden.current_user_id());

CREATE POLICY update_todo ON app.todo FOR UPDATE TO todo_user
  using (user_id = app_hidden.current_user_id());

CREATE POLICY delete_todo ON app.todo FOR DELETE TO todo_user
  using (user_id = app_hidden.current_user_id());

-- migrate:down
DROP POLICY select_todo ON app.todo;
DROP POLICY insert_todo ON app.todo;
DROP POLICY update_todo ON app.todo;
DROP POLICY delete_todo ON app.todo;
ALTER TABLE app.todo DISABLE ROW LEVEL SECURITY;
