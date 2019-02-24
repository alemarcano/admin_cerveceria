select * from "proveedorlote"
ALTER TABLE "lote" ALTER COLUMN precio$ TYPE float
ALTER TABLE "venta" ADD COLUMN "fecha" date;
ALTER TABLE "inventarioCerveza" RENAME COLUMN "cantDisponible" TO cantdisponible
ALTER TABLE "lote" ADD COLUMN precio$ real
ALTER TABLE "comisionvendedor" DROP COLUMN id;

select * from "estado_almacenMP"
/*Procedimiento almacenado de pasar de Lote a Historico MP y Estado Lote*/
CREATE OR REPLACE FUNCTION InsertarHistoricoMP() RETURNS TRIGGER AS
$$
BEGIN
INSERT INTO "historico_almacenMP"(fecha,cantidadalmacenada, fklote, fkmp) values (new.fecha, new.cantidadenviada, new.idlote, new.fkmp);
INSERT INTO "estado_almacenMP"(fecha,cantidadalmacenada, fklote, fkmp) values (new.fecha, new.cantidadenviada, new.idlote, new.fkmp);

RETURN NULL;

END;
$$ language 'plpgsql'

/*Trigger de pasar de Lote a Historico MP*/
CREATE TRIGGER HistoricoMP AFTER INSERT ON lote
for each row execute procedure InsertarHistoricoMP()

/*Procedimiento almacenado para actualizar inventario de MP*/
CREATE OR REPLACE FUNCTION ActualizarInventarioMP() RETURNS TRIGGER AS
$$
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
$$ language 'plpgsql'

select * from "inventario_almacenMP"
select * from "historico_almacenMP"
select * from lote
select * from "estado_almacenMP"

/*Trigger de pasar de Lote a Historico MP*/
CREATE TRIGGER InventarioMP AFTER INSERT ON lote
for each row execute procedure ActualizarInventarioMP()

SELECT COUNT(idlote) FROM lote where fkmp='1'

/*Insert de prueba que me lo genero random por python*/
INSERT INTO lote ("cantidadenviada", "fecha", "fk_proveedor", "fkmp") VALUES  ('5000','2019-02-10','1','1')


/*Procedimiento almacenado para verificar que la cantidad de lotes y materia prima no sea negativa*/
CREATE OR REPLACE FUNCTION VerificarNegativos() RETURNS TRIGGER AS
$$

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
$$ language 'plpgsql'

/*Trigger para verificar que la cantidad de lotes y materia prima no sea negativa*/
CREATE TRIGGER ValidarMP BEFORE INSERT ON "inventario_almacenMP"
FOR EACH ROW EXECUTE PROCEDURE VerificarNegativos()


/*Procedimiento almacenado antes de insertar a produccion para asegurar que hay un lote de lupula, uno de cereales y uno de cebada */
CREATE OR REPLACE FUNCTION ActualizarCantidadProduccion() RETURNS TRIGGER AS
$$
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
$$ language 'plpgsql'

CREATE TRIGGER InventarioProducciom AFTER INSERT ON "historico_almacenMP"
for each row execute procedure ActualizarCantidadProduccion()


/*VISTA PARA TRAERTE TODO LOS LOTES Y SABER EN QUE ESTADO ESTAN*/
CREATE VIEW EstadoLote AS
SELECT l.idlote  as " Nro. Lote ", mp.tipo as "Materia Prima", l.estado as "Estado Actual" from lote l
inner join "materia_prima" mp on mp.id = l.fkmp

/*VISTA PARA VER EL PAGO DEL PROVEEDOR CON LA FECHA Y LA CANTIDAD EN DOLARES*/
CREATE VIEW PagosProveedor AS
SELECT l.idlote  as " Nro. Lote ", mp.tipo as "Materia Prima", p.nombre as "Proveedor", 
CONCAT(p.ciudad, ', ', p.pais) as "Ubicacion", l.cantidadenviada as "Toneladas Compradas", l.precio$ as "Cantidad ($)", l.fecha as "Fecha de Pago"
from lote l
inner join "materia_prima" mp on mp.id = l.fkmp
inner join "proveedor" p on p.id = l.fkproveedor

/*VISTA PARA VER LA CANTIDAD DE DOLARES TOTALES PAGADOS A UN PROVEEDOR*/
CREATE VIEW SumaPagosProveedor AS
select  p.nombre as "Proveedor", mp.tipo as "Materia Prima", SUM(l.precio$) as "Total de $ pagados" from lote l
inner join "proveedor" p on p.id = l.fkproveedor
inner join "materia_prima" mp on mp.id = l.fkmp
group by p.nombre, mp.tipo


/*VISTA PARA VER LA CANTIDAD DE MATERIA PRIMA ALMACENADA Y SUS LOTES*/
CREATE VIEW InventarioMP AS
SELECT m.tipo as "Materia Prima", imp.cantidad as "Toneladas Almacenadas", imp.cantlotes as "Cantidad de Lotes" 
from "inventario_almacenMP" imp
inner join "materia_prima" m on m.id = imp.fkmp
order by "Materia Prima"

