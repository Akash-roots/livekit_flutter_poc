--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2025-06-29 10:56:34

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 17564)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 233 (class 1259 OID 21848)
-- Name: class_students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class_students (
    id integer NOT NULL,
    class_id integer NOT NULL,
    student_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.class_students OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 21847)
-- Name: class_students_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.class_students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.class_students_id_seq OWNER TO postgres;

--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 232
-- Name: class_students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.class_students_id_seq OWNED BY public.class_students.id;


--
-- TOC entry 231 (class 1259 OID 21836)
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    id integer NOT NULL,
    name character varying(255),
    teacher_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 21835)
-- Name: classes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.classes_id_seq OWNER TO postgres;

--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 230
-- Name: classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.classes_id_seq OWNED BY public.classes.id;


--
-- TOC entry 228 (class 1259 OID 17441)
-- Name: courses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.courses (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    teacher_id integer NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.courses OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17440)
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.courses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.courses_id_seq OWNER TO postgres;

--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 227
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.courses_id_seq OWNED BY public.courses.id;


--
-- TOC entry 235 (class 1259 OID 22718)
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    room_id uuid NOT NULL,
    sender_id integer NOT NULL,
    receiver_id integer NOT NULL,
    message text NOT NULL,
    message_type character varying(255) DEFAULT 'text'::character varying,
    created_at timestamp with time zone
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 22717)
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO postgres;

--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 234
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- TOC entry 219 (class 1259 OID 17343)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17342)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 218
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- TOC entry 229 (class 1259 OID 17531)
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user1_id integer NOT NULL,
    user2_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17393)
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id integer NOT NULL,
    user_id integer NOT NULL,
    full_name character varying(255),
    dob date,
    gender character varying(255),
    language_preference character varying(255),
    address text,
    guardian_name character varying(255),
    guardian_contact character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17392)
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.students_id_seq OWNER TO postgres;

--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 225
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- TOC entry 224 (class 1259 OID 17379)
-- Name: teachers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teachers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    full_name character varying(255) NOT NULL,
    bio text,
    qualifications character varying(255),
    languages character varying(255),
    profile_picture character varying(255),
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.teachers OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17378)
-- Name: teachers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teachers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teachers_id_seq OWNER TO postgres;

--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 223
-- Name: teachers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teachers_id_seq OWNED BY public.teachers.id;


--
-- TOC entry 222 (class 1259 OID 17363)
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    created_at timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17352)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password text NOT NULL,
    status character varying(255) DEFAULT 'active'::character varying,
    last_login timestamp with time zone,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17351)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4830 (class 2604 OID 21851)
-- Name: class_students id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_students ALTER COLUMN id SET DEFAULT nextval('public.class_students_id_seq'::regclass);


--
-- TOC entry 4829 (class 2604 OID 21839)
-- Name: classes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes ALTER COLUMN id SET DEFAULT nextval('public.classes_id_seq'::regclass);


--
-- TOC entry 4827 (class 2604 OID 17444)
-- Name: courses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses ALTER COLUMN id SET DEFAULT nextval('public.courses_id_seq'::regclass);


--
-- TOC entry 4831 (class 2604 OID 22721)
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- TOC entry 4822 (class 2604 OID 17346)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- TOC entry 4826 (class 2604 OID 17396)
-- Name: students id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- TOC entry 4825 (class 2604 OID 17382)
-- Name: teachers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers ALTER COLUMN id SET DEFAULT nextval('public.teachers_id_seq'::regclass);


--
-- TOC entry 4823 (class 2604 OID 17355)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5283 (class 0 OID 21848)
-- Dependencies: 233
-- Data for Name: class_students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.class_students (id, class_id, student_id, created_at) FROM stdin;
3	1	2	2025-06-28 12:13:46.559+05:30
4	2	2	2025-06-28 12:15:34.867+05:30
\.


--
-- TOC entry 5281 (class 0 OID 21836)
-- Dependencies: 231
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classes (id, name, teacher_id, created_at) FROM stdin;
1	English	5	2025-06-26 22:09:25.482+05:30
2	Test Create Class	5	2025-06-28 12:14:54.007+05:30
\.


