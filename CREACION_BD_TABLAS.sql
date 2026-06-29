CREATE DATABASE BBDD2_UTN;

CREATE TABLE Categorias_Productos
(
	id_categoria INT PRIMARY KEY IDENTITY(1,1),
	nombre_categoria VARCHAR(60) NOT NULL,
	descripcion VARCHAR(300),
);

CREATE TABLE Unidades_Medida
(
	id_unidad_medida INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(50) NOT NULL,
	abreviatura VARCHAR(10) NOT NULL
);

CREATE TABLE Metodos_Pago
(
	id_metodo_pago INT PRIMARY KEY IDENTITY(1,1),
	nombre_metodo VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200) NOT NULL
);

CREATE TABLE Turnos
(
	id_turno INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(20) NOT NULL,
	hora_inicio TIME NOT NULL,
	hora_fin TIME NOT NULL
);

CREATE TABLE Cargos
(
	id_cargo INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(60) NOT NULL,
	descripcion VARCHAR(300) NOT NULL
);

CREATE TABLE Proveedores
(
	id_proveedor INT PRIMARY KEY IDENTITY(1,1),
	razon_social VARCHAR(70) NOT NULL,
	cuit VARCHAR(15) NOT NULL,
	telefono VARCHAR(30) NOT NULL,
	mail VARCHAR(60) NOT NULL,
	direccion VARCHAR(60) NOT NULL
);

CREATE TABLE Clientes
(
	id_cliente INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(60) NOT NULL,
	apellido VARCHAR(60) NOT NULL,
	dni VARCHAR(9) NOT NULL,
	telefono VARCHAR(30) NOT NULL,
	mail VARCHAR(60) NOT NULL,
	direccion VARCHAR(60) NOT NULL,
	fecha_registro DATE NOT NULL,
	estado BIT NOT NULL 
);

CREATE TABLE Mesas
(
	id_mesa INT PRIMARY KEY IDENTITY(1,1),
	numero_mesa TINYINT NOT NULL,
	capacidad TINYINT NOT NULL,
	estado BIT NOT NULL
);

CREATE TABLE Empleados
(
	id_empleado INT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(60) NOT NULL,
	apellido VARCHAR(60) NOT NULL,
	dni VARCHAR(9) NOT NULL,
	telefono VARCHAR(30) NOT NULL,
	direccion VARCHAR(60) NOT NULL,
	fecha_ingreso DATE NOT NULL,
	sueldo DECIMAL(13,2) NOT NULL,
	estado BIT NOT NULL,
	id_cargo INT NOT NULL,
	id_turno INT NOT NULL,
	
	CONSTRAINT FK_Empleados_Cargo
		FOREIGN KEY (id_cargo)
		REFERENCES Cargos(id_cargo),
	
	CONSTRAINT FK_Empleados_Truno
		FOREIGN KEY (id_turno)
		REFERENCES Turnos(id_turno)
); 

CREATE TABLE Productos
(
	id_producto INT PRIMARY KEY IDENTITY(1,1),
	nombre_producto VARCHAR(60) NOT NULL,
	descripcion VARCHAR(250) NOT NULL,
	precio_compra DECIMAL(7,2) NOT NULL,
	precio_venta DECIMAL(7,2) NOT NULL,
	stock_actual INT NOT NULL,
	stock_minimo INT NOT NULL,
	estado BIT NOT NULL,
	fecha_alta DATE NOT NULL,
	id_categoria INT NOT NULL,
	id_unidad_medida INT NOT NULL,
	
	CONSTRAINT FK_Productos_Categoria
		FOREIGN KEY (id_categoria)
		REFERENCES Categorias_Productos(id_categoria),
		
	CONSTRAINT FK_Productos_Unidades_Medida
		FOREIGN KEY (id_unidad_medida)
		REFERENCES Unidades_Medida(id_unidad_medida)
);

CREATE TABLE Ingredientes
(
	id_ingrediente INT PRIMARY KEY IDENTITY (1,1),
	nombre VARCHAR(60) NOT NULL,
	stock_disponible INT NOT NULL,
	costo_unitario DECIMAL(7,2) NOT NULL,
	id_unidad_medida INT NOT NULL,
	
		CONSTRAINT FK_Ingredientes_Unidades_Medida
			FOREIGN KEY (id_unidad_medida)
			REFERENCES Unidades_Medida(id_unidad_medida)
);

