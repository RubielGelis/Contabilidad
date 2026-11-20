do $$
BEGIN

	CREATE SEQUENCE IF NOT EXISTS public."Roles_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
	CREATE TABLE IF NOT EXISTS public."Roles"
	(
	    id integer NOT NULL DEFAULT nextval('public."Roles_id_seq"'::regclass),
	    code text COLLATE pg_catalog."default" NOT NULL,
	    name text COLLATE pg_catalog."default" NOT NULL,
	    description text COLLATE pg_catalog."default",
	    enable boolean NOT NULL DEFAULT true,
	    date timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
	    CONSTRAINT roles_pkey PRIMARY KEY (id),
	    CONSTRAINT roles_code_key UNIQUE (code)
	);
    ALTER SEQUENCE public."Roles_id_seq" OWNED BY public."Roles".id;

    CREATE TABLE IF NOT EXISTS public."User" (
        id integer NOT NULL,
        name text NOT NULL,
        email text NOT NULL,
        "passwordHash" text NOT NULL,
        "resetPasswordToken" text,
        "resetPasswordExpires" timestamp(3) without time zone,
        "roleId" integer NOT NULL,
		CONSTRAINT user_pkey PRIMARY KEY (id),
    	CONSTRAINT user_name_key UNIQUE (name),
		CONSTRAINT user_email_key UNIQUE (email),
		CONSTRAINT user_rol_id_fkey FOREIGN KEY ("roleId")
        REFERENCES public."Roles" (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
    );
    CREATE SEQUENCE IF NOT EXISTS public."User_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;
    ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


	CREATE TABLE IF NOT EXISTS public."Account" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
		level integer NOT NULL,
		type text NOT NULL,
		nature text NOT NULL,
		disable boolean DEFAULT false,
		date timestamp without time zone DEFAULT now(),
		parentcode text NOT NULL,
		category integer NOT NULL,
		CONSTRAINT account_pkey PRIMARY KEY (id),
	    CONSTRAINT account_code_key UNIQUE (code)
    );
	CREATE SEQUENCE IF NOT EXISTS public."Account_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Account_id_seq" OWNED BY public."Account".id;
    ALTER TABLE ONLY public."Account" ALTER COLUMN id SET DEFAULT nextval('public."Account_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Third" (
        id integer NOT NULL,
		code text NOT NULL,
        name text NOT NULL,
        "contactInfo" text,
        address text,
		phone text,
        "mandatoryVariables" jsonb,
		CONSTRAINT third_pkey PRIMARY KEY (id),
	    CONSTRAINT third_code_key UNIQUE (code)
    );
	CREATE SEQUENCE IF NOT EXISTS public."Third_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Third_id_seq" OWNED BY public."Third".id;
    ALTER TABLE ONLY public."Third" ALTER COLUMN id SET DEFAULT nextval('public."Third_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Client" (
        id integer NOT NULL,
		code text NOT NULL,
        name text NOT NULL,
        "contactInfo" text,
        address text,
		email text NOT NULL,
		phone text,
        "mandatoryVariables" jsonb,
		"ThirdId" integer NOT NULL,
		CONSTRAINT client_pkey PRIMARY KEY (id),
		CONSTRAINT client_code_key UNIQUE (code),
		CONSTRAINT client_third_id_fkey FOREIGN KEY ("ThirdId")
		     REFERENCES public."Third" (id) MATCH SIMPLE
		     ON UPDATE NO ACTION
		     ON DELETE RESTRICT
    );
	CREATE SEQUENCE IF NOT EXISTS public."Client_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Client_id_seq" OWNED BY public."Client".id;
    ALTER TABLE ONLY public."Client" ALTER COLUMN id SET DEFAULT nextval('public."Client_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Supplier" (
        id integer NOT NULL,
		code text NOT NULL,
        name text NOT NULL,
        "contactInfo" text,
        address text,
		email text NOT NULL,
		phone text,
        "mandatoryVariables" jsonb,
		"ThirdId" integer NOT NULL,
		CONSTRAINT supplier_pkey PRIMARY KEY (id),
		CONSTRAINT supplier_code_key UNIQUE (code),
		CONSTRAINT supplier_third_id_fkey FOREIGN KEY ("ThirdId")
		     REFERENCES public."Third" (id) MATCH SIMPLE
		     ON UPDATE NO ACTION
		     ON DELETE RESTRICT
    );
    CREATE SEQUENCE IF NOT EXISTS public."Supplier_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Supplier_id_seq" OWNED BY public."Supplier".id;
    ALTER TABLE ONLY public."Supplier" ALTER COLUMN id SET DEFAULT nextval('public."Supplier_id_seq"'::regclass);

    CREATE TABLE IF NOT EXISTS public."Menu" (
        id integer NOT NULL,
        code character varying(100) NOT NULL,
        name character varying(255) NOT NULL,
        parent integer,
        action character varying(500) NOT NULL,
        disable boolean DEFAULT false,
		CONSTRAINT menu_pkey PRIMARY KEY (id),
		CONSTRAINT menu_code_key UNIQUE (code)
    );
	CREATE SEQUENCE IF NOT EXISTS public."Menu_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Menu_id_seq" OWNED BY public."Menu".id;
    ALTER TABLE ONLY public."Menu" ALTER COLUMN id SET DEFAULT nextval('public."Menu_id_seq"'::regclass);

    CREATE TABLE IF NOT EXISTS public."SystemParameter" (
        id integer NOT NULL,
        code text NOT NULL,
		"order" integer NOT NULL,
        name text NOT NULL,
        value text NOT NULL,
		description text NOT NULL,
		CONSTRAINT systemparameter_pkey PRIMARY KEY (id),
		CONSTRAINT systemparameter_code_key UNIQUE (code)
    );
    CREATE SEQUENCE IF NOT EXISTS public."SystemParameter_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."SystemParameter_id_seq" OWNED BY public."SystemParameter".id;
    ALTER TABLE ONLY public."SystemParameter" ALTER COLUMN id SET DEFAULT nextval('public."SystemParameter_id_seq"'::regclass);

    CREATE TABLE IF NOT EXISTS public."Seller" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        address text,
		email text,
		phone text,
		CONSTRAINT seller_pkey PRIMARY KEY (id),
		CONSTRAINT seller_code_key UNIQUE (code)
    );
    CREATE SEQUENCE IF NOT EXISTS public."Seller_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Seller_id_seq" OWNED BY public."Seller".id;
    ALTER TABLE ONLY public."Seller" ALTER COLUMN id SET DEFAULT nextval('public."Seller_id_seq"'::regclass);

    CREATE TABLE IF NOT EXISTS public."MasterVariable" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
		CONSTRAINT mastervariable_pkey PRIMARY KEY (id),
		CONSTRAINT mastervariable_code_key UNIQUE (code)
    );
    CREATE SEQUENCE IF NOT EXISTS public."MasterVariable_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."MasterVariable_id_seq" OWNED BY public."MasterVariable".id;
    ALTER TABLE ONLY public."MasterVariable" ALTER COLUMN id SET DEFAULT nextval('public."MasterVariable_id_seq"'::regclass);

    CREATE TABLE IF NOT EXISTS public."Attachment" (
        id integer NOT NULL,
        "quotationId" integer NOT NULL,
        "fileName" text NOT NULL,
        "fileType" text NOT NULL,
        "fileSize" integer NOT NULL,
        "fileContent" bytea NOT NULL,
        "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
        CONSTRAINT attachment_pkey PRIMARY KEY (id)
    );
    CREATE SEQUENCE IF NOT EXISTS public."Attachment_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Attachment_id_seq" OWNED BY public."Attachment".id;
    ALTER TABLE ONLY public."Attachment" ALTER COLUMN id SET DEFAULT nextval('public."Attachment_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Currency" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        "exchangeRate" double precision NOT NULL,
        CONSTRAINT currency_pkey PRIMARY KEY (id),
        CONSTRAINT currency_code_key UNIQUE (code)
    );
    CREATE SEQUENCE IF NOT EXISTS public."Currency_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Currency_id_seq" OWNED BY public."Currency".id;
    ALTER TABLE ONLY public."Currency" ALTER COLUMN id SET DEFAULT nextval('public."Currency_id_seq"'::regclass);

	CREATE SEQUENCE IF NOT EXISTS public."Countries_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
	CREATE TABLE IF NOT EXISTS public."Countries"
	(
	    id integer NOT NULL DEFAULT nextval('public."Countries_id_seq"'::regclass),
	    code character varying(10) COLLATE pg_catalog."default" NOT NULL,
	    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
	    dane character varying(25) COLLATE pg_catalog."default",
	    region character varying(50) COLLATE pg_catalog."default",
	    prefix character varying(10) COLLATE pg_catalog."default",
	    "curencyId" integer,
	    CONSTRAINT "Countries_pkey" PRIMARY KEY (id),
		CONSTRAINT "Countries_code_key" UNIQUE (code),
	    CONSTRAINT "Countries_curencyId_fkey" FOREIGN KEY ("curencyId")
	        REFERENCES public."Currency" (id) MATCH SIMPLE
	        ON UPDATE CASCADE
	        ON DELETE SET NULL
	);
    ALTER SEQUENCE public."Countries_id_seq" OWNED BY public."Countries".id;

    CREATE TABLE IF NOT EXISTS public."Cities" (
        id integer NOT NULL,
        code character varying(10) NOT NULL,
        name character varying(100) NOT NULL,
        "countriesId" integer NOT NULL,
        statecode character varying(25),
        iata character varying(10),
		CONSTRAINT "Cities_pkey" PRIMARY KEY (id),
		CONSTRAINT "Cities_code_key" UNIQUE (code),
		CONSTRAINT "Cities_countriesId_fkey" FOREIGN KEY ("countriesId")
	        REFERENCES public."Countries" (id) MATCH SIMPLE
	        ON UPDATE CASCADE
	        ON DELETE RESTRICT
    );
    CREATE SEQUENCE IF NOT EXISTS public."Cities_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Cities_id_seq" OWNED BY public."Cities".id;
    ALTER TABLE ONLY public."Cities" ALTER COLUMN id SET DEFAULT nextval('public."Cities_id_seq"'::regclass);

    CREATE TABLE IF NOT EXISTS public."Payment" (
        id integer NOT NULL,
        code text NOT NULL,
        name text NOT NULL,
        inactive boolean DEFAULT false NOT NULL,
        iscash boolean DEFAULT false NOT NULL,
        iscredit boolean DEFAULT false NOT NULL,
        CONSTRAINT payment_pkey PRIMARY KEY (id),
        CONSTRAINT payment_code_key UNIQUE (code)
    );
    CREATE SEQUENCE IF NOT EXISTS public."Payment_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Payment_id_seq" OWNED BY public."Payment".id;
    ALTER TABLE ONLY public."Payment" ALTER COLUMN id SET DEFAULT nextval('public."Payment_id_seq"'::regclass);

    CREATE TABLE IF NOT EXISTS public."SystemLog" (
        id integer NOT NULL,
        "userId" integer,
        action text NOT NULL,
        module text NOT NULL,
        description text NOT NULL,
        metadata jsonb,
        "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
        CONSTRAINT systemlog_pkey PRIMARY KEY (id)
    );
    CREATE SEQUENCE IF NOT EXISTS public."SystemLog_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."SystemLog_id_seq" OWNED BY public."SystemLog".id;
    ALTER TABLE ONLY public."SystemLog" ALTER COLUMN id SET DEFAULT nextval('public."SystemLog_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Books" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		"currencyId" integer NOT NULL,
		CONSTRAINT books_pkey PRIMARY KEY (id),
	    CONSTRAINT books_code_key UNIQUE (code),
		CONSTRAINT "Books_currencyId_fkey" FOREIGN KEY ("currencyId")
	        REFERENCES public."Currency" (id) MATCH SIMPLE
	        ON UPDATE CASCADE
	        ON DELETE RESTRICT
	);
	CREATE SEQUENCE IF NOT EXISTS public."Books_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Books_id_seq" OWNED BY public."Books".id;
    ALTER TABLE ONLY public."Books" ALTER COLUMN id SET DEFAULT nextval('public."Books_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."BU" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		"booksId" integer NOT NULL,
		CONSTRAINT bu_pkey PRIMARY KEY (id),
	    CONSTRAINT bu_code_key UNIQUE (code),
		CONSTRAINT "BU_booksId_fkey" FOREIGN KEY ("booksId")
	        REFERENCES public."Books" (id) MATCH SIMPLE
	        ON UPDATE CASCADE
	        ON DELETE RESTRICT
	);
	CREATE SEQUENCE IF NOT EXISTS public."BU_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."BU_id_seq" OWNED BY public."BU".id;
    ALTER TABLE ONLY public."BU" ALTER COLUMN id SET DEFAULT nextval('public."BU_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Auxiliary" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		CONSTRAINT auxiliary_pkey PRIMARY KEY (id),
	    CONSTRAINT auxiliary_code_key UNIQUE (code)
	);
	CREATE SEQUENCE IF NOT EXISTS public."Auxiliary_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Auxiliary_id_seq" OWNED BY public."Auxiliary".id;
    ALTER TABLE ONLY public."Auxiliary" ALTER COLUMN id SET DEFAULT nextval('public."Auxiliary_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."CostCenter" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		type text NOT NULL,
		level integer NOT NULL,
		parent text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		CONSTRAINT costcenter_pkey PRIMARY KEY (id),
	    CONSTRAINT costcenter_code_key UNIQUE (code)
	);
	CREATE SEQUENCE IF NOT EXISTS public."CostCenter_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."CostCenter_id_seq" OWNED BY public."CostCenter".id;
    ALTER TABLE ONLY public."CostCenter" ALTER COLUMN id SET DEFAULT nextval('public."CostCenter_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Items" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		type text NOT NULL,
		level integer NOT NULL,
		parent text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		CONSTRAINT items_pkey PRIMARY KEY (id),
	    CONSTRAINT items_code_key UNIQUE (code)
	);
	CREATE SEQUENCE IF NOT EXISTS public."Items_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Items_id_seq" OWNED BY public."Items".id;
    ALTER TABLE ONLY public."Items" ALTER COLUMN id SET DEFAULT nextval('public."Items_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Banks" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		"currencyId" integer NOT NULL,
		CONSTRAINT banks_pkey PRIMARY KEY (id),
	    CONSTRAINT banks_code_key UNIQUE (code),
		CONSTRAINT "Banks_currencyId_fkey" FOREIGN KEY ("currencyId")
	        REFERENCES public."Currency" (id) MATCH SIMPLE
	        ON UPDATE CASCADE
	        ON DELETE RESTRICT
	);
	CREATE SEQUENCE IF NOT EXISTS public."Banks_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Banks_id_seq" OWNED BY public."Banks".id;
    ALTER TABLE ONLY public."Banks" ALTER COLUMN id SET DEFAULT nextval('public."Banks_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Square" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		type text NOT NULL,
		level integer NOT NULL,
		parent text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		CONSTRAINT square_pkey PRIMARY KEY (id),
	    CONSTRAINT square_code_key UNIQUE (code)
	);
	CREATE SEQUENCE IF NOT EXISTS public."Square_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Square_id_seq" OWNED BY public."Square".id;
    ALTER TABLE ONLY public."Square" ALTER COLUMN id SET DEFAULT nextval('public."Square_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."InvoiceType" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		CONSTRAINT invoicetype_pkey PRIMARY KEY (id),
	    CONSTRAINT invoicetype_code_key UNIQUE (code)
	);
	CREATE SEQUENCE IF NOT EXISTS public."InvoiceType_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."InvoiceType_id_seq" OWNED BY public."InvoiceType".id;
    ALTER TABLE ONLY public."InvoiceType" ALTER COLUMN id SET DEFAULT nextval('public."InvoiceType_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."DocumentType" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		CONSTRAINT documenttype_pkey PRIMARY KEY (id),
	    CONSTRAINT documenttype_code_key UNIQUE (code)
	);
	CREATE SEQUENCE IF NOT EXISTS public."DocumentType_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."DocumentType_id_seq" OWNED BY public."DocumentType".id;
    ALTER TABLE ONLY public."DocumentType" ALTER COLUMN id SET DEFAULT nextval('public."DocumentType_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Sources" (
		id integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		report text NOT NULL,
		enable boolean NOT NULL DEFAULT true,
		"documentTypeId" integer NOT NULL,
		CONSTRAINT sources_pkey PRIMARY KEY (id),
	    CONSTRAINT sources_code_key UNIQUE (code),
		CONSTRAINT "Sources_documentTypeId_fkey" FOREIGN KEY ("documentTypeId")
	        REFERENCES public."DocumentType" (id) MATCH SIMPLE
	        ON UPDATE CASCADE
	        ON DELETE RESTRICT
	);
	CREATE SEQUENCE IF NOT EXISTS public."Sources_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Sources_id_seq" OWNED BY public."Sources".id;
    ALTER TABLE ONLY public."Sources" ALTER COLUMN id SET DEFAULT nextval('public."Sources_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Days" (
		id integer NOT NULL,
	    "date" DATE NOT NULL,
	    enable boolean NOT NULL DEFAULT true,
		CONSTRAINT days_pkey PRIMARY KEY (id)
	);
	CREATE SEQUENCE IF NOT EXISTS public."Days_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Days_id_seq" OWNED BY public."Days".id;
    ALTER TABLE ONLY public."Days" ALTER COLUMN id SET DEFAULT nextval('public."Days_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Document" (
		id integer NOT NULL,
		"sourcesId" integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		"accountId" integer NULL,
		"thirdId" integer NOT NULL,
		"clientId" integer NULL,
		"supplierId" integer NULL,
		"costcenterId" integer NULL,
		"itemsId" integer NULL,
		"banksId" integer NULL,
		"squareId" integer NULL,
		"auxiliaryId" integer NULL,
		"BUId" integer NULL,
		"currencyId" integer NULL,
		"values" numeric(18, 2) NOT NULL,
		debit numeric(18, 2) NOT NULL,
		credit numeric(18, 2) NOT NULL,
		exchangerate numeric(18, 6) NOT NULL,
		"datedoc" DATE NOT NULL,
		"date" timestamp without time zone DEFAULT now(),
		CONSTRAINT document_pkey PRIMARY KEY (id),
	    CONSTRAINT document_code_key UNIQUE (code),
		CONSTRAINT "Document_sourcesId_fkey" FOREIGN KEY ("sourcesId") REFERENCES public."Sources" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT,
		CONSTRAINT "Document_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public."Account" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_thirdId_fkey" FOREIGN KEY ("thirdId") REFERENCES public."Third" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT,
		CONSTRAINT "Document_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."Client" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_costcenterId_fkey" FOREIGN KEY ("costcenterId") REFERENCES public."CostCenter" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_itemsId_fkey" FOREIGN KEY ("itemsId") REFERENCES public."Items" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_banksId_fkey" FOREIGN KEY ("banksId") REFERENCES public."Banks" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_squareId_fkey" FOREIGN KEY ("squareId") REFERENCES public."Square" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_auxiliaryId_fkey" FOREIGN KEY ("auxiliaryId") REFERENCES public."Auxiliary" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_BUId_fkey" FOREIGN KEY ("BUId") REFERENCES public."BU" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Document_currencyId_fkey" FOREIGN KEY ("currencyId") REFERENCES public."Currency" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL
	);
	CREATE SEQUENCE IF NOT EXISTS public."Document_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Document_id_seq" OWNED BY public."Document".id;
    ALTER TABLE ONLY public."Document" ALTER COLUMN id SET DEFAULT nextval('public."Document_id_seq"'::regclass);

	CREATE TABLE IF NOT EXISTS public."Transaction" (
		id integer NOT NULL,
		"sourcesId" integer NOT NULL,
	    code text NOT NULL,
	    name text NOT NULL,
		description text NOT NULL,
		"accountId" integer NULL,
		"thirdId" integer NOT NULL,
		"clientId" integer NULL,
		"supplierId" integer NULL,
		"costcenterId" integer NULL,
		"itemsId" integer NULL,
		"banksId" integer NULL,
		"squareId" integer NULL,
		"sellerId" integer NULL,
		"auxiliaryId" integer NULL,
		"BUId" integer NULL,
		"currencyId" integer NULL,
		"values" numeric(18, 2) NOT NULL,
		"valuescurrency" numeric(18, 2) NOT NULL,
		exchangerate numeric(18, 6) NOT NULL,
		"invoicetypeId" integer NULL,
		invoice text NULL,
		expiresinvoice DATE NULL,
		reference text NULL,
		"datetra" DATE NOT NULL,
		"date" timestamp without time zone DEFAULT now(),
		CONSTRAINT transaction_pkey PRIMARY KEY (id),
	    CONSTRAINT transaction_code_key UNIQUE (code),
		CONSTRAINT "Transaction_sourcesId_fkey" FOREIGN KEY ("sourcesId") REFERENCES public."Sources" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT,
		CONSTRAINT "Transaction_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public."Account" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_thirdId_fkey" FOREIGN KEY ("thirdId") REFERENCES public."Third" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT,
		CONSTRAINT "Transaction_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public."Client" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_costcenterId_fkey" FOREIGN KEY ("costcenterId") REFERENCES public."CostCenter" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_itemsId_fkey" FOREIGN KEY ("itemsId") REFERENCES public."Items" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_banksId_fkey" FOREIGN KEY ("banksId") REFERENCES public."Banks" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_squareId_fkey" FOREIGN KEY ("squareId") REFERENCES public."Square" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES public."Seller" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_auxiliaryId_fkey" FOREIGN KEY ("auxiliaryId") REFERENCES public."Auxiliary" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_BUId_fkey" FOREIGN KEY ("BUId") REFERENCES public."BU" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_currencyId_fkey" FOREIGN KEY ("currencyId") REFERENCES public."Currency" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL,
		CONSTRAINT "Transaction_invoicetypeId_fkey" FOREIGN KEY ("invoicetypeId") REFERENCES public."InvoiceType" (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL
	);
	CREATE SEQUENCE IF NOT EXISTS public."Transaction_id_seq"
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        MAXVALUE 2147483647
        CACHE 1;
    ALTER SEQUENCE public."Transaction_id_seq" OWNED BY public."Transaction".id;
    ALTER TABLE ONLY public."Transaction" ALTER COLUMN id SET DEFAULT nextval('public."Transaction_id_seq"'::regclass);
END $$;