--
-- TOC entry 5278 (class 0 OID 17441)
-- Dependencies: 228
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.courses (id, title, description, teacher_id, "createdAt", "updatedAt") FROM stdin;
\.


--
-- TOC entry 5285 (class 0 OID 22718)
-- Dependencies: 235
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, room_id, sender_id, receiver_id, message, message_type, created_at) FROM stdin;
10	210a7a4c-948e-4be3-aa84-46395ed2da6b	8	5	hi	text	2025-06-28 11:24:18.594+05:30
12	210a7a4c-948e-4be3-aa84-46395ed2da6b	5	8	hi	text	2025-06-28 11:31:18.813+05:30
\.


--
-- TOC entry 5269 (class 0 OID 17343)
-- Dependencies: 219
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name) FROM stdin;
1	student
3	admin
2	teacher
\.


--
-- TOC entry 5279 (class 0 OID 17531)
-- Dependencies: 229
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (id, user1_id, user2_id, created_at) FROM stdin;
210a7a4c-948e-4be3-aa84-46395ed2da6b	5	8	2025-06-24 21:53:49.806+05:30
6d3a501d-1865-4f0d-a85c-5dac3fb742bd	6	8	2025-06-24 22:05:48.232+05:30
\.


--
-- TOC entry 5276 (class 0 OID 17393)
-- Dependencies: 226
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, user_id, full_name, dob, gender, language_preference, address, guardian_name, guardian_contact, "createdAt", "updatedAt") FROM stdin;
1	1	string	2025-05-27	string	string	string	string	string	2025-05-27 21:14:35.863+05:30	2025-05-27 21:14:35.863+05:30
2	8	test	2025-06-18	male	Engisdh	dsafjdk	dksjjh	skkjh	2025-06-18 20:54:03.396+05:30	2025-06-18 20:54:03.396+05:30
\.


--
-- TOC entry 5274 (class 0 OID 17379)
-- Dependencies: 224
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teachers (id, user_id, full_name, bio, qualifications, languages, profile_picture, created_at) FROM stdin;
1	3	string	string	string	string	string	2025-05-27 21:16:35.014+05:30
2	4	string	string	string	string	string	2025-05-27 21:29:14.093+05:30
9	5	Rita Sharma	Experienced Math teacher with 10+ years of teaching high school students.	M.Sc. Mathematics, B.Ed.	English, Hindi	https://example.com/images/rita.jpg	2025-06-17 21:40:21.7+05:30
10	6	Rajiv Menon	Physics enthusiast, passionate about helping students understand the laws of nature.'	M.Sc. Physics	English, Malayalam	https://example.com/images/rajiv.jpg	2025-06-17 21:40:53.669+05:30
11	7	Anjali Verma	English teacher focusing on literature and creative writing.'	M.A. English, B.Ed.	English, Hindi	https://example.com/images/anjali.jpg	2025-06-17 21:41:07.783+05:30
\.


--
-- TOC entry 5272 (class 0 OID 17363)
-- Dependencies: 222
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (created_at, user_id, role_id) FROM stdin;
2025-05-27 21:29:14.086+05:30	4	2
2025-06-17 21:40:21.692+05:30	5	2
2025-06-17 21:40:53.664+05:30	6	2
2025-06-17 21:41:07.778+05:30	7	2
2025-06-18 20:54:03.383+05:30	8	1
\.


