PGDMP                         w         
   cerveceria    11.1    11.1 Q    g           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            h           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            i           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            j           1262    65545 
   cerveceria    DATABASE     �   CREATE DATABASE cerveceria WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';
    DROP DATABASE cerveceria;
             postgres    false            �            1255    65716    actualizarinventariomp()    FUNCTION     '  CREATE FUNCTION public.actualizarinventariomp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
cant integer;
lot integer;
lot2 integer;
BEGIN
	cant := (SELECT cantidad FROM "inventario_almacenMP"  where "fk_materiaprima" = new.fkmp);
	lot := (SELECT cantlotes FROM "inventario_almacenMP"  where "fk_materiaprima" = new.fkmp);
	lot2 := (SELECT COUNT(idlote) FROM lote where fkmp=new.fkmp);
	UPDATE "inventario_almacenMP" SET
	cantidad = cant + new.cantidadenviada,
	cantlotes = lot2
	where "fk_materiaprima" = new.fkMP;

RETURN NULL;

END;
$$;
 /   DROP FUNCTION public.actualizarinventariomp();
       public       postgres    false            �            1255    65672    insertarhistoricomp()    FUNCTION     �   CREATE FUNCTION public.insertarhistoricomp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO "historico_almacenMP"(fecha,cantidad_almacenada, fk_lote) values (new.fecha, new.cantidadenviada, new.idlote);
RETURN NULL;

END;
$$;
 ,   DROP FUNCTION public.insertarhistoricomp();
       public       postgres    false            �            1255    65726    verificarnegativos()    FUNCTION     y  CREATE FUNCTION public.verificarnegativos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN
	IF new.cantidad < 0 THEN
		RAISE EXCEPTION 'La cantidad no es valida';
	ELSEIF new.cantlotes < 0 THEN
		RAISE EXCEPTION 'La cantidad de lotes no puede ser negativa';
	ELSE
		RAISE NOTICE 'El trigger % la tupla se inserto correctamente', TG_NAME;
	END IF;

RETURN NEW;