/*VISTA PARA VER LA CANTIDAD DE MATERIA PRIMA ALMACENADA EN PRODUCCION Y SUS LOTES*/
CREATE VIEW InventarioProduccion AS
SELECT m.tipo as "Materia Prima", ip.cantidad as "Toneladas Almacenadas", ip.cantlotes as "Cantidad de Lotes" 
from "inventario_produccion" ip
inner join "materia_prima" m on m.id = ip.fkmp
order by "Materia Prima"

/*////////////////////////////////////////////// Seccion de VENTAS /////////////////////////////////////////////////// */

CREATE OR REPLACE FUNCTION InsertarVenta(idclient integer, idvende integer,  idproduct integer, cant integer ) RETURNS void AS
$$
DECLARE
totaly real;
BEGIN
totaly:= (SELECT precio from cerveza where idcerveza = idproduct )*cant;
INSERT INTO "venta"(fkcliente,fkvendedor, fkproducto, cantidad, total, hora, fecha) values (idclient, idvende,  idproduct, cant, totaly, current_time, current_date);
END;
$$ language 'plpgsql'

Select InsertarVenta(1, 1, 1, 3 )

Create view VentaRealizada as
SELECT v.idventa as "Numero Venta", s.nombre as "Supermercado", CONCAT(ve.nombre, ' ',ve.apellido ) as "Vendedor", 
CONCAT(c.presentacion, ' ',c.tipo ) as "Cerveza", v.cantidad as "Cantidad", v.total as "Total Bs", v.hora as "Hora", v.fecha as "Fecha"
from venta v 
inner join supermercado s on s.id = v.fkcliente
inner join cerveza c on c.idcerveza = v.fkproducto
inner join vendedor ve on ve.cedula = v.fkvendedor
/*Actualizar inventario y aumentar la comision del vendedor*/

select * from "inventariocerveza"

/*Procedimiento almacenado para actualizar inventario de la cerveza*/
CREATE OR REPLACE FUNCTION ActualizarInventarioCerveza() RETURNS TRIGGER AS
$$
DECLARE
cant integer;
BEGIN
	cant := (SELECT "cantdisponible" FROM "inventariocerveza"  where "id" = new.fkproducto);
	UPDATE "inventariocerveza" SET
	cantdisponible = cant - new.cantidad
	where "id" = new.fkproducto;

RETURN NULL;

END;
$$ language 'plpgsql'

/*Trigger de pasar de Lote a Historico MP*/
CREATE TRIGGER InventarioCerveza AFTER INSERT ON venta
for each row execute procedure ActualizarInventarioCerveza()

Create view VerInventarioCerveza as
SELECT  CONCAT(c.presentacion, ' ',c.tipo ) as "Cerveza", i.cantdisponible as "Cantidad Disponible"
from "inventariocerveza" i
inner join "cerveza" as c on c.idcerveza = i.fkcerveza

/*Trigger para actualizar el porcentaje de ganancia del vendedor */
CREATE OR REPLACE FUNCTION ActualizarGanaciaVendedor() RETURNS TRIGGER AS
$$
DECLARE
cant integer;
BEGIN
	cant := (SELECT "cantganada" FROM "comisionvendedor"  where "fkvendedor" = new.fkvendedor);
	UPDATE "comisionvendedor" SET
	cantganada = cant + 0.03*(new.total)
	where "fkvendedor" = new.fkvendedor;

RETURN NULL;

END;
$$ language 'plpgsql'

/*Trigger de pasar de Lote a Historico MP*/
CREATE TRIGGER GananciaVendedor AFTER INSERT ON venta
for each row execute procedure ActualizarGanaciaVendedor()


SELECT * from comisionvendedor
SELECT * from vendedor
ALTER TABLE "comisionVendedor" RENAME TO comisionvendedor;

Create view VerGanaciaVendedores as
SELECT  ve.cedula as "Cedula", CONCAT(ve.nombre, ' ',ve.apellido ) as "Nombre Completo", cv.cantganada as "Ganacia 3% de las ventas"
from "vendedor" ve
inner join "comisionvendedor" as cv on cv.fkvendedor = ve.cedula

/*Trigger para insertar en la ganancia el vendedor que se crea*/
CREATE OR REPLACE FUNCTION InsertarVendedorGanancia() RETURNS TRIGGER AS
$$

BEGIN
	INSERT INTO "comisionvendedor"(fkvendedor, cantganada) values ( new.cedula, 0);
RETURN NULL;

END;
$$ language 'plpgsql'

/*Trigger de pasar de Lote a Historico MP*/
CREATE TRIGGER InsertarVendedorGanancia AFTER INSERT ON vendedor
for each row execute procedure InsertarVendedorGanancia()


INSERT INTO "vendedor"(cedula,nombre, apellido, fecha_nacimiento, telefono) values ('26012664','Alejandro' ,'Marcano', '1997/08/30', '04242481954');