--
-- TOC entry 5271 (class 0 OID 17352)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, status, last_login, created_at) FROM stdin;
1	user123@example.com	$2b$10$N2dhcLNOhurlnXGpjiuc2.cRkD3EzGEfkcOU3qRqskweZVbebnoiq	active	\N	2025-05-27 21:14:35.622+05:30
3	user456@example.com	$2b$10$rVbg1r/Uy470qfL8XH7htuLnnDqEYf6vXnu2Hq6KES0yKcunt.IWu	active	\N	2025-05-27 21:16:34.957+05:30
4	user987@example.com	$2b$10$Krb9HxHIXTGhZLOvzoqTzewTUDgmVwrv80daloIrkGX2lZsmgqPW2	active	\N	2025-05-27 21:29:14.03+05:30
5	rita@gmail.com	$2b$10$k6AM58v.AufsBE8U.sTZ2OcQsj7K2w40KOJbVyZYQAVXufOzzyjyi	active	\N	2025-06-17 21:40:21.488+05:30
6	ragiv@gmail.com	$2b$10$9.KVAO3Ab/v09FxoH5J6vOu25a5fht8KQrpeFNoqcyv2riM5QOAoi	active	\N	2025-06-17 21:40:53.588+05:30
7	aAnjali@gmail.com	$2b$10$lsrTyqS0PK3nhb.IhwCIb.dBsdHv86UXcHB2tOkW.ZZ7VEx86dUcq	active	\N	2025-06-17 21:41:07.707+05:30
8	teststudent@gmail.com	$2b$10$Dg20KR04gwPYZnvvTweqQeVNzZENL22AsoDXjIGvfkXdQHE/JkCsC	active	\N	2025-06-18 20:54:03.186+05:30
\.


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 232
-- Name: class_students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.class_students_id_seq', 4, true);


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 230
-- Name: classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.classes_id_seq', 2, true);


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 227
-- Name: courses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.courses_id_seq', 1, false);


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 234
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 12, true);


--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 218
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 1, false);


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 225
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_id_seq', 2, true);


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 223
-- Name: teachers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teachers_id_seq', 11, true);


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 8, true);


--
-- TOC entry 5106 (class 2606 OID 21855)
-- Name: class_students class_students_class_id_student_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_students
    ADD CONSTRAINT class_students_class_id_student_id_key UNIQUE (class_id, student_id);


--
-- TOC entry 5108 (class 2606 OID 21853)
-- Name: class_students class_students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_students
    ADD CONSTRAINT class_students_pkey PRIMARY KEY (id);


--
-- TOC entry 5104 (class 2606 OID 21841)
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- TOC entry 5100 (class 2606 OID 17448)
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- TOC entry 5110 (class 2606 OID 22726)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- TOC entry 4834 (class 2606 OID 28197)
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- TOC entry 4836 (class 2606 OID 28199)
-- Name: roles roles_name_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key1 UNIQUE (name);


--
-- TOC entry 4838 (class 2606 OID 28213)
-- Name: roles roles_name_key10; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key10 UNIQUE (name);


--
-- TOC entry 4840 (class 2606 OID 28215)
-- Name: roles roles_name_key11; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key11 UNIQUE (name);


--
-- TOC entry 4842 (class 2606 OID 28191)
-- Name: roles roles_name_key12; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key12 UNIQUE (name);


--
-- TOC entry 4844 (class 2606 OID 28217)
-- Name: roles roles_name_key13; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key13 UNIQUE (name);


--
-- TOC entry 4846 (class 2606 OID 28189)
-- Name: roles roles_name_key14; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key14 UNIQUE (name);


--
-- TOC entry 4848 (class 2606 OID 28219)
-- Name: roles roles_name_key15; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key15 UNIQUE (name);


--
-- TOC entry 4850 (class 2606 OID 28221)
-- Name: roles roles_name_key16; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key16 UNIQUE (name);


--
-- TOC entry 4852 (class 2606 OID 28223)
-- Name: roles roles_name_key17; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key17 UNIQUE (name);


--
-- TOC entry 4854 (class 2606 OID 28187)
-- Name: roles roles_name_key18; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key18 UNIQUE (name);


--
-- TOC entry 4856 (class 2606 OID 28225)
-- Name: roles roles_name_key19; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key19 UNIQUE (name);


--
-- TOC entry 4858 (class 2606 OID 28201)
-- Name: roles roles_name_key2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key2 UNIQUE (name);


--
-- TOC entry 4860 (class 2606 OID 28185)
-- Name: roles roles_name_key20; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key20 UNIQUE (name);


--
-- TOC entry 4862 (class 2606 OID 28227)
-- Name: roles roles_name_key21; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key21 UNIQUE (name);


--
-- TOC entry 4864 (class 2606 OID 28183)
-- Name: roles roles_name_key22; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key22 UNIQUE (name);