CREATE TABLE Ventas
(
	id_venta INT PRIMARY KEY IDENTITY(1,1),
	fecha DATE NOT NULL,
	subtotal DECIMAL(7,2) NOT NULL,
	descuento DECIMAL(7,2) NOT NULL,
	total DECIMAL(7,2) NOT NULL,
	observaciones VARCHAR(300) NOT NULL,
	id_cliente INT NOT NULL,
	id_empleado INT NOT NULL,
	id_mesa INT NOT NULL,
	
	CONSTRAINT FK_Ventas_Clientes
		FOREIGN KEY (id_cliente)
		REFERENCES Clientes(id_cliente),
		
	CONSTRAINT FK_Ventas_Empleado
		FOREIGN KEY (id_empleado)
		REFERENCES Empleados(id_empleado),
		
	CONSTRAINT FK_Ventas_Mesa
		FOREIGN KEY (id_mesa)
		REFERENCES Mesas(id_mesa)
); 

CREATE TABLE Compras
(
	id_compra INT PRIMARY KEY IDENTITY(1,1),
	id_proveedor INT NOT NULL,
	id_empleado INT NOT NULL,
	id_metodo_pago INT NOT NULL,
	total DECIMAL(7,2) NOT NULL,
	observaciones VARCHAR(300) NOT NULL,

	CONSTRAINT FK_Compras_Proveedor
		FOREIGN KEY (id_proveedor)
		REFERENCES Proveedores(id_proveedor),
	
	CONSTRAINT FK_Compras_Empleado
		FOREIGN KEY (id_empleado)
		REFERENCES Empleados(id_empleado),
		
	CONSTRAINT FK_Compras_Metodos_Pago
		FOREIGN KEY (id_metodo_pago)
		REFERENCES Metodos_Pago(id_metodo_pago)
);

CREATE TABLE Detalle_Ventas
(
	id_detalle INT PRIMARY KEY IDENTITY(1,1),
	cantidad INT NOT NULL,
	precio_unitario DECIMAL(7,2),
	subtotal DECIMAL(7,2),
	id_venta INT NOT NULL,
	id_producto INT NOT NULL,
	
	CONSTRAINT FK_Detalle_Ventas_Venta
		FOREIGN KEY (id_venta)
		REFERENCES Ventas(id_venta),
		
	CONSTRAINT FK_Detalle_Venta_Producto
		FOREIGN KEY (id_producto)
		REFERENCES Productos(id_producto)
); 

CREATE TABLE Detalle_Compras
(
	id_detalle INT PRIMARY KEY IDENTITY(1,1),
	cantidad INT NOT NULL,
	costo_unitario DECIMAL(7,2),
	subtotal DECIMAL(7,2),
	id_compra INT NOT NULL,
	id_producto INT NOT NULL,
	
	CONSTRAINT FK_Detalle_Compras_Compra
		FOREIGN KEY (id_compra)
		REFERENCES Compras(id_compra),
	
	CONSTRAINT FK_Detalle_Compras_Producto
		FOREIGN KEY (id_producto)
		REFERENCES Productos(id_producto)
);

CREATE TABLE Ingredientes_Producto
(
	cantidad_utilizada INT NOT NULL,
	id_producto INT NOT NULL,
	id_ingrediente INT NOT NULL,
	
	CONSTRAINT PK_Ingredientes_Producto
		PRIMARY KEY (id_producto, id_ingrediente),
		
	CONSTRAINT FK_Ingredientes_Producto_AUXPro
		FOREIGN KEY (id_producto)
		REFERENCES Productos(id_producto),
		
	CONSTRAINT FK_Ingredientes_Producto_AUXIng
		FOREIGN KEY (id_ingrediente)
		REFERENCES Ingredientes(id_ingrediente),
);

CREATE TABLE Metodo_Pago_Venta
(
	id_venta INT NOT NULL,
	id_metodo_pago INT NOT NULL,
	importe DECIMAL(7,2) NOT NULL,
	
	CONSTRAINT PK_Metodo_Pago_Venta
		PRIMARY KEY (id_venta, id_metodo_pago),
		
	CONSTRAINT FK_Metodo_Pago_Venta_AUXVen
		FOREIGN KEY (id_venta)
		REFERENCES Ventas(id_venta),
		
	CONSTRAINT FK_Metodo_Pago_Venta_AUXMet
		FOREIGN KEY (id_metodo_pago)
		REFERENCES Metodos_Pago(id_metodo_pago),
);

CREATE TABLE Auditoria_Precios_Compra (
     id_auditoria INT PRIMARY KEY IDENTITY(1,1),
     id_detalle INT NOT NULL,
     precio_anterior DECIMAL(7,2),
     precio_nuevo DECIMAL(7,2),
     fecha_cambio DATETIME NOT NULL
);