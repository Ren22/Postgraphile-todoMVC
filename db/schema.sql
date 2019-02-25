SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: app; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app;


--
-- Name: app_hidden; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app_hidden;


--
-- Name: app_private; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app_private;


--
-- Name: postgraphile_watch; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA postgraphile_watch;


--
-- Name: current_user_id(); Type: FUNCTION; Schema: app_hidden; Owner: -
--

CREATE FUNCTION app_hidden.current_user_id() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT nullif(current_setting('user.id', true), '')::text;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: todo; Type: TABLE; Schema: app; Owner: -
--

CREATE TABLE app.todo (
    id integer NOT NULL,
    title text,
    completed boolean DEFAULT false NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id text DEFAULT app_hidden.current_user_id() NOT NULL
);


--
-- Name: COLUMN todo.id; Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON COLUMN app.todo.id IS '@omit create,update';


--
-- Name: COLUMN todo.created_at; Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON COLUMN app.todo.created_at IS '@omit create,update';


--
-- Name: COLUMN todo.updated_at; Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON COLUMN app.todo.updated_at IS '@omit create,update';


--
-- Name: COLUMN todo.user_id; Type: COMMENT; Schema: app; Owner: -
--

COMMENT ON COLUMN app.todo.user_id IS '@omit create,update';


--
-- Name: clear_completed(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.clear_completed() RETURNS SETOF app.todo
    LANGUAGE sql
    AS $$
DELETE FROM app.todo WHERE completed = true RETURNING *;
$$;


--
-- Name: complete_all(); Type: FUNCTION; Schema: app; Owner: -
--

CREATE FUNCTION app.complete_all() RETURNS SETOF app.todo
    LANGUAGE sql
    AS $$
UPDATE app.todo
   SET completed = NOT (SELECT COUNT(*) FROM app.todo WHERE completed = true) = (SELECT COUNT(*) FROM app.todo)
RETURNING *;
$$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$;


--
-- Name: notify_watchers_ddl(); Type: FUNCTION; Schema: postgraphile_watch; Owner: -
--

CREATE FUNCTION postgraphile_watch.notify_watchers_ddl() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform pg_notify(
    'postgraphile_watch',
    json_build_object(
      'type',
      'ddl',
      'payload',
      (select json_agg(json_build_object('schema', schema_name, 'command', command_tag)) from pg_event_trigger_ddl_commands() as x)
    )::text
  );
end;
$$;


--
-- Name: notify_watchers_drop(); Type: FUNCTION; Schema: postgraphile_watch; Owner: -
--

CREATE FUNCTION postgraphile_watch.notify_watchers_drop() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform pg_notify(
    'postgraphile_watch',
    json_build_object(
      'type',
      'drop',
      'payload',
      (select json_agg(distinct x.schema_name) from pg_event_trigger_dropped_objects() as x)
    )::text
  );
end;
$$;


--
-- Name: todo_id_seq; Type: SEQUENCE; Schema: app; Owner: -
--

CREATE SEQUENCE app.todo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: todo_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: -
--

ALTER SEQUENCE app.todo_id_seq OWNED BY app.todo.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: todo id; Type: DEFAULT; Schema: app; Owner: -
--

ALTER TABLE ONLY app.todo ALTER COLUMN id SET DEFAULT nextval('app.todo_id_seq'::regclass);


--
-- Name: todo todo_pkey; Type: CONSTRAINT; Schema: app; Owner: -
--

ALTER TABLE ONLY app.todo
    ADD CONSTRAINT todo_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: todo todo_updated_at; Type: TRIGGER; Schema: app; Owner: -
--

CREATE TRIGGER todo_updated_at BEFORE UPDATE ON app.todo FOR EACH ROW EXECUTE PROCEDURE app_private.set_updated_at();


--
-- Name: postgraphile_watch_ddl; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER postgraphile_watch_ddl ON ddl_command_end
         WHEN TAG IN ('ALTER AGGREGATE', 'ALTER DOMAIN', 'ALTER EXTENSION', 'ALTER FOREIGN TABLE', 'ALTER FUNCTION', 'ALTER POLICY', 'ALTER SCHEMA', 'ALTER TABLE', 'ALTER TYPE', 'ALTER VIEW', 'COMMENT', 'CREATE AGGREGATE', 'CREATE DOMAIN', 'CREATE EXTENSION', 'CREATE FOREIGN TABLE', 'CREATE FUNCTION', 'CREATE INDEX', 'CREATE POLICY', 'CREATE RULE', 'CREATE SCHEMA', 'CREATE TABLE', 'CREATE TABLE AS', 'CREATE VIEW', 'DROP AGGREGATE', 'DROP DOMAIN', 'DROP EXTENSION', 'DROP FOREIGN TABLE', 'DROP FUNCTION', 'DROP INDEX', 'DROP OWNED', 'DROP POLICY', 'DROP RULE', 'DROP SCHEMA', 'DROP TABLE', 'DROP TYPE', 'DROP VIEW', 'GRANT', 'REVOKE', 'SELECT INTO')
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_ddl();


--
-- Name: postgraphile_watch_drop; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER postgraphile_watch_drop ON sql_drop
   EXECUTE PROCEDURE postgraphile_watch.notify_watchers_drop();


--
-- Name: todo delete_todo; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY delete_todo ON app.todo FOR DELETE TO todo_user USING ((user_id = app_hidden.current_user_id()));


--
-- Name: todo insert_todo; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY insert_todo ON app.todo FOR INSERT TO todo_user WITH CHECK ((user_id = app_hidden.current_user_id()));


--
-- Name: todo select_todo; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY select_todo ON app.todo FOR SELECT TO todo_user USING ((user_id = app_hidden.current_user_id()));


--
-- Name: todo; Type: ROW SECURITY; Schema: app; Owner: -
--

ALTER TABLE app.todo ENABLE ROW LEVEL SECURITY;

--
-- Name: todo update_todo; Type: POLICY; Schema: app; Owner: -
--

CREATE POLICY update_todo ON app.todo FOR UPDATE TO todo_user USING ((user_id = app_hidden.current_user_id()));


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20190222030350'),
    ('20190222174947'),
    ('20190223181643'),
    ('20190225022714'),
    ('20190225030150');