--
-- TOC entry 4866 (class 2606 OID 28229)
-- Name: roles roles_name_key23; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key23 UNIQUE (name);


--
-- TOC entry 4868 (class 2606 OID 28181)
-- Name: roles roles_name_key24; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key24 UNIQUE (name);


--
-- TOC entry 4870 (class 2606 OID 28231)
-- Name: roles roles_name_key25; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key25 UNIQUE (name);


--
-- TOC entry 4872 (class 2606 OID 28233)
-- Name: roles roles_name_key26; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key26 UNIQUE (name);


--
-- TOC entry 4874 (class 2606 OID 28179)
-- Name: roles roles_name_key27; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key27 UNIQUE (name);


--
-- TOC entry 4876 (class 2606 OID 28235)
-- Name: roles roles_name_key28; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key28 UNIQUE (name);


--
-- TOC entry 4878 (class 2606 OID 28129)
-- Name: roles roles_name_key29; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key29 UNIQUE (name);


--
-- TOC entry 4880 (class 2606 OID 28203)
-- Name: roles roles_name_key3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key3 UNIQUE (name);


--
-- TOC entry 4882 (class 2606 OID 28177)
-- Name: roles roles_name_key30; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key30 UNIQUE (name);


--
-- TOC entry 4884 (class 2606 OID 28131)
-- Name: roles roles_name_key31; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key31 UNIQUE (name);


--
-- TOC entry 4886 (class 2606 OID 28175)
-- Name: roles roles_name_key32; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key32 UNIQUE (name);


--
-- TOC entry 4888 (class 2606 OID 28173)
-- Name: roles roles_name_key33; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key33 UNIQUE (name);


--
-- TOC entry 4890 (class 2606 OID 28133)
-- Name: roles roles_name_key34; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key34 UNIQUE (name);


--
-- TOC entry 4892 (class 2606 OID 28171)
-- Name: roles roles_name_key35; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key35 UNIQUE (name);


--
-- TOC entry 4894 (class 2606 OID 28169)
-- Name: roles roles_name_key36; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key36 UNIQUE (name);


--
-- TOC entry 4896 (class 2606 OID 28135)
-- Name: roles roles_name_key37; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key37 UNIQUE (name);


--
-- TOC entry 4898 (class 2606 OID 28167)
-- Name: roles roles_name_key38; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key38 UNIQUE (name);


--
-- TOC entry 4900 (class 2606 OID 28165)
-- Name: roles roles_name_key39; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key39 UNIQUE (name);


--
-- TOC entry 4902 (class 2606 OID 28205)
-- Name: roles roles_name_key4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key4 UNIQUE (name);


--
-- TOC entry 4904 (class 2606 OID 28137)
-- Name: roles roles_name_key40; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key40 UNIQUE (name);


--
-- TOC entry 4906 (class 2606 OID 28139)
-- Name: roles roles_name_key41; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key41 UNIQUE (name);


--
-- TOC entry 4908 (class 2606 OID 28163)
-- Name: roles roles_name_key42; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key42 UNIQUE (name);


--
-- TOC entry 4910 (class 2606 OID 28141)
-- Name: roles roles_name_key43; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key43 UNIQUE (name);


--
-- TOC entry 4912 (class 2606 OID 28161)
-- Name: roles roles_name_key44; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key44 UNIQUE (name);


--
-- TOC entry 4914 (class 2606 OID 28143)
-- Name: roles roles_name_key45; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key45 UNIQUE (name);


--
-- TOC entry 4916 (class 2606 OID 28159)
-- Name: roles roles_name_key46; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key46 UNIQUE (name);


--
-- TOC entry 4918 (class 2606 OID 28145)
-- Name: roles roles_name_key47; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key47 UNIQUE (name);


--
-- TOC entry 4920 (class 2606 OID 28157)
-- Name: roles roles_name_key48; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key48 UNIQUE (name);


--
-- TOC entry 4922 (class 2606 OID 28147)
-- Name: roles roles_name_key49; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key49 UNIQUE (name);


--
-- TOC entry 4924 (class 2606 OID 28207)
-- Name: roles roles_name_key5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key5 UNIQUE (name);


