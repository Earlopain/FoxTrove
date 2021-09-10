SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: account_levels; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.account_levels AS ENUM (
    'unactivated',
    'member',
    'admin'
);


--
-- Name: account_permissions; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.account_permissions AS ENUM (
    'delete_artist',
    'request_manual_update',
    'allow_url_moderation'
);


--
-- Name: file_extensions; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.file_extensions AS ENUM (
    'png',
    'jpg',
    'gif',
    'webp'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id bigint NOT NULL,
    username character varying NOT NULL,
    email character varying NOT NULL,
    level public.account_levels DEFAULT 'unactivated'::public.account_levels NOT NULL,
    permissions public.account_permissions[] DEFAULT '{}'::public.account_permissions[] NOT NULL,
    password_digest character varying NOT NULL,
    last_logged_in_at timestamp without time zone NOT NULL,
    last_ip_addr inet NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: artist_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_submissions (
    id bigint NOT NULL,
    artist_url_id bigint NOT NULL,
    identifier_on_site text NOT NULL,
    title_on_site text,
    description_on_site text,
    created_at_on_site timestamp without time zone NOT NULL,
    file_name text NOT NULL,
    file_extension public.file_extensions NOT NULL,
    sha256 text NOT NULL,
    direct_url text,
    width integer NOT NULL,
    height integer NOT NULL,
    size integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: artist_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_submissions_id_seq OWNED BY public.artist_submissions.id;


--
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_urls (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    approver_id bigint,
    artist_id bigint NOT NULL,
    site_id bigint NOT NULL,
    identifier_on_site text NOT NULL,
    created_at_on_site timestamp without time zone NOT NULL,
    about_on_site text NOT NULL,
    scraping_disabled boolean DEFAULT false NOT NULL,
    last_scraped_at timestamp without time zone,
    last_scraped_submission_identifier text,
    sidekiq_job_id text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: artist_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_urls_id_seq OWNED BY public.artist_urls.id;


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artists (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    name text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artists_id_seq OWNED BY public.artists.id;


--
-- Name: moderation_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_logs (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    creator_inet inet NOT NULL,
    loggable_type text NOT NULL,
    loggable_id integer NOT NULL,
    action text NOT NULL,
    payload jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: moderation_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_logs_id_seq OWNED BY public.moderation_logs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id bigint NOT NULL,
    internal_name character varying NOT NULL,
    display_name character varying NOT NULL,
    homepage character varying NOT NULL,
    artist_url_format character varying NOT NULL,
    artist_submission_format character varying NOT NULL,
    direct_url_format character varying NOT NULL,
    allows_hotlinking boolean NOT NULL,
    stores_original boolean NOT NULL,
    original_easily_accessible boolean NOT NULL,
    notes character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: artist_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_submissions ALTER COLUMN id SET DEFAULT nextval('public.artist_submissions_id_seq'::regclass);


--
-- Name: artist_urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls ALTER COLUMN id SET DEFAULT nextval('public.artist_urls_id_seq'::regclass);


--
-- Name: artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists ALTER COLUMN id SET DEFAULT nextval('public.artists_id_seq'::regclass);


--
-- Name: moderation_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_logs ALTER COLUMN id SET DEFAULT nextval('public.moderation_logs_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: artist_submissions artist_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_submissions
    ADD CONSTRAINT artist_submissions_pkey PRIMARY KEY (id);


--
-- Name: artist_urls artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: moderation_logs moderation_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_logs
    ADD CONSTRAINT moderation_logs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: index_accounts_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_email ON public.accounts USING btree (email);


--
-- Name: index_accounts_on_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_level ON public.accounts USING btree (level);


--
-- Name: index_accounts_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_username ON public.accounts USING btree (username);


--
-- Name: index_artist_submissions_on_artist_url_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_submissions_on_artist_url_id ON public.artist_submissions USING btree (artist_url_id);


--
-- Name: index_artist_submissions_on_sha256; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_submissions_on_sha256 ON public.artist_submissions USING btree (sha256);


--
-- Name: index_artist_urls_on_approver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_approver_id ON public.artist_urls USING btree (approver_id);


--
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_artist_id ON public.artist_urls USING btree (artist_id);


--
-- Name: index_artist_urls_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_creator_id ON public.artist_urls USING btree (creator_id);


--
-- Name: index_artist_urls_on_identifier_on_site; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_identifier_on_site ON public.artist_urls USING btree (identifier_on_site);


--
-- Name: index_artist_urls_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_site_id ON public.artist_urls USING btree (site_id);


--
-- Name: index_artists_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_creator_id ON public.artists USING btree (creator_id);


--
-- Name: index_moderation_logs_on_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_logs_on_action ON public.moderation_logs USING btree (action);


--
-- Name: index_moderation_logs_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_logs_on_creator_id ON public.moderation_logs USING btree (creator_id);


--
-- Name: index_moderation_logs_on_creator_inet; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_logs_on_creator_inet ON public.moderation_logs USING btree (creator_inet);


--
-- Name: index_moderation_logs_on_loggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_logs_on_loggable_id ON public.moderation_logs USING btree (loggable_id);


--
-- Name: index_moderation_logs_on_loggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_logs_on_loggable_type ON public.moderation_logs USING btree (loggable_type);


--
-- Name: index_moderation_logs_on_loggable_type_and_loggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_logs_on_loggable_type_and_loggable_id ON public.moderation_logs USING btree (loggable_type, loggable_id);


--
-- Name: index_sites_on_internal_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sites_on_internal_name ON public.sites USING btree (internal_name);


--
-- Name: artist_urls fk_rails_1cc82d4704; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT fk_rails_1cc82d4704 FOREIGN KEY (creator_id) REFERENCES public.accounts(id);


--
-- Name: artist_submissions fk_rails_2ebf31f3af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_submissions
    ADD CONSTRAINT fk_rails_2ebf31f3af FOREIGN KEY (artist_url_id) REFERENCES public.artist_urls(id);


--
-- Name: artists fk_rails_4e3f72966d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT fk_rails_4e3f72966d FOREIGN KEY (creator_id) REFERENCES public.accounts(id);


--
-- Name: artist_urls fk_rails_79347f77be; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT fk_rails_79347f77be FOREIGN KEY (approver_id) REFERENCES public.accounts(id);


--
-- Name: artist_urls fk_rails_830320186c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT fk_rails_830320186c FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: moderation_logs fk_rails_d8dc8b5e52; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_logs
    ADD CONSTRAINT fk_rails_d8dc8b5e52 FOREIGN KEY (creator_id) REFERENCES public.accounts(id);


--
-- Name: artist_urls fk_rails_e4e6c00d41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT fk_rails_e4e6c00d41 FOREIGN KEY (artist_id) REFERENCES public.artists(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20210908132036'),
('20210908142922'),
('20210908165941'),
('20210908173750'),
('20210908174953'),
('20210908181041');


