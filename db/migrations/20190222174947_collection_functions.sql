-- migrate:up
CREATE OR REPLACE FUNCTION app.clear_completed()
RETURNS setof app.todo as $$
DELETE FROM app.todo WHERE completed = true RETURNING *;
$$ language sql VOLATILE;

CREATE OR REPLACE FUNCTION app.complete_all()
RETURNS setof app.todo as $$
UPDATE app.todo
   SET completed = NOT (SELECT COUNT(*) FROM app.todo WHERE completed = true) = (SELECT COUNT(*) FROM app.todo)
RETURNING *;
$$ language sql VOLATILE;

-- migrate:down
DROP FUNCTION app.clear_completed();
DROP FUNCTION app.complete_all();