--
-- TOC entry 4926 (class 2606 OID 28155)
-- Name: roles roles_name_key50; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key50 UNIQUE (name);


--
-- TOC entry 4928 (class 2606 OID 28149)
-- Name: roles roles_name_key51; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key51 UNIQUE (name);


--
-- TOC entry 4930 (class 2606 OID 28153)
-- Name: roles roles_name_key52; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key52 UNIQUE (name);


--
-- TOC entry 4932 (class 2606 OID 28151)
-- Name: roles roles_name_key53; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key53 UNIQUE (name);


--
-- TOC entry 4934 (class 2606 OID 28127)
-- Name: roles roles_name_key54; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key54 UNIQUE (name);


--
-- TOC entry 4936 (class 2606 OID 28237)
-- Name: roles roles_name_key55; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key55 UNIQUE (name);


--
-- TOC entry 4938 (class 2606 OID 28125)
-- Name: roles roles_name_key56; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key56 UNIQUE (name);


--
-- TOC entry 4940 (class 2606 OID 28239)
-- Name: roles roles_name_key57; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key57 UNIQUE (name);


--
-- TOC entry 4942 (class 2606 OID 28123)
-- Name: roles roles_name_key58; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key58 UNIQUE (name);


--
-- TOC entry 4944 (class 2606 OID 28241)
-- Name: roles roles_name_key59; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key59 UNIQUE (name);


--
-- TOC entry 4946 (class 2606 OID 28195)
-- Name: roles roles_name_key6; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key6 UNIQUE (name);


--
-- TOC entry 4948 (class 2606 OID 28121)
-- Name: roles roles_name_key60; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key60 UNIQUE (name);


--
-- TOC entry 4950 (class 2606 OID 28243)
-- Name: roles roles_name_key61; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key61 UNIQUE (name);


--
-- TOC entry 4952 (class 2606 OID 28119)
-- Name: roles roles_name_key62; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key62 UNIQUE (name);


--
-- TOC entry 4954 (class 2606 OID 28245)
-- Name: roles roles_name_key63; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key63 UNIQUE (name);


--
-- TOC entry 4956 (class 2606 OID 28209)
-- Name: roles roles_name_key7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key7 UNIQUE (name);


--
-- TOC entry 4958 (class 2606 OID 28193)
-- Name: roles roles_name_key8; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key8 UNIQUE (name);


--
-- TOC entry 4960 (class 2606 OID 28211)
-- Name: roles roles_name_key9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key9 UNIQUE (name);


--
-- TOC entry 4962 (class 2606 OID 17348)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5102 (class 2606 OID 17537)
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 17400)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 5096 (class 2606 OID 17386)
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);


--
-- TOC entry 5094 (class 2606 OID 17367)
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- TOC entry 4964 (class 2606 OID 28371)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4966 (class 2606 OID 28373)
-- Name: users users_email_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key1 UNIQUE (email);


--
-- TOC entry 4968 (class 2606 OID 28261)
-- Name: users users_email_key10; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key10 UNIQUE (email);


--
-- TOC entry 4970 (class 2606 OID 28263)
-- Name: users users_email_key11; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key11 UNIQUE (email);


--
-- TOC entry 4972 (class 2606 OID 28333)
-- Name: users users_email_key12; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key12 UNIQUE (email);


--
-- TOC entry 4974 (class 2606 OID 28265)
-- Name: users users_email_key13; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key13 UNIQUE (email);


--
-- TOC entry 4976 (class 2606 OID 28331)
-- Name: users users_email_key14; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key14 UNIQUE (email);


--
-- TOC entry 4978 (class 2606 OID 28267)
-- Name: users users_email_key15; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key15 UNIQUE (email);


--
-- TOC entry 4980 (class 2606 OID 28269)
-- Name: users users_email_key16; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key16 UNIQUE (email);


--
-- TOC entry 4982 (class 2606 OID 28337)
-- Name: users users_email_key17; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key17 UNIQUE (email);


--
-- TOC entry 4984 (class 2606 OID 28329)
-- Name: users users_email_key18; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key18 UNIQUE (email);


--
-- TOC entry 4986 (class 2606 OID 28339)
-- Name: users users_email_key19; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key19 UNIQUE (email);


