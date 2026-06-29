INSERT INTO Cargos (nombre, descripcion)
VALUES
('Cajero','Realiza cobros'),
('Mozo','Atiende mesas'),
('Cocinero','Prepara pedidos');

INSERT INTO Turnos (nombre, hora_inicio, hora_fin)
VALUES
('Mañana','08:00','16:00'),
('Noche','16:00','00:00');

INSERT INTO Unidades_Medida(nombre,abreviatura)
VALUES
('Unidad','u'),
('Kilogramo','kg'),
('Litro','lts');

INSERT INTO Categorias_Productos(nombre_categoria,descripcion)
VALUES
('Pizzas','Pizzas'),
('Bebidas','Bebidas');

INSERT INTO Metodos_Pago(nombre_metodo,descripcion)
VALUES
('Efectivo','Billete'),
('Tarjeta','Débito o crédito');

INSERT INTO Clientes
(nombre,apellido,dni,telefono,mail,direccion,fecha_registro,estado)
VALUES
('Franco','Fernandez','46001711','+54 9 11 3088-3131','franco@mail.com','Calle 123',GETDATE(),1),
('Sebastian','De La Cruz','11111111','+54 9 11 5923-6366','sebastian@mail.com','Calle 321',GETDATE(),1)
;

INSERT INTO Proveedores
(razon_social,cuit,telefono,mail,direccion)
VALUES
('Distribuidora Sabudiria Del Profe Angel','30712345678','1144556677','proveedor@mail.com','UTN-FRGP | PACHECO | BSAS');

INSERT INTO Mesas
(numero_mesa,capacidad,estado)
VALUES
(1,4,1);

INSERT INTO Empleados
(nombre,apellido,dni,telefono,direccion,fecha_ingreso,sueldo,estado,id_cargo,id_turno)
VALUES
('Lucas','F.','29000111','+54 9 11 1111-2222','Calle Paso 1200',GETDATE(),1500000.01,1,1,1),
('Alejo','A.','46000111','+54 9 11 2222-3333','Calle NoPaso 1200',GETDATE(),1000000.02,1,2,1),
('Diego','M.','25000111','+54 9 11 3333-4444','Calle SiPaso 1200',GETDATE(),999000.03,1,3,1),
('Franco','F.','46001711','+54 9 11 3088-3131','Calle Corte 1200',GETDATE(),1500000.01,1,1,1),
('Seba','DLC.','11111111','+54 9 11 5923-6366','Calle NoCorte 1200',GETDATE(),1000000.02,1,2,1),
('Santiago','X.','40000111','+54 9 11 4444-5555','Calle SiCorte 1200',GETDATE(),999000.03,1,3,1)
;

INSERT INTO Ingredientes
(nombre,stock_disponible,costo_unitario,id_unidad_medida)
VALUES
('Muzzarella',50,8500,2),
('Salsa',20,3500,3);

INSERT INTO Productos
(nombre_producto,descripcion,precio_compra,precio_venta,stock_actual,stock_minimo,estado,fecha_alta,id_categoria,id_unidad_medida)
VALUES
('Pizza Muzzarella','Pizza clásica',3500,9000,20,5,1,GETDATE(),1,1),
('Coca Cola 500ml','Bebida',900,2200,50,10,1,GETDATE(),2,1);

INSERT INTO Compras
(id_proveedor,id_empleado,id_metodo_pago,total,observaciones)
VALUES
(1,1,1,170000,'Compra semanal');

INSERT INTO Ventas
(fecha,subtotal,descuento,total,observaciones,id_cliente,id_empleado,id_mesa)
VALUES
(GETDATE(),11200,0,11200,'Sin observaciones',2,1,3);

INSERT INTO Ingredientes_Producto
(id_producto,id_ingrediente,cantidad_utilizada)
VALUES
(1,1,0.2),
(1,2,0.150);

INSERT INTO Detalle_Compras
(cantidad,costo_unitario,subtotal,id_compra,id_producto)
VALUES
(20,3500,70000,3,1);

INSERT INTO Detalle_Ventas
(cantidad,precio_unitario,subtotal,id_venta,id_producto)
VALUES
(1,9000,9000,3,1),
(1,2200,2200,3,2);

INSERT INTO Metodo_Pago_Venta
(id_venta,id_metodo_pago,importe)
VALUES
(3,1,11200);

