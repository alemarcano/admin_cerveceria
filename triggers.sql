select * from "inventario_almacenMP"
ALTER TABLE "historico_almacenMP" ALTER COLUMN id_almacenMP TYPE varchar(20)
ALTER TABLE "historico_almacenMP" ADD COLUMN "fk_lote" integer;
ALTER TABLE "inventario_almacenMP" RENAME COLUMN "fk_materiaprima" TO fkMP
ALTER TABLE "inventario_almacenMP" ADD COLUMN cantlotes integer


/*Procedimiento almacenado de pasar de Lote a Historico MP*/
CREATE OR REPLACE FUNCTION InsertarHistoricoMP() RETURNS TRIGGER AS
$$
BEGIN
INSERT INTO "historico_almacenMP"(fecha,cantidad_almacenada, fk_lote) values (new.fecha, new.cantidadenviada, new.idlote);
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
	cant := (SELECT cantidad FROM "inventario_almacenMP"  where "fk_materiaprima" = new.fkmp);
	lot := (SELECT cantlotes FROM "inventario_almacenMP"  where "fk_materiaprima" = new.fkmp);
	lot2 := (SELECT COUNT(idlote) FROM lote where fkmp=new.fkmp);
	UPDATE "inventario_almacenMP" SET
	cantidad = cant + new.cantidadenviada,
	cantlotes = lot2
	where "fk_materiaprima" = new.fkMP;

RETURN NULL;

END;
$$ language 'plpgsql'

select * from "inventario_almacenMP"
select * from "historico_almacenMP"
select * from lote

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
CREATE OR REPLACE FUNCTION VerificarCantidadProduccion() RETURNS TRIGGER AS
$$
DECLARE
materia1 integer:= (SELECT cantlotes FROM "inventario_almacenMP"  where "fk_materiaprima" = '1');
materia2 integer:= (SELECT cantlotes FROM "inventario_almacenMP"  where "fk_materiaprima" = '2');
materia3 integer:= (SELECT cantlotes FROM "inventario_almacenMP"  where "fk_materiaprima" = '3');
cant integer;
lot integer;
lot2 integer;
/*Falta poner la condicion que lo pase a produccion luego de una semana NO SE COMO HACERLO */

BEGIN
	IF (materia1 = 0 AND materia2 = 0 AND materia3 = 0) THEN
		RAISE EXCEPTION 'No hay lotes de materia prima para pasar a produccion';
	ELSE
	
	cant := (SELECT cantidad FROM "inventario_produccion"  where "fk_materiaprima" = new."fk_materiaprima");
	lot := (SELECT cantlotes FROM "inventario_produccion"  where "fk_materiaprima" = new."fk_materiaprima");
	lot2 := (SELECT COUNT(idlote) FROM lote where fkmp=new.fkmp);
	UPDATE "inventario_almacenMP" SET
	cantidad = cant - new.cantidad,
	cantlotes = lot2
	where "fk_materiaprima" = new."fk_materiaprima";
	
	UPDATE "inventario_produccion" SET
	cantidad = cant + new.cantidad,
	cantlotes = lot2
	where "fk_materiaprima" = new."fk_materiaprima";
		
	END IF;

RETURN NEW;

END;
$$ language 'plpgsql'




