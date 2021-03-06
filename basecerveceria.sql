PGDMP                         w         
   cerveceria    11.1    11.1 �               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false                       1262    65545 
   cerveceria    DATABASE     �   CREATE DATABASE cerveceria WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';
    DROP DATABASE cerveceria;
             postgres    false                       1255    66521    actualizarcantidadembotellado()    FUNCTION     }  CREATE FUNCTION public.actualizarcantidadembotellado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

cant integer;
cant2 integer;
lot integer;
lot2 integer;
/*Falta poner la condicion que lo pase a produccion luego de una semana NO SE COMO HACERLO */

BEGIN
	
	cant := (SELECT cantidad FROM "inventario_produccion"  where "fkmp" = new.fkmp);
	cant2 := (SELECT cantidad FROM "inventario_embotellado"  where "fkmp" = new.fkmp);
	lot := (SELECT cantlotes FROM "inventario_produccion" where fkmp=new.fkmp);
	lot2 := (SELECT cantlotes FROM "inventario_embotellado" where "fkmp"=new.fkmp);
	
	
	/*le sumo 7 dias, una semana cuando entra al almacen de embotellado*/
	INSERT INTO "historico_almacenemb"(fecha,cantidadembotellada, fklote, fkmp) values (new.fecha + integer '7', new.cantidadalmacenada, new.fklote, new.fkmp);
	INSERT INTO "estado_almacenembotellado"(fecha,cantidadembotellada, fklote, fkmp) values (new.fecha + integer '7', new.cantidadalmacenada, new.fklote, new.fkmp);
	DELETE FROM "estado_almacenPro" WHERE fklote = new.fklote;
	
	UPDATE "inventario_produccion" SET
	cantidad = cant - new.cantidadalmacenada,
	cantlotes = lot - 1
	where "fkmp" = new.fkmp;
	
	UPDATE "lote" SET
	estado = 'embotellado'
	where "idlote" = new.fklote;
	
	UPDATE "inventario_embotellado" SET
	cantidad = cant2 + new.cantidadalmacenada,
	cantlotes = lot2 + 1
	where "fkmp" = new.fkmp;


RETURN NEW;
END;
$$;
 6   DROP FUNCTION public.actualizarcantidadembotellado();
       public       postgres    false                       1255    66514    actualizarcantidadproduccion()    FUNCTION     �  CREATE FUNCTION public.actualizarcantidadproduccion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
materia1 integer:= (SELECT cantlotes FROM "inventario_almacenMP"  where "fkmp" = '1');
materia2 integer:= (SELECT cantlotes FROM "inventario_almacenMP"  where "fkmp" = '2');
materia3 integer:= (SELECT cantlotes FROM "inventario_almacenMP"  where "fkmp" = '3');
cant integer;
cant2 integer;

lot integer;
lot2 integer;
/*Falta poner la condicion que lo pase a produccion luego de una semana NO SE COMO HACERLO */

BEGIN
	IF (materia1 = 0 OR materia2 = 0 OR materia3 = 0) THEN
	RAISE NOTICE 'No hay lotes de materia prima para pasar a produccion';
	ELSE
	cant := (SELECT cantidad FROM "inventario_almacenMP"  where "fkmp" = new.fkmp);
	cant2 := (SELECT cantidad FROM "inventario_produccion"  where "fkmp" = new.fkmp);
	lot := (SELECT cantlotes FROM "inventario_almacenMP" where fkmp=new.fkmp);
	lot2 := (SELECT cantlotes FROM "inventario_produccion" where "fkmp"=new.fkmp);
	
	INSERT INTO "historico_almacenPRO"(fecha,cantidadalmacenada, fklote, fkmp) values (new.fecha, new.cantidadalmacenada, new.fklote, new.fkmp);
	INSERT INTO "estado_almacenPro"(fecha,cantidadalmacenada, fklote, fkmp) values (new.fecha, new.cantidadalmacenada, new.fklote, new.fkmp);
	DELETE FROM "estado_almacenMP" WHERE fklote = new.fklote;
	
	UPDATE "inventario_almacenMP" SET
	cantidad = cant - new.cantidadalmacenada,
	cantlotes = lot - 1
	where "fkmp" = new.fkmp;
	
	UPDATE "lote" SET
	estado = 'produccion'
	where "idlote" = new.fklote;
	
	UPDATE "inventario_produccion" SET
	cantidad = cant2 + new.cantidadalmacenada,
	cantlotes = lot2 + 1
	where "fkmp" = new.fkmp;
	END IF;

RETURN NEW;

END;
$$;
 5   DROP FUNCTION public.actualizarcantidadproduccion();
       public       postgres    false                       1255    66129    actualizarganaciavendedor()    FUNCTION     ^  CREATE FUNCTION public.actualizarganaciavendedor() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
cant integer;
BEGIN
	cant := (SELECT "cantganada" FROM "comisionvendedor"  where "fkvendedor" = new.fkvendedor);
	UPDATE "comisionvendedor" SET
	cantganada = cant + 0.03*(new.total)
	where "fkvendedor" = new.fkvendedor;

RETURN NULL;

END;
$$;
 2   DROP FUNCTION public.actualizarganaciavendedor();
       public       postgres    false                       1255    66101    actualizarinventariocerveza()    FUNCTION     V  CREATE FUNCTION public.actualizarinventariocerveza() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
cant integer;
BEGIN
	cant := (SELECT "cantdisponible" FROM "inventariocerveza"  where "id" = new.fkproducto);
	UPDATE "inventariocerveza" SET
	cantdisponible = cant - new.cantidad
	where "id" = new.fkproducto;

RETURN NULL;

END;
$$;
 4   DROP FUNCTION public.actualizarinventariocerveza();
       public       postgres    false                       1255    66482    actualizarinventariomp()    FUNCTION       CREATE FUNCTION public.actualizarinventariomp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
cant integer;
lot integer;
lot2 integer;
BEGIN
	cant := (SELECT cantidad FROM "inventario_almacenMP"  where "fkmp" = new.fkmp);
	lot := (SELECT cantlotes FROM "inventario_almacenMP"  where "fkmp" = new.fkmp);
	lot2 := (SELECT COUNT(idalmacenmp) FROM "estado_almacenMP" where "fkmp"=new.fkmp);
	UPDATE "inventario_almacenMP" SET
	cantidad = cant + new.cantidadenviada,
	cantlotes = lot + 1
	where "fkmp" = new.fkMP;

RETURN NULL;

END;
$$;
 /   DROP FUNCTION public.actualizarinventariomp();
       public       postgres    false            �            1255    65906    insertarhistoricomp()    FUNCTION     �  CREATE FUNCTION public.insertarhistoricomp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO "historico_almacenMP"(fecha,cantidadalmacenada, fklote, fkmp) values (new.fecha, new.cantidadenviada, new.idlote, new.fkmp);
INSERT INTO "estado_almacenMP"(fecha,cantidadalmacenada, fklote, fkmp) values (new.fecha, new.cantidadenviada, new.idlote, new.fkmp);

RETURN NULL;

END;
$$;
 ,   DROP FUNCTION public.insertarhistoricomp();
       public       postgres    false                       1255    66135    insertarvendedorganancia()    FUNCTION     �   CREATE FUNCTION public.insertarvendedorganancia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN
	INSERT INTO "comisionvendedor"(fkvendedor, cantganada) values (new.cedula, 0);
RETURN NULL;