--
-- TOC entry 4988 (class 2606 OID 28249)
-- Name: users users_email_key2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key2 UNIQUE (email);


--
-- TOC entry 4990 (class 2606 OID 28327)
-- Name: users users_email_key20; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key20 UNIQUE (email);


--
-- TOC entry 4992 (class 2606 OID 28341)
-- Name: users users_email_key21; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key21 UNIQUE (email);


--
-- TOC entry 4994 (class 2606 OID 28273)
-- Name: users users_email_key22; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key22 UNIQUE (email);


--
-- TOC entry 4996 (class 2606 OID 28343)
-- Name: users users_email_key23; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key23 UNIQUE (email);


--
-- TOC entry 4998 (class 2606 OID 28271)
-- Name: users users_email_key24; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key24 UNIQUE (email);


--
-- TOC entry 5000 (class 2606 OID 28345)
-- Name: users users_email_key25; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key25 UNIQUE (email);


--
-- TOC entry 5002 (class 2606 OID 28347)
-- Name: users users_email_key26; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key26 UNIQUE (email);


--
-- TOC entry 5004 (class 2606 OID 28367)
-- Name: users users_email_key27; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key27 UNIQUE (email);


--
-- TOC entry 5006 (class 2606 OID 28349)
-- Name: users users_email_key28; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key28 UNIQUE (email);


--
-- TOC entry 5008 (class 2606 OID 28365)
-- Name: users users_email_key29; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key29 UNIQUE (email);


--
-- TOC entry 5010 (class 2606 OID 28251)
-- Name: users users_email_key3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key3 UNIQUE (email);


--
-- TOC entry 5012 (class 2606 OID 28363)
-- Name: users users_email_key30; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key30 UNIQUE (email);


--
-- TOC entry 5014 (class 2606 OID 28351)
-- Name: users users_email_key31; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key31 UNIQUE (email);


--
-- TOC entry 5016 (class 2606 OID 28355)
-- Name: users users_email_key32; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key32 UNIQUE (email);


--
-- TOC entry 5018 (class 2606 OID 28361)
-- Name: users users_email_key33; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key33 UNIQUE (email);


--
-- TOC entry 5020 (class 2606 OID 28357)
-- Name: users users_email_key34; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key34 UNIQUE (email);


--
-- TOC entry 5022 (class 2606 OID 28359)
-- Name: users users_email_key35; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key35 UNIQUE (email);


--
-- TOC entry 5024 (class 2606 OID 28325)
-- Name: users users_email_key36; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key36 UNIQUE (email);


--
-- TOC entry 5026 (class 2606 OID 28283)
-- Name: users users_email_key37; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key37 UNIQUE (email);


--
-- TOC entry 5028 (class 2606 OID 28323)
-- Name: users users_email_key38; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key38 UNIQUE (email);


--
-- TOC entry 5030 (class 2606 OID 28353)
-- Name: users users_email_key39; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key39 UNIQUE (email);


--
-- TOC entry 5032 (class 2606 OID 28253)
-- Name: users users_email_key4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key4 UNIQUE (email);


--
-- TOC entry 5034 (class 2606 OID 28285)
-- Name: users users_email_key40; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key40 UNIQUE (email);


--
-- TOC entry 5036 (class 2606 OID 28321)
-- Name: users users_email_key41; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key41 UNIQUE (email);


--
-- TOC entry 5038 (class 2606 OID 28319)
-- Name: users users_email_key42; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key42 UNIQUE (email);


--
-- TOC entry 5040 (class 2606 OID 28287)
-- Name: users users_email_key43; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key43 UNIQUE (email);


--
-- TOC entry 5042 (class 2606 OID 28317)
-- Name: users users_email_key44; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key44 UNIQUE (email);


--
-- TOC entry 5044 (class 2606 OID 28289)
-- Name: users users_email_key45; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key45 UNIQUE (email);


--
-- TOC entry 5046 (class 2606 OID 28315)
-- Name: users users_email_key46; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key46 UNIQUE (email);


--
-- TOC entry 5048 (class 2606 OID 28291)
-- Name: users users_email_key47; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key47 UNIQUE (email);


