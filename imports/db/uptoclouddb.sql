--
-- PostgreSQL database dump
--

-- Dumped from database version 14.3 (Debian 14.3-1.pgdg110+1)
-- Dumped by pg_dump version 14.1

-- Started on 2022-05-25 22:46:42

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 16386)
-- Name: document; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document (
    id bigint NOT NULL,
    resource_name character varying(255) NOT NULL,
    resource_url character varying(255) NOT NULL,
    owner_id character varying(255) NOT NULL
);


ALTER TABLE public.document OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 16385)
-- Name: document_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_id_seq OWNER TO postgres;

--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 209
-- Name: document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_id_seq OWNED BY public.document.id;


--
-- TOC entry 212 (class 1259 OID 16395)
-- Name: document_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_metadata (
    id bigint NOT NULL,
    description text,
    document_id bigint
);


ALTER TABLE public.document_metadata OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16394)
-- Name: document_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.document_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_metadata_id_seq OWNER TO postgres;

--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 211
-- Name: document_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.document_metadata_id_seq OWNED BY public.document_metadata.id;


--
-- TOC entry 213 (class 1259 OID 16403)
-- Name: document_metadata_tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_metadata_tag (
    document_metadata_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.document_metadata_tag OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16408)
-- Name: reading_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reading_permissions (
    document_id bigint NOT NULL,
    reader_id character varying(255) NOT NULL
);


ALTER TABLE public.reading_permissions OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16412)
-- Name: tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tag (
    id bigint NOT NULL,
    name character varying(255)
);


ALTER TABLE public.tag OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16411)
-- Name: tag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tag_id_seq OWNER TO postgres;

--
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 215
-- Name: tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tag_id_seq OWNED BY public.tag.id;


--
-- TOC entry 217 (class 1259 OID 16418)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying(255) NOT NULL,
    container_name character varying(255),
    email character varying(255) NOT NULL,
    username character varying(30) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 3189 (class 2604 OID 16389)
-- Name: document id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document ALTER COLUMN id SET DEFAULT nextval('public.document_id_seq'::regclass);


--
-- TOC entry 3190 (class 2604 OID 16398)
-- Name: document_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_metadata ALTER COLUMN id SET DEFAULT nextval('public.document_metadata_id_seq'::regclass);


--
-- TOC entry 3191 (class 2604 OID 16415)
-- Name: tag id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag ALTER COLUMN id SET DEFAULT nextval('public.tag_id_seq'::regclass);


--
-- TOC entry 3356 (class 0 OID 16386)
-- Dependencies: 210
-- Data for Name: document; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document (id, resource_name, resource_url, owner_id) FROM stdin;
\.


--
-- TOC entry 3358 (class 0 OID 16395)
-- Dependencies: 212
-- Data for Name: document_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document_metadata (id, description, document_id) FROM stdin;
\.


--
-- TOC entry 3359 (class 0 OID 16403)
-- Dependencies: 213
-- Data for Name: document_metadata_tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document_metadata_tag (document_metadata_id, tag_id) FROM stdin;
\.


--
-- TOC entry 3360 (class 0 OID 16408)
-- Dependencies: 214
-- Data for Name: reading_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reading_permissions (document_id, reader_id) FROM stdin;
\.


--
-- TOC entry 3362 (class 0 OID 16412)
-- Dependencies: 216
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tag (id, name) FROM stdin;
\.


--
-- TOC entry 3363 (class 0 OID 16418)
-- Dependencies: 217
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, container_name, email, username) FROM stdin;
\.


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 209
-- Name: document_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.document_id_seq', 1, false);


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 211
-- Name: document_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.document_metadata_id_seq', 1, false);


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 215
-- Name: tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tag_id_seq', 1, false);


--
-- TOC entry 3197 (class 2606 OID 16402)
-- Name: document_metadata document_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_metadata
    ADD CONSTRAINT document_metadata_pkey PRIMARY KEY (id);


--
-- TOC entry 3201 (class 2606 OID 16407)
-- Name: document_metadata_tag document_metadata_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_metadata_tag
    ADD CONSTRAINT document_metadata_tag_pkey PRIMARY KEY (document_metadata_id, tag_id);


--
-- TOC entry 3193 (class 2606 OID 16393)
-- Name: document document_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_pkey PRIMARY KEY (id);


--
-- TOC entry 3195 (class 2606 OID 16426)
-- Name: document document_resource_name_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_resource_name_id_unique UNIQUE (resource_name, owner_id);


--
-- TOC entry 3203 (class 2606 OID 16417)
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- TOC entry 3205 (class 2606 OID 16430)
-- Name: users uk_6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- TOC entry 3199 (class 2606 OID 16428)
-- Name: document_metadata uk_aby6erl03lwkg93fcrxoeux5v; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_metadata
    ADD CONSTRAINT uk_aby6erl03lwkg93fcrxoeux5v UNIQUE (document_id);


--
-- TOC entry 3207 (class 2606 OID 16432)
-- Name: users uk_r43af9ap4edm43mmtq01oddj6; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk_r43af9ap4edm43mmtq01oddj6 UNIQUE (username);


--
-- TOC entry 3209 (class 2606 OID 16424)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3214 (class 2606 OID 16453)
-- Name: reading_permissions FK4q5rqlgho8vfiafrwwktryyxm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_permissions
    ADD CONSTRAINT "FK4q5rqlgho8vfiafrwwktryyxm" FOREIGN KEY (reader_id) REFERENCES public.users(id);


--
-- TOC entry 3212 (class 2606 OID 16443)
-- Name: document_metadata_tag FKdm54pr38k1d8svljr77vxav4q; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_metadata_tag
    ADD CONSTRAINT "FKdm54pr38k1d8svljr77vxav4q" FOREIGN KEY (tag_id) REFERENCES public.tag(id);


--
-- TOC entry 3210 (class 2606 OID 16433)
-- Name: document FKhe3736ydj9odajha3sspor43p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT "FKhe3736ydj9odajha3sspor43p" FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- TOC entry 3215 (class 2606 OID 16458)
-- Name: reading_permissions FKj58vr8ve7flxrakjpn030ieqw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_permissions
    ADD CONSTRAINT "FKj58vr8ve7flxrakjpn030ieqw" FOREIGN KEY (document_id) REFERENCES public.document(id);


--
-- TOC entry 3213 (class 2606 OID 16448)
-- Name: document_metadata_tag FKm4p2mgtfk6upm34nh790bfjl9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_metadata_tag
    ADD CONSTRAINT "FKm4p2mgtfk6upm34nh790bfjl9" FOREIGN KEY (document_metadata_id) REFERENCES public.document_metadata(id);


--
-- TOC entry 3211 (class 2606 OID 16438)
-- Name: document_metadata FKu69emeb62buepn3uxneike4h; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_metadata
    ADD CONSTRAINT "FKu69emeb62buepn3uxneike4h" FOREIGN KEY (document_id) REFERENCES public.document(id);


-- Completed on 2022-05-25 22:46:43

--
-- PostgreSQL database dump complete
--

