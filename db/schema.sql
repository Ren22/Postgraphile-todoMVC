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
-- Name: app_private; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app_private;


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
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


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
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20190222030350');