--
-- TOC entry 5050 (class 2606 OID 28313)
-- Name: users users_email_key48; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key48 UNIQUE (email);


--
-- TOC entry 5052 (class 2606 OID 28293)
-- Name: users users_email_key49; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key49 UNIQUE (email);


--
-- TOC entry 5054 (class 2606 OID 28255)
-- Name: users users_email_key5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key5 UNIQUE (email);


--
-- TOC entry 5056 (class 2606 OID 28311)
-- Name: users users_email_key50; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key50 UNIQUE (email);


--
-- TOC entry 5058 (class 2606 OID 28295)
-- Name: users users_email_key51; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key51 UNIQUE (email);


--
-- TOC entry 5060 (class 2606 OID 28309)
-- Name: users users_email_key52; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key52 UNIQUE (email);


--
-- TOC entry 5062 (class 2606 OID 28297)
-- Name: users users_email_key53; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key53 UNIQUE (email);


--
-- TOC entry 5064 (class 2606 OID 28307)
-- Name: users users_email_key54; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key54 UNIQUE (email);


--
-- TOC entry 5066 (class 2606 OID 28299)
-- Name: users users_email_key55; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key55 UNIQUE (email);


--
-- TOC entry 5068 (class 2606 OID 28305)
-- Name: users users_email_key56; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key56 UNIQUE (email);


--
-- TOC entry 5070 (class 2606 OID 28301)
-- Name: users users_email_key57; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key57 UNIQUE (email);


--
-- TOC entry 5072 (class 2606 OID 28303)
-- Name: users users_email_key58; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key58 UNIQUE (email);


--
-- TOC entry 5074 (class 2606 OID 28275)
-- Name: users users_email_key59; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key59 UNIQUE (email);


--
-- TOC entry 5076 (class 2606 OID 28369)
-- Name: users users_email_key6; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key6 UNIQUE (email);


--
-- TOC entry 5078 (class 2606 OID 28281)
-- Name: users users_email_key60; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key60 UNIQUE (email);


--
-- TOC entry 5080 (class 2606 OID 28277)
-- Name: users users_email_key61; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key61 UNIQUE (email);


--
-- TOC entry 5082 (class 2606 OID 28279)
-- Name: users users_email_key62; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key62 UNIQUE (email);


--
-- TOC entry 5084 (class 2606 OID 28375)
-- Name: users users_email_key63; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key63 UNIQUE (email);


--
-- TOC entry 5086 (class 2606 OID 28257)
-- Name: users users_email_key7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key7 UNIQUE (email);


--
-- TOC entry 5088 (class 2606 OID 28259)
-- Name: users users_email_key8; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key8 UNIQUE (email);


--
-- TOC entry 5090 (class 2606 OID 28335)
-- Name: users users_email_key9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key9 UNIQUE (email);


--
-- TOC entry 5092 (class 2606 OID 17360)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5119 (class 2606 OID 28405)
-- Name: class_students class_students_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_students
    ADD CONSTRAINT class_students_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5120 (class 2606 OID 28410)
-- Name: class_students class_students_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class_students
    ADD CONSTRAINT class_students_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5118 (class 2606 OID 28400)
-- Name: classes classes_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- TOC entry 5115 (class 2606 OID 17449)
-- Name: courses courses_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5116 (class 2606 OID 28415)
-- Name: rooms fk_user1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT fk_user1 FOREIGN KEY (user1_id) REFERENCES public.users(id);


--
-- TOC entry 5117 (class 2606 OID 28420)
-- Name: rooms fk_user2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT fk_user2 FOREIGN KEY (user2_id) REFERENCES public.users(id);


--
-- TOC entry 5121 (class 2606 OID 28393)
-- Name: messages messages_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- TOC entry 5122 (class 2606 OID 28388)
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- TOC entry 5114 (class 2606 OID 28378)
-- Name: students students_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5113 (class 2606 OID 28383)
-- Name: teachers teachers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5111 (class 2606 OID 17373)
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5112 (class 2606 OID 17368)
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2025-06-29 10:56:34

--
-- PostgreSQL database dump complete
--