END;
$$;
 1   DROP FUNCTION public.insertarvendedorganancia();
       public       postgres    false                        1255    66052 1   insertarventa(integer, integer, integer, integer)    FUNCTION     �  CREATE FUNCTION public.insertarventa(idclient integer, idvende integer, idproduct integer, cant integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
totaly real;
BEGIN
totaly:= (SELECT precio from cerveza where idcerveza = idproduct )*cant;
INSERT INTO "venta"(fkcliente,fkvendedor, fkproducto, cantidad, total, hora, fecha) values (idclient, idvende,  idproduct, cant, totaly, current_time, current_date);
END;
$$;
 h   DROP FUNCTION public.insertarventa(idclient integer, idvende integer, idproduct integer, cant integer);
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
       public       postgres    false            �            1259    65735    cerveza    TABLE     �   CREATE TABLE public.cerveza (
    idcerveza integer NOT NULL,
    tipo text NOT NULL,
    presentacion text NOT NULL,
    precio real NOT NULL
);
    DROP TABLE public.cerveza;
       public         postgres    false            �            1259    65733    cerveza_idcerveza_seq    SEQUENCE     �   CREATE SEQUENCE public.cerveza_idcerveza_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.cerveza_idcerveza_seq;
       public       postgres    false    211                       0    0    cerveza_idcerveza_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.cerveza_idcerveza_seq OWNED BY public.cerveza.idcerveza;
            public       postgres    false    210            �            1259    66115    comisionvendedor    TABLE     V   CREATE TABLE public.comisionvendedor (
    fkvendedor integer,
    cantganada real
);
 $   DROP TABLE public.comisionvendedor;
       public         postgres    false            �            1259    65789    estado_almacenMP    TABLE     �   CREATE TABLE public."estado_almacenMP" (
    idalmacenmp integer NOT NULL,
    fecha date,
    cantidadalmacenada integer,
    fklote integer,
    fkmp integer
);
 &   DROP TABLE public."estado_almacenMP";
       public         postgres    false            �            1259    65787 !   estado_almacenMP_id_almacenMP_seq    SEQUENCE     �   CREATE SEQUENCE public."estado_almacenMP_id_almacenMP_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public."estado_almacenMP_id_almacenMP_seq";
       public       postgres    false    218                       0    0 !   estado_almacenMP_id_almacenMP_seq    SEQUENCE OWNED BY     j   ALTER SEQUENCE public."estado_almacenMP_id_almacenMP_seq" OWNED BY public."estado_almacenMP".idalmacenmp;
            public       postgres    false    217            �            1259    65813    estado_almacenPro    TABLE     �   CREATE TABLE public."estado_almacenPro" (
    idalmacenpro integer NOT NULL,
    fecha date,
    cantidadalmacenada integer,
    fklote integer,
    fkmp integer
);
 '   DROP TABLE public."estado_almacenPro";
       public         postgres    false            �            1259    65811 "   estado_almacenPro_idalmacenpro_seq    SEQUENCE     �   CREATE SEQUENCE public."estado_almacenPro_idalmacenpro_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ;   DROP SEQUENCE public."estado_almacenPro_idalmacenpro_seq";
       public       postgres    false    220                       0    0 "   estado_almacenPro_idalmacenpro_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public."estado_almacenPro_idalmacenpro_seq" OWNED BY public."estado_almacenPro".idalmacenpro;
            public       postgres    false    219            �            1259    66243    estado_almacenembotellado    TABLE     �   CREATE TABLE public.estado_almacenembotellado (
    id integer NOT NULL,
    fecha date,
    cantidadembotellada integer,
    fklote integer,
    fkmp integer
);
 -   DROP TABLE public.estado_almacenembotellado;
       public         postgres    false            �            1259    66241     estado_almacenembotellado_id_seq    SEQUENCE     �   CREATE SEQUENCE public.estado_almacenembotellado_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.estado_almacenembotellado_id_seq;
       public       postgres    false    237                       0    0     estado_almacenembotellado_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.estado_almacenembotellado_id_seq OWNED BY public.estado_almacenembotellado.id;
            public       postgres    false    236            �            1259    65562    lote    TABLE     �   CREATE TABLE public.lote (
    idlote integer NOT NULL,
    cantidadenviada integer NOT NULL,
    fecha date NOT NULL,
    fkproveedor integer NOT NULL,
    fkmp integer NOT NULL,
    estado text,
    "precio$" double precision
);
    DROP TABLE public.lote;
       public         postgres    false            �            1259    65567    materia_prima    TABLE     W   CREATE TABLE public.materia_prima (
    id integer NOT NULL,
    tipo text NOT NULL
);
 !   DROP TABLE public.materia_prima;
       public         postgres    false            �            1259    66029 
   estadolote    VIEW     �   CREATE VIEW public.estadolote AS
 SELECT l.idlote AS " Nro. Lote ",
    mp.tipo AS "Materia Prima",
    l.estado AS "Estado Actual"
   FROM (public.lote l
     JOIN public.materia_prima mp ON ((mp.id = l.fkmp)));
    DROP VIEW public.estadolote;
       public       postgres    false    199    199    199    201    201            �            1259    65929    historico_almacenMP    TABLE     �   CREATE TABLE public."historico_almacenMP" (
    "idalmacenMP" integer NOT NULL,
    fecha date,
    cantidadalmacenada integer,
    fklote integer,
    fkmp integer
);
 )   DROP TABLE public."historico_almacenMP";
       public         postgres    false            �            1259    65927 #   historico_almacenMP_idalmacenMP_seq    SEQUENCE     �   CREATE SEQUENCE public."historico_almacenMP_idalmacenMP_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public."historico_almacenMP_idalmacenMP_seq";
       public       postgres    false    224                       0    0 #   historico_almacenMP_idalmacenMP_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public."historico_almacenMP_idalmacenMP_seq" OWNED BY public."historico_almacenMP"."idalmacenMP";
            public       postgres    false    223            �            1259    65841    historico_almacenPRO    TABLE     �   CREATE TABLE public."historico_almacenPRO" (
    "idalmacenPRO" integer NOT NULL,
    fecha date,
    cantidadalmacenada integer,
    fklote integer,
    fkmp integer
);
 *   DROP TABLE public."historico_almacenPRO";
       public         postgres    false            �            1259    65839 %   historico_almacenPRO_idalmacenPRO_seq    SEQUENCE     �   CREATE SEQUENCE public."historico_almacenPRO_idalmacenPRO_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 >   DROP SEQUENCE public."historico_almacenPRO_idalmacenPRO_seq";
       public       postgres    false    222                        0    0 %   historico_almacenPRO_idalmacenPRO_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public."historico_almacenPRO_idalmacenPRO_seq" OWNED BY public."historico_almacenPRO"."idalmacenPRO";
            public       postgres    false    221            �            1259    66259    historico_almacenemb    TABLE     �   CREATE TABLE public.historico_almacenemb (
    idalmacen integer NOT NULL,
    fecha date,
    cantidadembotellada integer,
    fklote integer,
    fkmp integer
);
 (   DROP TABLE public.historico_almacenemb;
       public         postgres    false            �            1259    66257 "   historico_almacenemb_idalmacen_seq    SEQUENCE     �   CREATE SEQUENCE public.historico_almacenemb_idalmacen_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.historico_almacenemb_idalmacen_seq;
       public       postgres    false    241            !           0    0 "   historico_almacenemb_idalmacen_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.historico_almacenemb_idalmacen_seq OWNED BY public.historico_almacenemb.idalmacen;
            public       postgres    false    240            �            1259    65757    inventariocerveza    TABLE     v   CREATE TABLE public.inventariocerveza (
    id integer NOT NULL,
    fkcerveza integer,
    cantdisponible integer
);
 %   DROP TABLE public.inventariocerveza;
       public         postgres    false            �            1259    65755    inventarioCerveza_id_seq    SEQUENCE     �   CREATE SEQUENCE public."inventarioCerveza_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."inventarioCerveza_id_seq";
       public       postgres    false    215            "           0    0    inventarioCerveza_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."inventarioCerveza_id_seq" OWNED BY public.inventariocerveza.id;
            public       postgres    false    214            �            1259    65555    inventario_almacenMP    TABLE     �   CREATE TABLE public."inventario_almacenMP" (
    "id_almacenMP" integer NOT NULL,
    fkmp integer NOT NULL,
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
       public       postgres    false    196            #           0    0 (   inventario_almacenMP_fk_materiaprima_seq    SEQUENCE OWNED BY     n   ALTER SEQUENCE public."inventario_almacenMP_fk_materiaprima_seq" OWNED BY public."inventario_almacenMP".fkmp;
            public       postgres    false    197            �            1259    65560 %   inventario_almacenMP_id_almacenMP_seq    SEQUENCE     �   CREATE SEQUENCE public."inventario_almacenMP_id_almacenMP_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 >   DROP SEQUENCE public."inventario_almacenMP_id_almacenMP_seq";
       public       postgres    false    196            $           0    0 %   inventario_almacenMP_id_almacenMP_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public."inventario_almacenMP_id_almacenMP_seq" OWNED BY public."inventario_almacenMP"."id_almacenMP";
            public       postgres    false    198            �            1259    66251    inventario_embotellado    TABLE     �   CREATE TABLE public.inventario_embotellado (
    id integer NOT NULL,
    fkmp integer,
    cantidad integer,
    cantlotes integer
);
 *   DROP TABLE public.inventario_embotellado;
       public         postgres    false            �            1259    66249    inventario_embotellado_id_seq    SEQUENCE     �   CREATE SEQUENCE public.inventario_embotellado_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.inventario_embotellado_id_seq;
       public       postgres    false    239            %           0    0    inventario_embotellado_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.inventario_embotellado_id_seq OWNED BY public.inventario_embotellado.id;
            public       postgres    false    238            �            1259    65728    inventario_produccion    TABLE     �   CREATE TABLE public.inventario_produccion (
    "idalmacenPRO" integer NOT NULL,
    fkmp integer,
    cantidad integer,
    cantlotes integer
);
 )   DROP TABLE public.inventario_produccion;
       public         postgres    false            �            1259    66165    inventariomp    VIEW       CREATE VIEW public.inventariomp AS
 SELECT m.tipo AS "Materia Prima",
    imp.cantidad AS "Toneladas Almacenadas",
    imp.cantlotes AS "Cantidad de Lotes"
   FROM (public."inventario_almacenMP" imp
     JOIN public.materia_prima m ON ((m.id = imp.fkmp)))
  ORDER BY m.tipo;
    DROP VIEW public.inventariomp;
       public       postgres    false    196    196    196    201    201            �            1259    66169    inventarioproduccion    VIEW       CREATE VIEW public.inventarioproduccion AS
 SELECT m.tipo AS "Materia Prima",
    ip.cantidad AS "Toneladas Almacenadas",
    ip.cantlotes AS "Cantidad de Lotes"
   FROM (public.inventario_produccion ip
     JOIN public.materia_prima m ON ((m.id = ip.fkmp)))
  ORDER BY m.tipo;
 '   DROP VIEW public.inventarioproduccion;
       public       postgres    false    209    209    201    201    209            �            1259    65565    lote_idlote_seq    SEQUENCE     �   CREATE SEQUENCE public.lote_idlote_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.lote_idlote_seq;
       public       postgres    false    199            &           0    0    lote_idlote_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.lote_idlote_seq OWNED BY public.lote.idlote;
            public       postgres    false    200            �            1259    65573    materia_prima_id_seq    SEQUENCE     �   CREATE SEQUENCE public.materia_prima_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.materia_prima_id_seq;
       public       postgres    false    201            '           0    0    materia_prima_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.materia_prima_id_seq OWNED BY public.materia_prima.id;
            public       postgres    false    202            �            1259    65591 	   proveedor    TABLE     �   CREATE TABLE public.proveedor (
    id integer NOT NULL,
    nombre text NOT NULL,
    direccion text,
    ciudad text NOT NULL,
    pais text,
    tlf character varying NOT NULL,
    fk_mp integer NOT NULL
);
    DROP TABLE public.proveedor;
       public         postgres    false            �            1259    66151    pagosproveedor    VIEW     �  CREATE VIEW public.pagosproveedor AS
 SELECT l.idlote AS " Nro. Lote ",
    mp.tipo AS "Materia Prima",
    p.nombre AS "Proveedor",
    concat(p.ciudad, ', ', p.pais) AS "Ubicacion",
    l.cantidadenviada AS "Toneladas Compradas",
    l."precio$" AS "Cantidad ($)",
    l.fecha AS "Fecha de Pago"
   FROM ((public.lote l
     JOIN public.materia_prima mp ON ((mp.id = l.fkmp)))
     JOIN public.proveedor p ON ((p.id = l.fkproveedor)));
 !   DROP VIEW public.pagosproveedor;
       public       postgres    false    199    199    201    201    205    205    205    199    199    205    199    199            �            1259    65575    peso_automatico    TABLE     _   CREATE TABLE public.peso_automatico (
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
       public       postgres    false    203            (           0    0    peso_automatico_id_peso_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.peso_automatico_id_peso_seq OWNED BY public.peso_automatico.id_peso;
            public       postgres    false    204            �            1259    65597    proveedor_fk_mp_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_fk_mp_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.proveedor_fk_mp_seq;
       public       postgres    false    205            )           0    0    proveedor_fk_mp_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.proveedor_fk_mp_seq OWNED BY public.proveedor.fk_mp;
            public       postgres    false    206            �            1259    65599    proveedor_id_seq    SEQUENCE     �   CREATE SEQUENCE public.proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.proveedor_id_seq;
       public       postgres    false    205            *           0    0    proveedor_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.proveedor_id_seq OWNED BY public.proveedor.id;
            public       postgres    false    207            �            1259    65601    proveedorlote    VIEW     h  CREATE VIEW public.proveedorlote AS
 SELECT l.idlote AS "Numero de Lote",
    p.nombre AS "Nombre del Proveedor",
    concat(p.ciudad, ', ', p.pais) AS "Ubicacion",
    p.tlf AS telefono,
    mp.tipo AS "Materia Prima"
   FROM ((public.proveedor p
     JOIN public.materia_prima mp ON ((p.fk_mp = mp.id)))
     JOIN public.lote l ON ((l.fkproveedor = p.id)));
     DROP VIEW public.proveedorlote;
       public       postgres    false    205    205    201    199    205    199    205    205    201    205            �            1259    66156    sumapagosproveedor    VIEW     @  CREATE VIEW public.sumapagosproveedor AS
 SELECT p.nombre AS "Proveedor",
    mp.tipo AS "Materia Prima",
    sum(l."precio$") AS "Total de $ pagados"
   FROM ((public.lote l
     JOIN public.proveedor p ON ((p.id = l.fkproveedor)))
     JOIN public.materia_prima mp ON ((mp.id = l.fkmp)))
  GROUP BY p.nombre, mp.tipo;
 %   DROP VIEW public.sumapagosproveedor;
       public       postgres    false    199    205    205    201    201    199    199            �            1259    65746    supermercado    TABLE     �   CREATE TABLE public.supermercado (
    id integer NOT NULL,
    nombre text,
    telefono text,
    ubicacion text,
    ciudad text
);
     DROP TABLE public.supermercado;
       public         postgres    false            �            1259    65744    supermercado_id_seq    SEQUENCE     �   CREATE SEQUENCE public.supermercado_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.supermercado_id_seq;
       public       postgres    false    213            +           0    0    supermercado_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.supermercado_id_seq OWNED BY public.supermercado.id;
            public       postgres    false    212            �            1259    65763    vendedor    TABLE     �   CREATE TABLE public.vendedor (
    cedula integer NOT NULL,
    nombre text NOT NULL,
    apellido text NOT NULL,
    fecha_nacimiento date,
    telefono text
);
    DROP TABLE public.vendedor;
       public         postgres    false            �            1259    66055    venta    TABLE     �   CREATE TABLE public.venta (
    idventa integer NOT NULL,
    fkcliente integer,
    fkvendedor integer,
    fkproducto integer,
    cantidad integer,
    total real,
    hora time with time zone,
    fecha date
);
    DROP TABLE public.venta;
       public         postgres    false            �            1259    66053    venta_idventa_seq    SEQUENCE     �   CREATE SEQUENCE public.venta_idventa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.venta_idventa_seq;
       public       postgres    false    227            ,           0    0    venta_idventa_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.venta_idventa_seq OWNED BY public.venta.idventa;
            public       postgres    false    226            �            1259    66085    ventarealizada    VIEW       CREATE VIEW public.ventarealizada AS
 SELECT v.idventa AS "Numero Venta",
    s.nombre AS "Supermercado",
    concat(ve.nombre, ' ', ve.apellido) AS "Vendedor",
    concat(c.presentacion, ' ', c.tipo) AS "Cerveza",
    v.cantidad AS "Cantidad",
    v.total AS "Total Bs",
    v.hora AS "Hora",
    v.fecha AS "Fecha"
   FROM (((public.venta v
     JOIN public.supermercado s ON ((s.id = v.fkcliente)))
     JOIN public.cerveza c ON ((c.idcerveza = v.fkproducto)))
     JOIN public.vendedor ve ON ((ve.cedula = v.fkvendedor)));
 !   DROP VIEW public.ventarealizada;
       public       postgres    false    227    227    227    227    211    211    211    213    213    216    216    216    227    227    227    227            �            1259    66131    verganaciavendedores    VIEW       CREATE VIEW public.verganaciavendedores AS
 SELECT ve.cedula AS "Cedula",
    concat(ve.nombre, ' ', ve.apellido) AS "Nombre Completo",
    cv.cantganada AS "Ganacia 3% de las ventas"
   FROM (public.vendedor ve
     JOIN public.comisionvendedor cv ON ((cv.fkvendedor = ve.cedula)));
 '   DROP VIEW public.verganaciavendedores;
       public       postgres    false    216    230    230    216    216            �            1259    66103    verinventariocerveza    VIEW     �   CREATE VIEW public.verinventariocerveza AS
 SELECT concat(c.presentacion, ' ', c.tipo) AS "Cerveza",
    i.cantdisponible AS "Cantidad Disponible"
   FROM (public.inventariocerveza i
     JOIN public.cerveza c ON ((c.idcerveza = i.fkcerveza)));
 '   DROP VIEW public.verinventariocerveza;
       public       postgres    false    211    215    215    211    211            "           2604    65738    cerveza idcerveza    DEFAULT     v   ALTER TABLE ONLY public.cerveza ALTER COLUMN idcerveza SET DEFAULT nextval('public.cerveza_idcerveza_seq'::regclass);
 @   ALTER TABLE public.cerveza ALTER COLUMN idcerveza DROP DEFAULT;
       public       postgres    false    211    210    211            %           2604    65792    estado_almacenMP idalmacenmp    DEFAULT     �   ALTER TABLE ONLY public."estado_almacenMP" ALTER COLUMN idalmacenmp SET DEFAULT nextval('public."estado_almacenMP_id_almacenMP_seq"'::regclass);
 M   ALTER TABLE public."estado_almacenMP" ALTER COLUMN idalmacenmp DROP DEFAULT;
       public       postgres    false    217    218    218            &           2604    65816    estado_almacenPro idalmacenpro    DEFAULT     �   ALTER TABLE ONLY public."estado_almacenPro" ALTER COLUMN idalmacenpro SET DEFAULT nextval('public."estado_almacenPro_idalmacenpro_seq"'::regclass);
 O   ALTER TABLE public."estado_almacenPro" ALTER COLUMN idalmacenpro DROP DEFAULT;
       public       postgres    false    219    220    220            *           2604    66246    estado_almacenembotellado id    DEFAULT     �   ALTER TABLE ONLY public.estado_almacenembotellado ALTER COLUMN id SET DEFAULT nextval('public.estado_almacenembotellado_id_seq'::regclass);
 K   ALTER TABLE public.estado_almacenembotellado ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    236    237    237            (           2604    65932    historico_almacenMP idalmacenMP    DEFAULT     �   ALTER TABLE ONLY public."historico_almacenMP" ALTER COLUMN "idalmacenMP" SET DEFAULT nextval('public."historico_almacenMP_idalmacenMP_seq"'::regclass);
 R   ALTER TABLE public."historico_almacenMP" ALTER COLUMN "idalmacenMP" DROP DEFAULT;
       public       postgres    false    224    223    224            '           2604    65844 !   historico_almacenPRO idalmacenPRO    DEFAULT     �   ALTER TABLE ONLY public."historico_almacenPRO" ALTER COLUMN "idalmacenPRO" SET DEFAULT nextval('public."historico_almacenPRO_idalmacenPRO_seq"'::regclass);
 T   ALTER TABLE public."historico_almacenPRO" ALTER COLUMN "idalmacenPRO" DROP DEFAULT;
       public       postgres    false    221    222    222            ,           2604    66262    historico_almacenemb idalmacen    DEFAULT     �   ALTER TABLE ONLY public.historico_almacenemb ALTER COLUMN idalmacen SET DEFAULT nextval('public.historico_almacenemb_idalmacen_seq'::regclass);
 M   ALTER TABLE public.historico_almacenemb ALTER COLUMN idalmacen DROP DEFAULT;
       public       postgres    false    240    241    241                       2604    65609 !   inventario_almacenMP id_almacenMP    DEFAULT     �   ALTER TABLE ONLY public."inventario_almacenMP" ALTER COLUMN "id_almacenMP" SET DEFAULT nextval('public."inventario_almacenMP_id_almacenMP_seq"'::regclass);
 T   ALTER TABLE public."inventario_almacenMP" ALTER COLUMN "id_almacenMP" DROP DEFAULT;
       public       postgres    false    198    196                       2604    65610    inventario_almacenMP fkmp    DEFAULT     �   ALTER TABLE ONLY public."inventario_almacenMP" ALTER COLUMN fkmp SET DEFAULT nextval('public."inventario_almacenMP_fk_materiaprima_seq"'::regclass);
 J   ALTER TABLE public."inventario_almacenMP" ALTER COLUMN fkmp DROP DEFAULT;
       public       postgres    false    197    196            +           2604    66254    inventario_embotellado id    DEFAULT     �   ALTER TABLE ONLY public.inventario_embotellado ALTER COLUMN id SET DEFAULT nextval('public.inventario_embotellado_id_seq'::regclass);
 H   ALTER TABLE public.inventario_embotellado ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    238    239    239            $           2604    65760    inventariocerveza id    DEFAULT     ~   ALTER TABLE ONLY public.inventariocerveza ALTER COLUMN id SET DEFAULT nextval('public."inventarioCerveza_id_seq"'::regclass);
 C   ALTER TABLE public.inventariocerveza ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    215    214    215                       2604    65611    lote idlote    DEFAULT     j   ALTER TABLE ONLY public.lote ALTER COLUMN idlote SET DEFAULT nextval('public.lote_idlote_seq'::regclass);
 :   ALTER TABLE public.lote ALTER COLUMN idlote DROP DEFAULT;
       public       postgres    false    200    199                       2604    65612    materia_prima id    DEFAULT     t   ALTER TABLE ONLY public.materia_prima ALTER COLUMN id SET DEFAULT nextval('public.materia_prima_id_seq'::regclass);
 ?   ALTER TABLE public.materia_prima ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    202    201                       2604    65613    peso_automatico id_peso    DEFAULT     �   ALTER TABLE ONLY public.peso_automatico ALTER COLUMN id_peso SET DEFAULT nextval('public.peso_automatico_id_peso_seq'::regclass);
 F   ALTER TABLE public.peso_automatico ALTER COLUMN id_peso DROP DEFAULT;
       public       postgres    false    204    203                        2604    65615    proveedor id    DEFAULT     l   ALTER TABLE ONLY public.proveedor ALTER COLUMN id SET DEFAULT nextval('public.proveedor_id_seq'::regclass);
 ;   ALTER TABLE public.proveedor ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    207    205            !           2604    65616    proveedor fk_mp    DEFAULT     r   ALTER TABLE ONLY public.proveedor ALTER COLUMN fk_mp SET DEFAULT nextval('public.proveedor_fk_mp_seq'::regclass);
 >   ALTER TABLE public.proveedor ALTER COLUMN fk_mp DROP DEFAULT;
       public       postgres    false    206    205            #           2604    65749    supermercado id    DEFAULT     r   ALTER TABLE ONLY public.supermercado ALTER COLUMN id SET DEFAULT nextval('public.supermercado_id_seq'::regclass);
 >   ALTER TABLE public.supermercado ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    213    212    213            )           2604    66058    venta idventa    DEFAULT     n   ALTER TABLE ONLY public.venta ALTER COLUMN idventa SET DEFAULT nextval('public.venta_idventa_seq'::regclass);
 <   ALTER TABLE public.venta ALTER COLUMN idventa DROP DEFAULT;
       public       postgres    false    226    227    227            �          0    65735    cerveza 
   TABLE DATA               H   COPY public.cerveza (idcerveza, tipo, presentacion, precio) FROM stdin;
    public       postgres    false    211   ��                 0    66115    comisionvendedor 
   TABLE DATA               B   COPY public.comisionvendedor (fkvendedor, cantganada) FROM stdin;
    public       postgres    false    230   ��                 0    65789    estado_almacenMP 
   TABLE DATA               b   COPY public."estado_almacenMP" (idalmacenmp, fecha, cantidadalmacenada, fklote, fkmp) FROM stdin;
    public       postgres    false    218   P�                 0    65813    estado_almacenPro 
   TABLE DATA               d   COPY public."estado_almacenPro" (idalmacenpro, fecha, cantidadalmacenada, fklote, fkmp) FROM stdin;
    public       postgres    false    220   ^�                 0    66243    estado_almacenembotellado 
   TABLE DATA               a   COPY public.estado_almacenembotellado (id, fecha, cantidadembotellada, fklote, fkmp) FROM stdin;
    public       postgres    false    237   5�                 0    65929    historico_almacenMP 
   TABLE DATA               g   COPY public."historico_almacenMP" ("idalmacenMP", fecha, cantidadalmacenada, fklote, fkmp) FROM stdin;
    public       postgres    false    224   ��       	          0    65841    historico_almacenPRO 
   TABLE DATA               i   COPY public."historico_almacenPRO" ("idalmacenPRO", fecha, cantidadalmacenada, fklote, fkmp) FROM stdin;
    public       postgres    false    222   ��                 0    66259    historico_almacenemb 
   TABLE DATA               c   COPY public.historico_almacenemb (idalmacen, fecha, cantidadembotellada, fklote, fkmp) FROM stdin;
    public       postgres    false    241   ��       �          0    65555    inventario_almacenMP 
   TABLE DATA               [   COPY public."inventario_almacenMP" ("id_almacenMP", fkmp, cantidad, cantlotes) FROM stdin;
    public       postgres    false    196   K�                 0    66251    inventario_embotellado 
   TABLE DATA               O   COPY public.inventario_embotellado (id, fkmp, cantidad, cantlotes) FROM stdin;
    public       postgres    false    239   ��       �          0    65728    inventario_produccion 
   TABLE DATA               Z   COPY public.inventario_produccion ("idalmacenPRO", fkmp, cantidad, cantlotes) FROM stdin;
    public       postgres    false    209   ��                 0    65757    inventariocerveza 
   TABLE DATA               J   COPY public.inventariocerveza (id, fkcerveza, cantdisponible) FROM stdin;
    public       postgres    false    215   ��       �          0    65562    lote 
   TABLE DATA               d   COPY public.lote (idlote, cantidadenviada, fecha, fkproveedor, fkmp, estado, "precio$") FROM stdin;
    public       postgres    false    199   +�       �          0    65567    materia_prima 
   TABLE DATA               1   COPY public.materia_prima (id, tipo) FROM stdin;
    public       postgres    false    201   ��       �          0    65575    peso_automatico 
   TABLE DATA               9   COPY public.peso_automatico (id_peso, marca) FROM stdin;
    public       postgres    false    203   ��       �          0    65591 	   proveedor 
   TABLE DATA               T   COPY public.proveedor (id, nombre, direccion, ciudad, pais, tlf, fk_mp) FROM stdin;
    public       postgres    false    205   �                  0    65746    supermercado 
   TABLE DATA               O   COPY public.supermercado (id, nombre, telefono, ubicacion, ciudad) FROM stdin;
    public       postgres    false    213   ��                 0    65763    vendedor 
   TABLE DATA               X   COPY public.vendedor (cedula, nombre, apellido, fecha_nacimiento, telefono) FROM stdin;
    public       postgres    false    216   ��                 0    66055    venta 
   TABLE DATA               i   COPY public.venta (idventa, fkcliente, fkvendedor, fkproducto, cantidad, total, hora, fecha) FROM stdin;
    public       postgres    false    227   ��       -           0    0    cerveza_idcerveza_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.cerveza_idcerveza_seq', 1, false);
            public       postgres    false    210            .           0    0 !   estado_almacenMP_id_almacenMP_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public."estado_almacenMP_id_almacenMP_seq"', 282, true);
            public       postgres    false    217            /           0    0 "   estado_almacenPro_idalmacenpro_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('public."estado_almacenPro_idalmacenpro_seq"', 139, true);
            public       postgres    false    219            0           0    0     estado_almacenembotellado_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.estado_almacenembotellado_id_seq', 17, true);
            public       postgres    false    236            1           0    0 #   historico_almacenMP_idalmacenMP_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public."historico_almacenMP_idalmacenMP_seq"', 244, true);
            public       postgres    false    223            2           0    0 %   historico_almacenPRO_idalmacenPRO_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public."historico_almacenPRO_idalmacenPRO_seq"', 140, true);
            public       postgres    false    221            3           0    0 "   historico_almacenemb_idalmacen_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.historico_almacenemb_idalmacen_seq', 17, true);
            public       postgres    false    240            4           0    0    inventarioCerveza_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public."inventarioCerveza_id_seq"', 1, false);
            public       postgres    false    214            5           0    0 (   inventario_almacenMP_fk_materiaprima_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public."inventario_almacenMP_fk_materiaprima_seq"', 1, false);
            public       postgres    false    197            6           0    0 %   inventario_almacenMP_id_almacenMP_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public."inventario_almacenMP_id_almacenMP_seq"', 1, false);
            public       postgres    false    198            7           0    0    inventario_embotellado_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.inventario_embotellado_id_seq', 1, false);
            public       postgres    false    238            8           0    0    lote_idlote_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.lote_idlote_seq', 424, true);
            public       postgres    false    200            9           0    0    materia_prima_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.materia_prima_id_seq', 1, false);
            public       postgres    false    202            :           0    0    peso_automatico_id_peso_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.peso_automatico_id_peso_seq', 1, false);
            public       postgres    false    204            ;           0    0    proveedor_fk_mp_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.proveedor_fk_mp_seq', 4, true);
            public       postgres    false    206            <           0    0    proveedor_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.proveedor_id_seq', 1, false);
            public       postgres    false    207            =           0    0    supermercado_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.supermercado_id_seq', 1, false);
            public       postgres    false    212            >           0    0    venta_idventa_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.venta_idventa_seq', 9, true);
            public       postgres    false    226            =           2606    65743    cerveza cerveza_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.cerveza
    ADD CONSTRAINT cerveza_pkey PRIMARY KEY (idcerveza);
 >   ALTER TABLE ONLY public.cerveza DROP CONSTRAINT cerveza_pkey;
       public         postgres    false    211            E           2606    65794 &   estado_almacenMP estado_almacenMP_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public."estado_almacenMP"
    ADD CONSTRAINT "estado_almacenMP_pkey" PRIMARY KEY (idalmacenmp);
 T   ALTER TABLE ONLY public."estado_almacenMP" DROP CONSTRAINT "estado_almacenMP_pkey";
       public         postgres    false    218            H           2606    65818 (   estado_almacenPro estado_almacenPro_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public."estado_almacenPro"
    ADD CONSTRAINT "estado_almacenPro_pkey" PRIMARY KEY (idalmacenpro);
 V   ALTER TABLE ONLY public."estado_almacenPro" DROP CONSTRAINT "estado_almacenPro_pkey";
       public         postgres    false    220            W           2606    66248 8   estado_almacenembotellado estado_almacenembotellado_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.estado_almacenembotellado
    ADD CONSTRAINT estado_almacenembotellado_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.estado_almacenembotellado DROP CONSTRAINT estado_almacenembotellado_pkey;
       public         postgres    false    237            O           2606    65934 ,   historico_almacenMP historico_almacenMP_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY public."historico_almacenMP"
    ADD CONSTRAINT "historico_almacenMP_pkey" PRIMARY KEY ("idalmacenMP");
 Z   ALTER TABLE ONLY public."historico_almacenMP" DROP CONSTRAINT "historico_almacenMP_pkey";
       public         postgres    false    224            K           2606    65846 .   historico_almacenPRO historico_almacenPRO_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public."historico_almacenPRO"
    ADD CONSTRAINT "historico_almacenPRO_pkey" PRIMARY KEY ("idalmacenPRO");
 \   ALTER TABLE ONLY public."historico_almacenPRO" DROP CONSTRAINT "historico_almacenPRO_pkey";
       public         postgres    false    222            A           2606    65762 (   inventariocerveza inventarioCerveza_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.inventariocerveza
    ADD CONSTRAINT "inventarioCerveza_pkey" PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.inventariocerveza DROP CONSTRAINT "inventarioCerveza_pkey";
       public         postgres    false    215            /           2606    65620 .   inventario_almacenMP inventario_almacenMP_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public."inventario_almacenMP"
    ADD CONSTRAINT "inventario_almacenMP_pkey" PRIMARY KEY ("id_almacenMP");
 \   ALTER TABLE ONLY public."inventario_almacenMP" DROP CONSTRAINT "inventario_almacenMP_pkey";
       public         postgres    false    196            Y           2606    66256 2   inventario_embotellado inventario_embotellado_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.inventario_embotellado
    ADD CONSTRAINT inventario_embotellado_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.inventario_embotellado DROP CONSTRAINT inventario_embotellado_pkey;
       public         postgres    false    239            ;           2606    65732 0   inventario_produccion inventario_produccion_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.inventario_produccion
    ADD CONSTRAINT inventario_produccion_pkey PRIMARY KEY ("idalmacenPRO");
 Z   ALTER TABLE ONLY public.inventario_produccion DROP CONSTRAINT inventario_produccion_pkey;
       public         postgres    false    209            3           2606    65622    lote lote_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.lote
    ADD CONSTRAINT lote_pkey PRIMARY KEY (idlote);
 8   ALTER TABLE ONLY public.lote DROP CONSTRAINT lote_pkey;
       public         postgres    false    199            5           2606    65624     materia_prima materia_prima_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.materia_prima
    ADD CONSTRAINT materia_prima_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.materia_prima DROP CONSTRAINT materia_prima_pkey;
       public         postgres    false    201            7           2606    65626 $   peso_automatico peso_automatico_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.peso_automatico
    ADD CONSTRAINT peso_automatico_pkey PRIMARY KEY (id_peso);
 N   ALTER TABLE ONLY public.peso_automatico DROP CONSTRAINT peso_automatico_pkey;
       public         postgres    false    203            9           2606    65630    proveedor proveedor_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.proveedor DROP CONSTRAINT proveedor_pkey;
       public         postgres    false    205            ?           2606    65754    supermercado supermercado_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.supermercado
    ADD CONSTRAINT supermercado_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.supermercado DROP CONSTRAINT supermercado_pkey;
       public         postgres    false    213            C           2606    65770    vendedor vendedor_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.vendedor
    ADD CONSTRAINT vendedor_pkey PRIMARY KEY (cedula);
 @   ALTER TABLE ONLY public.vendedor DROP CONSTRAINT vendedor_pkey;
       public         postgres    false    216            T           2606    66060    venta venta_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.venta
    ADD CONSTRAINT venta_pkey PRIMARY KEY (idventa);
 :   ALTER TABLE ONLY public.venta DROP CONSTRAINT venta_pkey;
       public         postgres    false    227            -           1259    65681 	   fki_fk_MP    INDEX     N   CREATE INDEX "fki_fk_MP" ON public."inventario_almacenMP" USING btree (fkmp);
    DROP INDEX public."fki_fk_MP";
       public         postgres    false    196            0           1259    65698 
   fki_fk_MP2    INDEX     =   CREATE INDEX "fki_fk_MP2" ON public.lote USING btree (fkmp);
     DROP INDEX public."fki_fk_MP2";
       public         postgres    false    199            F           1259    65800    fki_fk_lote2    INDEX     M   CREATE INDEX fki_fk_lote2 ON public."estado_almacenMP" USING btree (fklote);
     DROP INDEX public.fki_fk_lote2;
       public         postgres    false    218            I           1259    65899    fki_fk_lote3    INDEX     N   CREATE INDEX fki_fk_lote3 ON public."estado_almacenPro" USING btree (fklote);
     DROP INDEX public.fki_fk_lote3;
       public         postgres    false    220            1           1259    65704    fki_fk_proveedor    INDEX     H   CREATE INDEX fki_fk_proveedor ON public.lote USING btree (fkproveedor);
 $   DROP INDEX public.fki_fk_proveedor;
       public         postgres    false    199            P           1259    66084    fki_fkcerveza    INDEX     E   CREATE INDEX fki_fkcerveza ON public.venta USING btree (fkproducto);
 !   DROP INDEX public.fki_fkcerveza;
       public         postgres    false    227            Q           1259    66072    fki_fkcliente    INDEX     D   CREATE INDEX fki_fkcliente ON public.venta USING btree (fkcliente);
 !   DROP INDEX public.fki_fkcliente;
       public         postgres    false    227            L           1259    66000    fki_fkloteee    INDEX     P   CREATE INDEX fki_fkloteee ON public."historico_almacenMP" USING btree (fklote);
     DROP INDEX public.fki_fkloteee;
       public         postgres    false    224            M           1259    66006 	   fki_fkmp3    INDEX     K   CREATE INDEX fki_fkmp3 ON public."historico_almacenMP" USING btree (fkmp);
    DROP INDEX public.fki_fkmp3;
       public         postgres    false    224            R           1259    66078    fki_fkvendedor    INDEX     F   CREATE INDEX fki_fkvendedor ON public.venta USING btree (fkvendedor);
 "   DROP INDEX public.fki_fkvendedor;
       public         postgres    false    227            U           1259    66126    fki_fkvendedor2    INDEX     R   CREATE INDEX fki_fkvendedor2 ON public.comisionvendedor USING btree (fkvendedor);
 #   DROP INDEX public.fki_fkvendedor2;
       public         postgres    false    230            l           2620    66130    venta gananciavendedor    TRIGGER     �   CREATE TRIGGER gananciavendedor AFTER INSERT ON public.venta FOR EACH ROW EXECUTE PROCEDURE public.actualizarganaciavendedor();
 /   DROP TRIGGER gananciavendedor ON public.venta;
       public       postgres    false    227    258            g           2620    65907    lote historicomp    TRIGGER     t   CREATE TRIGGER historicomp AFTER INSERT ON public.lote FOR EACH ROW EXECUTE PROCEDURE public.insertarhistoricomp();
 )   DROP TRIGGER historicomp ON public.lote;
       public       postgres    false    255    199            i           2620    66136 !   vendedor insertarvendedorganancia    TRIGGER     �   CREATE TRIGGER insertarvendedorganancia AFTER INSERT ON public.vendedor FOR EACH ROW EXECUTE PROCEDURE public.insertarvendedorganancia();
 :   DROP TRIGGER insertarvendedorganancia ON public.vendedor;
       public       postgres    false    259    216            m           2620    66102    venta inventariocerveza    TRIGGER     �   CREATE TRIGGER inventariocerveza AFTER INSERT ON public.venta FOR EACH ROW EXECUTE PROCEDURE public.actualizarinventariocerveza();
 0   DROP TRIGGER inventariocerveza ON public.venta;
       public       postgres    false    257    227            j           2620    66522 *   historico_almacenPRO inventarioembotellado    TRIGGER     �   CREATE TRIGGER inventarioembotellado AFTER INSERT ON public."historico_almacenPRO" FOR EACH ROW EXECUTE PROCEDURE public.actualizarcantidadembotellado();
 E   DROP TRIGGER inventarioembotellado ON public."historico_almacenPRO";
       public       postgres    false    222    262            h           2620    66483    lote inventariomp    TRIGGER     x   CREATE TRIGGER inventariomp AFTER INSERT ON public.lote FOR EACH ROW EXECUTE PROCEDURE public.actualizarinventariomp();
 *   DROP TRIGGER inventariomp ON public.lote;
       public       postgres    false    199    260            k           2620    66515 (   historico_almacenMP inventarioproducciom    TRIGGER     �   CREATE TRIGGER inventarioproducciom AFTER INSERT ON public."historico_almacenMP" FOR EACH ROW EXECUTE PROCEDURE public.actualizarcantidadproduccion();
 C   DROP TRIGGER inventarioproducciom ON public."historico_almacenMP";
       public       postgres    false    261    224            f           2620    65727    inventario_almacenMP validarmp    TRIGGER     �   CREATE TRIGGER validarmp BEFORE INSERT ON public."inventario_almacenMP" FOR EACH ROW EXECUTE PROCEDURE public.verificarnegativos();
 9   DROP TRIGGER validarmp ON public."inventario_almacenMP";
       public       postgres    false    242    196            Z           2606    65676    inventario_almacenMP fk_MP    FK CONSTRAINT     �   ALTER TABLE ONLY public."inventario_almacenMP"
    ADD CONSTRAINT "fk_MP" FOREIGN KEY (fkmp) REFERENCES public.materia_prima(id);
 H   ALTER TABLE ONLY public."inventario_almacenMP" DROP CONSTRAINT "fk_MP";
       public       postgres    false    201    196    2869            [           2606    65693    lote fk_MP2    FK CONSTRAINT     q   ALTER TABLE ONLY public.lote
    ADD CONSTRAINT "fk_MP2" FOREIGN KEY (fkmp) REFERENCES public.materia_prima(id);
 7   ALTER TABLE ONLY public.lote DROP CONSTRAINT "fk_MP2";
       public       postgres    false    2869    201    199            ]           2606    65795    estado_almacenMP fk_lote2    FK CONSTRAINT     |   ALTER TABLE ONLY public."estado_almacenMP"
    ADD CONSTRAINT fk_lote2 FOREIGN KEY (fklote) REFERENCES public.lote(idlote);
 E   ALTER TABLE ONLY public."estado_almacenMP" DROP CONSTRAINT fk_lote2;
       public       postgres    false    218    2867    199            _           2606    65894    estado_almacenPro fk_lote3    FK CONSTRAINT     }   ALTER TABLE ONLY public."estado_almacenPro"
    ADD CONSTRAINT fk_lote3 FOREIGN KEY (fklote) REFERENCES public.lote(idlote);
 F   ALTER TABLE ONLY public."estado_almacenPro" DROP CONSTRAINT fk_lote3;
       public       postgres    false    199    2867    220            \           2606    65699    lote fk_proveedor    FK CONSTRAINT     x   ALTER TABLE ONLY public.lote
    ADD CONSTRAINT fk_proveedor FOREIGN KEY (fkproveedor) REFERENCES public.proveedor(id);
 ;   ALTER TABLE ONLY public.lote DROP CONSTRAINT fk_proveedor;
       public       postgres    false    205    2873    199            d           2606    66079    venta fkcerveza    FK CONSTRAINT     z   ALTER TABLE ONLY public.venta
    ADD CONSTRAINT fkcerveza FOREIGN KEY (fkproducto) REFERENCES public.cerveza(idcerveza);
 9   ALTER TABLE ONLY public.venta DROP CONSTRAINT fkcerveza;
       public       postgres    false    211    2877    227            b           2606    66067    venta fkcliente    FK CONSTRAINT     w   ALTER TABLE ONLY public.venta
    ADD CONSTRAINT fkcliente FOREIGN KEY (fkcliente) REFERENCES public.supermercado(id);
 9   ALTER TABLE ONLY public.venta DROP CONSTRAINT fkcliente;
       public       postgres    false    227    213    2879            ^           2606    66402    estado_almacenMP fklote4    FK CONSTRAINT     {   ALTER TABLE ONLY public."estado_almacenMP"
    ADD CONSTRAINT fklote4 FOREIGN KEY (fklote) REFERENCES public.lote(idlote);
 D   ALTER TABLE ONLY public."estado_almacenMP" DROP CONSTRAINT fklote4;
       public       postgres    false    218    2867    199            `           2606    65995    historico_almacenMP fkloteee    FK CONSTRAINT        ALTER TABLE ONLY public."historico_almacenMP"
    ADD CONSTRAINT fkloteee FOREIGN KEY (fklote) REFERENCES public.lote(idlote);
 H   ALTER TABLE ONLY public."historico_almacenMP" DROP CONSTRAINT fkloteee;
       public       postgres    false    2867    224    199            a           2606    66001    historico_almacenMP fkmp3    FK CONSTRAINT        ALTER TABLE ONLY public."historico_almacenMP"
    ADD CONSTRAINT fkmp3 FOREIGN KEY (fkmp) REFERENCES public.materia_prima(id);
 E   ALTER TABLE ONLY public."historico_almacenMP" DROP CONSTRAINT fkmp3;
       public       postgres    false    201    2869    224            c           2606    66073    venta fkvendedor    FK CONSTRAINT     y   ALTER TABLE ONLY public.venta
    ADD CONSTRAINT fkvendedor FOREIGN KEY (fkvendedor) REFERENCES public.vendedor(cedula);
 :   ALTER TABLE ONLY public.venta DROP CONSTRAINT fkvendedor;
       public       postgres    false    227    216    2883            e           2606    66121    comisionvendedor fkvendedor2    FK CONSTRAINT     �   ALTER TABLE ONLY public.comisionvendedor
    ADD CONSTRAINT fkvendedor2 FOREIGN KEY (fkvendedor) REFERENCES public.vendedor(cedula);
 F   ALTER TABLE ONLY public.comisionvendedor DROP CONSTRAINT fkvendedor2;
       public       postgres    false    216    2883    230            �   e   x�3�,JM���K�Q��L�(�L�/I��IT065P���4600�2�*��LĐ3�sd���K�4�����XRa
�n
5E��f.��HK� ��3�         E   x����@��K1�5GzI�u~�F�`\���"�ӵH�j���6f�:���3�`���{���         �   x�]��C!��K"��^�������j�1bk���~h���)�;���\��=4d�SOGb�X�&��%
��$��j�[Y%��'P}du/��GV���iX����A=-�aܻ�2�e�\�`�K�,Þ71�e���`�ư��_V	tb?OeL���%�΢wZ���;��Y�K2��]'Wd�,��*	`����Y�7)���en\��Z�_b�庖�CaX�k�~���rs/�
,���H\�����(��         �   x�]й�@Dј���={q�ux8H<��5�j���W��=b��,�/yo�P�>�`#��;�%��x�G�k_�_�ҭ/�_N�N/.����9�0�g���)�UNQ0s|�O;��ݨ�_��K0����ј֧s�"{��	fND?I�!W%N��ʨJ􁝕Q�8C2+�*чs;+��%�Ageܾd����~����`�         �   x�]йC1�z�����:���0eO�XA`~_/�2�k�q#�B�]����g��{�&�)49�ɇn���E��OC&u�?w��SO*Jϣ�[���L�x4cy�us[d._}?�w������V�/�$78         �   x�]�A�� ��/�
N����;��P�R�,�I`����1���h�V�lW�;q�����7q��I܅qp�9��*q�%L�Г�>�%CxV��T�[���Wx�'3-˾�iY�c&K���,�ڝX�(��qD�%���3Yb�;	�%�}�0Y��bY�:Z�H��^U�����hF,�7a��]:��y^1���t|�t�LᷮjK�W�$�>��8�,�Xҏ��c��2�%�87d^K�A�2��L���}����P      	   �   x�]���0Dѳ�K.Z{I�ud8҆Z_�������m��=M��L�/y%o�i�u��J>uw�5���6؃M�<�◦uI�r�-�pzq��y�g�X�{�`Z�\rf0s켧�|�nT*s\��㦃98�2ǭNǒE�zU��$����8q0+=+�6VzV�����D�m��[����C���߷���Z`�         �   x�]йC1�z�����:���0eO�XA`~_/�2�k�q#�B�]����g��{�&�)49�ɇn���E��OC&u�?w��SO*Jϣ�[���L�x4cy�us[d._}?�w������V�/�$78      �   &   x�3�4�44�4�2�4��4�2�4�44
��qqq ?��         '   x�3�4�42�4�2�4�44�4�2�4�4� ���qqq E      �   &   x�3�4�41�44�2�BCN3.cNcNS�P� N�m         -   x���  ���� `3�_��~6�U����$���2��-I~v{      �   V  x���Kn�0�s�y���t�$h��o����U����k8%���$�ӹ���2�����t�z'B�f؃�FGө!��!��+H>J���L��dݚ-�Z��mo-�c�O�y�9Z�u:�8e�v.�D}Ey����9��c<����{����Z�T��h���EZ��"@Z-1�P��B��3�N��w
�z�-+�/�uӭZ���]����5>���p����[�!:؝��j7�K�d+�����n��7�L�Km����n�+m��*!�ٺT��߻^9Dpq��{���Al�T|Hƕ�H/s�($j��ǺN>?���{{G�      �   1   x�3�LNMJLI�2��)-(���2��&�+��&g��\1z\\\ F|�      �   3   x�3��q�2�t�IL�v�KqIM�N-�2��p��&����Vp��qqq *      �   �   x�U�1k�0�g�Wx?(ر����L)�v(]�D�|88���UzP�I��}ߓ�(Y��M�rf�!n��=����p�C���e��F��	��4����K*I��Ti�4�qᯍ�N:)	�;)ɛڙk��Nd���OL��B��*^�-ߨ?@c����+��k�ʢ?���s��u:B�Bk���{��ʿg�F�7�z>�1߫,U(          �   x�m�A
�0E��)r11���BAݹ�m
�v�ӛV)�]����h�)ت6�b"�7���@��nbh�kL҈�Ũ�#2M\�L��"��A���Ϥɛ�e��)�cb�V�γ�6� v�>,��/�̷���s�mw
.?
Y��q@Q��C���q�����t�V0         �   x�5��N� @�ÿ`f�C�Ǎ1��x���h�i!����;�.$<o���L/����Q�-�kM�@Sp�� (�+8��@��F�l_5-^�=�����`�)O���5$�O���8k��u�[��ER����d�L,p]KN��'#bK뱓�ꥠ[���s��j�&Kl�'(�Z/f
^�	.�(y-�X���}��'H�j�8�Η�1/�<�z��4����?B�Þ0<-߱�s�w44CC[39o>�1ԻU�         �   x�]���@�3ۋW�g���_G��X�ŕ7��2���z`�L��Y&3C|�`%a��r���m
�aZ|"p���㉴��M������U��={��X/��� �}�����俨��u�^�i@�]��v8�e��}(B���5�o�W7�     