END;
$$;
 +   DROP FUNCTION public.verificarnegativos();
       public       postgres    false            �            1259    65653    historico_almacenMP    TABLE     �   CREATE TABLE public."historico_almacenMP" (
    "id_almacenMP" integer NOT NULL,
    fecha date,
    cantidad_almacenada integer,
    fk_peso integer,
    fk_lote integer
);
 )   DROP TABLE public."historico_almacenMP";
       public         postgres    false            �            1259    65651 $   historico_almacenMP_id_almacenMP_seq    SEQUENCE     �   CREATE SEQUENCE public."historico_almacenMP_id_almacenMP_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public."historico_almacenMP_id_almacenMP_seq";
       public       postgres    false    212            k           0    0 $   historico_almacenMP_id_almacenMP_seq    SEQUENCE OWNED BY     s   ALTER SEQUENCE public."historico_almacenMP_id_almacenMP_seq" OWNED BY public."historico_almacenMP"."id_almacenMP";
            public       postgres    false    211            �            1259    65555    inventario_almacenMP    TABLE     �   CREATE TABLE public."inventario_almacenMP" (
    "id_almacenMP" integer NOT NULL,
    fk_materiaprima integer NOT NULL,
    cantidad integer NOT NULL,
    cantlotes integer
);
 *   DROP TABLE public."inventario_almacenMP";
       public         postgres    false            �            1259    65558 (   inventario_almacenMP_fk_materiaprima_seq    SEQUENCE     �   CREATE SEQUENCE public."inventario_almacenMP_fk_materiaprima_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 A   DROP SEQUENCE public."inventario_almacenMP_fk_materiaprima_seq";
       public       postgres    false    196            l           0    0 (   inventario_almacenMP_fk_materiaprima_seq    SEQUENCE OWNED BY     y   ALTER SEQUENCE public."inventario_almacenMP_fk_materiaprima_seq" OWNED BY public."inventario_almacenMP".fk_materiaprima;
            public       postgres    false    197            �            1259    65560 %   inventario_almacenMP_id_almacenMP_seq    SEQUENCE     �   CREATE SEQUENCE public."inventario_almacenMP_id_almacenMP_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 >   DROP SEQUENCE public."inventario_almacenMP_id_almacenMP_seq";
       public       postgres    false    196            m           0    0 %   inventario_almacenMP_id_almacenMP_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public."inventario_almacenMP_id_almacenMP_seq" OWNED BY public."inventario_almacenMP"."id_almacenMP";
            public       postgres    false    198            �            1259    65728    inventario_produccion    TABLE     �   CREATE TABLE public.inventario_produccion (
    "idalmacenPRO" integer NOT NULL,
    fk_materiaprima integer,
    cantidad integer,
    cantlotes integer
);
 )   DROP TABLE public.inventario_produccion;
       public         postgres    false            �            1259    65562    lote    TABLE     �   CREATE TABLE public.lote (
    idlote integer NOT NULL,
    cantidadenviada integer NOT NULL,
    fecha date NOT NULL,
    fk_proveedor integer NOT NULL,
    fkmp integer NOT NULL
);
    DROP TABLE public.lote;
       public         postgres    false            �            1259    65565    lote_idlote_seq    SEQUENCE     �   CREATE SEQUENCE public.lote_idlote_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.lote_idlote_seq;
       public       postgres    false    199            n           0    0    lote_idlote_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.lote_idlote_seq OWNED BY public.lote.idlote;
            public       postgres    false    200            �            1259    65567    materia_prima    TABLE     W   CREATE TABLE public.materia_prima (
    id integer NOT NULL,
    tipo text NOT NULL
);
 !   DROP TABLE public.materia_prima;
       public         postgres    false            �            1259    65573    materia_prima_id_seq    SEQUENCE     �   CREATE SEQUENCE public.materia_prima_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.materia_prima_id_seq;
       public       postgres    false    201            o           0    0    materia_prima_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.materia_prima_id_seq OWNED BY public.materia_prima.id;
            public       postgres    false    202            �            1259    65575    peso_automatico    TABLE     _   CREATE TABLE public.peso_automatico (
    id_peso integer NOT NULL,
    marca text NOT NULL
);
 #   DROP TABLE public.peso_automatico;
       public         postgres    false            �            1259    65581    peso_automatico_id_peso_seq    SEQUENCE     �   CREATE SEQUENCE public.peso_automatico_id_peso_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.peso_automatico_id_peso_seq;
       public       postgres    false    203            p           0    0    peso_automatico_id_peso_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.peso_automatico_id_peso_seq OWNED BY public.peso_automatico.id_peso;
            public       postgres    false    204            �            1259    65583    product    TABLE     j   CREATE TABLE public.product (
    id integer NOT NULL,
    name text NOT NULL,
    price real NOT NULL
);
    DROP TABLE public.product;
       public         postgres    false            �            1259    65589    product_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.product_id_seq;
       public       postgres    false    205            q           0    0    product_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;
            public       postgres    false    206            �            1259    65591 	   proveedor    TABLE     �   CREATE TABLE public.proveedor (
    id integer NOT NULL,
    nombre text NOT NULL,
    direccion text,
    ciudad text NOT NULL,
    pais text,
    tlf character varying NOT NULL,
    fk_mp integer NOT NULL
);
    DROP TABLE public.proveedor;
       public         postgres    false            �            1259    65597    proveedor_fk_mp_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_fk_mp_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.proveedor_fk_mp_seq;
       public       postgres    false    207            r           0    0    proveedor_fk_mp_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.proveedor_fk_mp_seq OWNED BY public.proveedor.fk_mp;
            public       postgres    false    208            �            1259    65599    proveedor_id_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.proveedor_id_seq;
       public       postgres    false    207            s           0    0    proveedor_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;
            public       postgres    false    209            �            1259    65601    proveedorlote    VIEW     i  CREATE VIEW public.proveedorlote AS
 SELECT l.idlote AS "Numero de Lote",
    p.nombre AS "Nombre del Proveedor",
    concat(p.ciudad, ', ', p.pais) AS "Ubicacion",
    p.tlf AS telefono,
    mp.tipo AS "Materia Prima"
   FROM ((public.proveedor p
     JOIN public.materia_prima mp ON ((p.fk_mp = mp.id)))
     JOIN public.lote l ON ((l.fk_proveedor = p.id)));
     DROP VIEW public.proveedorlote;
       public       postgres    false    207    199    207    207    207    207    207    199    201    201            �
           2604    65656     historico_almacenMP id_almacenMP    DEFAULT     �   ALTER TABLE ONLY public."historico_almacenMP" ALTER COLUMN "id_almacenMP" SET DEFAULT nextval('public."historico_almacenMP_id_almacenMP_seq"'::regclass);
 S   ALTER TABLE public."historico_almacenMP" ALTER COLUMN "id_almacenMP" DROP DEFAULT;
       public       postgres    false    212    211    212            �
           2604    65609 !   inventario_almacenMP id_almacenMP    DEFAULT     �   ALTER TABLE ONLY public."inventario_almacenMP" ALTER COLUMN "id_almacenMP" SET DEFAULT nextval('public."inventario_almacenMP_id_almacenMP_seq"'::regclass);
 T   ALTER TABLE public."inventario_almacenMP" ALTER COLUMN "id_almacenMP" DROP DEFAULT;
       public       postgres    false    198    196            �
           2604    65610 $   inventario_almacenMP fk_materiaprima    DEFAULT     �   ALTER TABLE ONLY public."inventario_almacenMP" ALTER COLUMN fk_materiaprima SET DEFAULT nextval('public."inventario_almacenMP_fk_materiaprima_seq"'::regclass);
 U   ALTER TABLE public."inventario_almacenMP" ALTER COLUMN fk_materiaprima DROP DEFAULT;
       public       postgres    false    197    196            �
           2604    65611    lote idlote    DEFAULT     j   ALTER TABLE ONLY public.lote ALTER COLUMN idlote SET DEFAULT nextval('public.lote_idlote_seq'::regclass);
 :   ALTER TABLE public.lote ALTER COLUMN idlote DROP DEFAULT;
       public       postgres    false    200    199            �
           2604    65612    materia_prima id    DEFAULT     t   ALTER TABLE ONLY public.materia_prima ALTER COLUMN id SET DEFAULT nextval('public.materia_prima_id_seq'::regclass);
 ?   ALTER TABLE public.materia_prima ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    202    201            �
           2604    65613    peso_automatico id_peso    DEFAULT     �   ALTER TABLE ONLY public.peso_automatico ALTER COLUMN id_peso SET DEFAULT nextval('public.peso_automatico_id_peso_seq'::regclass);
 F   ALTER TABLE public.peso_automatico ALTER COLUMN id_peso DROP DEFAULT;
       public       postgres    false    204    203            �
           2604    65614 
   product id    DEFAULT     h   ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);
 9   ALTER TABLE public.product ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    206    205            �
           2604    65615    proveedor id    DEFAULT     l   ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);
 ;   ALTER TABLE public.proveedor ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    209    207            �
           2604    65616    proveedor fk_mp    DEFAULT     r   ALTER TABLE ONLY public.proveedor ALTER COLUMN fk_mp SET DEFAULT nextval('public.proveedor_fk_mp_seq'::regclass);
 >   ALTER TABLE public.proveedor ALTER COLUMN fk_mp DROP DEFAULT;
       public       postgres    false    208    207            c          0    65653    historico_almacenMP 
   TABLE DATA               m   COPY public."historico_almacenMP" ("id_almacenMP", fecha, cantidad_almacenada, fk_peso, fk_lote) FROM stdin;
    public       postgres    false    212   d`       T          0    65555    inventario_almacenMP 
   TABLE DATA               f   COPY public."inventario_almacenMP" ("id_almacenMP", fk_materiaprima, cantidad, cantlotes) FROM stdin;
    public       postgres    false    196   2a       d          0    65728    inventario_produccion 
   TABLE DATA               e   COPY public.inventario_produccion ("idalmacenPRO", fk_materiaprima, cantidad, cantlotes) FROM stdin;
    public       postgres    false    213   oa       W          0    65562    lote 
   TABLE DATA               R   COPY public.lote (idlote, cantidadenviada, fecha, fk_proveedor, fkmp) FROM stdin;
    public       postgres    false    199   �a       Y          0    65567    materia_prima 
   TABLE DATA               1   COPY public.materia_prima (id, tipo) FROM stdin;
    public       postgres    false    201   Ub       [          0    65575    peso_automatico 
   TABLE DATA               9   COPY public.peso_automatico (id_peso, marca) FROM stdin;
    public       postgres    false    203   �b       ]          0    65583    product 
   TABLE DATA               2   COPY public.product (id, name, price) FROM stdin;
    public       postgres    false    205   �b       _          0    65591 	   proveedor 
   TABLE DATA               T   COPY public.proveedor (id, nombre, direccion, ciudad, pais, tlf, fk_mp) FROM stdin;
    public       postgres    false    207   !c       t           0    0 $   historico_almacenMP_id_almacenMP_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public."historico_almacenMP_id_almacenMP_seq"', 57, true);
            public       postgres    false    211            u           0    0 (   inventario_almacenMP_fk_materiaprima_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public."inventario_almacenMP_fk_materiaprima_seq"', 1, false);
            public       postgres    false    197            v           0    0 %   inventario_almacenMP_id_almacenMP_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public."inventario_almacenMP_id_almacenMP_seq"', 1, false);
            public       postgres    false    198            w           0    0    lote_idlote_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.lote_idlote_seq', 140, true);
            public       postgres    false    200            x           0    0    materia_prima_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.materia_prima_id_seq', 1, false);
            public       postgres    false    202            y           0    0    peso_automatico_id_peso_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.peso_automatico_id_peso_seq', 1, false);
            public       postgres    false    204            z           0    0    product_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.product_id_seq', 3, true);
            public       postgres    false    206            {           0    0    proveedor_fk_mp_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.proveedor_fk_mp_seq', 4, true);
            public       postgres    false    208            |           0    0    proveedor_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.proveedor_id_seq', 1, false);
            public       postgres    false    209            �
           2606    65658 ,   historico_almacenMP historico_almacenMP_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public."historico_almacenMP"
    ADD CONSTRAINT "historico_almacenMP_pkey" PRIMARY KEY ("id_almacenMP");
 Z   ALTER TABLE ONLY public."historico_almacenMP" DROP CONSTRAINT "historico_almacenMP_pkey";
       public         postgres    false    212            �
           2606    65620 .   inventario_almacenMP inventario_almacenMP_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public."inventario_almacenMP"
    ADD CONSTRAINT "inventario_almacenMP_pkey" PRIMARY KEY ("id_almacenMP");
 \   ALTER TABLE ONLY public."inventario_almacenMP" DROP CONSTRAINT "inventario_almacenMP_pkey";
       public         postgres    false    196            �
           2606    65732 0   inventario_produccion inventario_produccion_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.inventario_produccion
    ADD CONSTRAINT inventario_produccion_pkey PRIMARY KEY ("idalmacenPRO");
 Z   ALTER TABLE ONLY public.inventario_produccion DROP CONSTRAINT inventario_produccion_pkey;
       public         postgres    false    213            �
           2606    65622    lote lote_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.lote
    ADD CONSTRAINT lote_pkey PRIMARY KEY (idlote);
 8   ALTER TABLE ONLY public.lote DROP CONSTRAINT lote_pkey;
       public         postgres    false    199            �
           2606    65624     materia_prima materia_prima_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.materia_prima
    ADD CONSTRAINT materia_prima_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.materia_prima DROP CONSTRAINT materia_prima_pkey;
       public         postgres    false    201            �
           2606    65626 $   peso_automatico peso_automatico_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.peso_automatico
    ADD CONSTRAINT peso_automatico_pkey PRIMARY KEY (id_peso);
 N   ALTER TABLE ONLY public.peso_automatico DROP CONSTRAINT peso_automatico_pkey;
       public         postgres    false    203            �
           2606    65628    product product_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pkey;
       public         postgres    false    205            �
           2606    65630    proveedor proveedor_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_pkey;
       public         postgres    false    207            �
           1259    65681 	   fki_fk_MP    INDEX     Y   CREATE INDEX "fki_fk_MP" ON public."inventario_almacenMP" USING btree (fk_materiaprima);
    DROP INDEX public."fki_fk_MP";
       public         postgres    false    196            �
           1259    65698 
   fki_fk_MP2    INDEX     =   CREATE INDEX "fki_fk_MP2" ON public.lote USING btree (fkmp);
     DROP INDEX public."fki_fk_MP2";
       public         postgres    false    199            �
           1259    65664    fki_fk_lote    INDEX     P   CREATE INDEX fki_fk_lote ON public."historico_almacenMP" USING btree (fk_lote);
    DROP INDEX public.fki_fk_lote;
       public         postgres    false    212            �
           1259    65670    fki_fk_peso    INDEX     P   CREATE INDEX fki_fk_peso ON public."historico_almacenMP" USING btree (fk_peso);
    DROP INDEX public.fki_fk_peso;
       public         postgres    false    212            �
           1259    65704    fki_fk_proveedor    INDEX     I   CREATE INDEX fki_fk_proveedor ON public.lote USING btree (fk_proveedor);
 $   DROP INDEX public.fki_fk_proveedor;
       public         postgres    false    199            �
           2620    65673    lote historicomp    TRIGGER     t   CREATE TRIGGER historicomp AFTER INSERT ON public.lote FOR EACH ROW EXECUTE PROCEDURE public.insertarhistoricomp();
 )   DROP TRIGGER historicomp ON public.lote;
       public       postgres    false    214    199            �
           2620    65717    lote inventariomp    TRIGGER     x   CREATE TRIGGER inventariomp AFTER INSERT ON public.lote FOR EACH ROW EXECUTE PROCEDURE public.actualizarinventariomp();
 *   DROP TRIGGER inventariomp ON public.lote;
       public       postgres    false    199    215            �
           2620    65727    inventario_almacenMP validarmp    TRIGGER     �   CREATE TRIGGER validarmp BEFORE INSERT ON public."inventario_almacenMP" FOR EACH ROW EXECUTE PROCEDURE public.verificarnegativos();
 9   DROP TRIGGER validarmp ON public."inventario_almacenMP";
       public       postgres    false    196    216            �
           2606    65676    inventario_almacenMP fk_MP    FK CONSTRAINT     �   ALTER TABLE ONLY public."inventario_almacenMP"
    ADD CONSTRAINT "fk_MP" FOREIGN KEY (fk_materiaprima) REFERENCES public.materia_prima(id);
 H   ALTER TABLE ONLY public."inventario_almacenMP" DROP CONSTRAINT "fk_MP";
       public       postgres    false    196    2757    201            �
           2606    65693    lote fk_MP2    FK CONSTRAINT     q   ALTER TABLE ONLY public.lote
    ADD CONSTRAINT "fk_MP2" FOREIGN KEY (fkmp) REFERENCES public.materia_prima(id);
 7   ALTER TABLE ONLY public.lote DROP CONSTRAINT "fk_MP2";
       public       postgres    false    2757    199    201            �
           2606    65659    historico_almacenMP fk_lote    FK CONSTRAINT        ALTER TABLE ONLY public."historico_almacenMP"
    ADD CONSTRAINT fk_lote FOREIGN KEY (fk_lote) REFERENCES public.lote(idlote);
 G   ALTER TABLE ONLY public."historico_almacenMP" DROP CONSTRAINT fk_lote;
       public       postgres    false    212    2755    199            �
           2606    65665    historico_almacenMP fk_peso    FK CONSTRAINT     �   ALTER TABLE ONLY public."historico_almacenMP"
    ADD CONSTRAINT fk_peso FOREIGN KEY (fk_peso) REFERENCES public.peso_automatico(id_peso);
 G   ALTER TABLE ONLY public."historico_almacenMP" DROP CONSTRAINT fk_peso;
       public       postgres    false    212    2759    203            �
           2606    65699    lote fk_proveedor    FK CONSTRAINT     y   ALTER TABLE ONLY public.lote
    ADD CONSTRAINT fk_proveedor FOREIGN KEY (fk_proveedor) REFERENCES public.proveedor(id);
 ;   ALTER TABLE ONLY public.lote DROP CONSTRAINT fk_proveedor;
       public       postgres    false    2763    199    207            c   �   x�]���!�;��%1#@I\�?�;,�����bh�����ڣ�+����s�'8nb��7iΛh�(�`~��ET�Av;\�E����ǋ���\ĊtH�6��Pl�dgB}�)3�$46�9߄�m��ѡ<�U76�m��ՍD�q��Q�v8Ս���T7v��Հǵj������ȬL�؝Ydx=��e�      T   -   x���  ��eD�V0�ρm��v�U�=�B�S�9zK���      d      x�3�4�4�4�2�4�Ɯ�`:F��� 3�d      W   �   x�e��!г�e#� �K��#;�
N�>��"���N�2.�K����2�mgr��^�;)��
��K�̼�m���;\�ݕ�p��է�y�?�>����}ι��{���wͻ����y�ޏ���v�c�{.w��w�W���ל�{�����Y=�7�^Y�{#���W)�ɶV�      Y   1   x�3�LNMJLI�2��)-(���2��&�+��&g��\1z\\\ F|�      [   3   x�3��q�2�t�IL�v�KqIM�N-�2��p��&����Vp��qqq *      ]   8   x�3�,I��T �����f�\Ɯ��9�
`���Ȑ˄� � ������+F��� �qq      _   �   x�U�1k�0�g�Wx?(ر����L)�v(]�D�|88���UzP�I��}ߓ�(Y��M�rf�!n��=����p�C���e��F��	��4����K*I��Ti�4�qᯍ�N:)	�;)ɛڙk��Nd���OL��B��*^�-ߨ?@c����+��k�ʢ?���s��u:B�Bk���{��ʿg�F�7�z>�1߫,U(     