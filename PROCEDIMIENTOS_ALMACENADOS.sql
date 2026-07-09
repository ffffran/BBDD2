USE BBDD2_UTN;
GO

CREATE PROCEDURE sp_registrar_venta
    @id_cliente INT,
    @id_empleado INT,
    @id_mesa INT,
    @id_metodo_pago INT,
    @observaciones VARCHAR(300)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @id_venta INT;
        DECLARE @total DECIMAL(7,2) = 0;

        INSERT INTO Ventas (fecha, id_cliente, id_empleado, id_mesa,
                            subtotal, descuento, total, observaciones)
        VALUES (GETDATE(), @id_cliente, @id_empleado, @id_mesa,
                0, 0, 0, @observaciones);

        SET @id_venta = SCOPE_IDENTITY();

        INSERT INTO Metodo_Pago_Venta (id_venta, id_metodo_pago, importe)
        VALUES (@id_venta, @id_metodo_pago, 0);

        COMMIT TRANSACTION;
        PRINT 'Venta registrada correctamente. ID: ' + CAST(@id_venta AS VARCHAR);
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al registrar venta: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE PROCEDURE sp_agregar_detalle_venta
    @id_venta INT,
    @id_producto INT,
    @cantidad INT
AS
BEGIN
    BEGIN TRY
        DECLARE @precio DECIMAL(7,2);

        SELECT @precio = precio_venta
        FROM Productos
        WHERE id_producto = @id_producto;

        INSERT INTO Detalle_Ventas
            (cantidad, precio_unitario, subtotal, id_venta, id_producto)
        VALUES
            (@cantidad,
             @precio,
             @cantidad * @precio,
             @id_venta,
             @id_producto);

        PRINT 'Detalle agregado correctamente.';
    END TRY

    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE PROCEDURE sp_finalizar_venta
    @id_venta INT
AS
BEGIN
    BEGIN TRY
        DECLARE @subtotal DECIMAL(7,2);

        SELECT @subtotal = SUM(subtotal)
        FROM Detalle_Ventas
        WHERE id_venta = @id_venta;

        IF @subtotal IS NULL
            SET @subtotal = 0;

        IF @subtotal = 0
        BEGIN
            DELETE FROM Metodo_Pago_Venta
            WHERE id_venta = @id_venta;
        
            DELETE FROM Ventas
            WHERE id_venta = @id_venta;
        
            THROW 50001, 'La venta no contiene productos. Se canceló la operación.', 1;
        END;

        UPDATE Ventas
        SET
            subtotal = @subtotal,
            descuento = 0,
            total = @subtotal
        WHERE id_venta = @id_venta;

        UPDATE Metodo_Pago_Venta
        SET importe = @subtotal
        WHERE id_venta = @id_venta;

        PRINT 'Venta finalizada correctamente.';
    END TRY

    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE PROCEDURE sp_registrar_compra
    @id_proveedor INT,
    @id_empleado INT,
    @id_metodo_pago INT,
    @total DECIMAL(7,2),
    @observaciones VARCHAR(300)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Compras (id_proveedor, id_empleado, id_metodo_pago,
                             total, observaciones)
        VALUES (@id_proveedor, @id_empleado, @id_metodo_pago,
                @total, @observaciones);

        COMMIT TRANSACTION;
        PRINT 'Compra registrada correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al registrar compra: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

GO
CREATE PROCEDURE sp_agregar_detalle_compra
    @id_compra INT,
    @id_producto INT,
    @cantidad INT
AS
BEGIN
    BEGIN TRY

        DECLARE @precio DECIMAL(7,2);

        SELECT @precio = precio_compra
        FROM Productos
        WHERE id_producto = @id_producto;

        INSERT INTO Detalle_Compras
        (
            cantidad,
            costo_unitario,
            subtotal,
            id_compra,
            id_producto
        )
        VALUES
        (
            @cantidad,
            @precio,
            @cantidad * @precio,
            @id_compra,
            @id_producto
        );

        PRINT 'Detalle agregado correctamente.';

    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

GO
CREATE PROCEDURE sp_finalizar_compra
    @id_compra INT
AS
BEGIN
    BEGIN TRY

        DECLARE @total DECIMAL(7,2);

        SELECT @total = SUM(subtotal)
        FROM Detalle_Compras
        WHERE id_compra = @id_compra;

        IF @total IS NULL
            SET @total = 0;

        UPDATE Compras
        SET total = @total
        WHERE id_compra = @id_compra;

        PRINT 'Compra finalizada correctamente.';

    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE PROCEDURE sp_agregar_ingrediente
    @nombre VARCHAR(60),
    @stock_disponible DECIMAL(6,3),
    @costo_unitario DECIMAL(7,2),
    @id_unidad_medida INT
AS
BEGIN
   
    IF @stock_disponible <= 0
    BEGIN
        RAISERROR('El stock disponible debe ser mayor a 0.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Unidades_Medida WHERE id_unidad_medida = @id_unidad_medida)
    BEGIN
        RAISERROR('El id de unidad de medida no existe.', 16, 1);
        RETURN;
    END

    INSERT INTO Ingredientes (nombre, stock_disponible, costo_unitario, id_unidad_medida)
    VALUES (@nombre, @stock_disponible, @costo_unitario, @id_unidad_medida);
END;

GO


CREATE PROCEDURE sp_cocinar_producto
    @id_producto INT,
    @cantidad INT
AS
BEGIN
  

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @cantidad <= 0
        BEGIN
            THROW 50001, 'La cantidad a cocinar debe ser mayor a cero.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM Ingredientes_Producto ip
            INNER JOIN Ingredientes i
                ON i.id_ingrediente = ip.id_ingrediente
            WHERE ip.id_producto = @id_producto
              AND i.stock_disponible < (ip.cantidad_utilizada * @cantidad)
        )
        BEGIN
            PRINT 'No es posible cocinar el producto.';
            PRINT 'Es necesario reponer uno o más ingredientes.';

            ROLLBACK TRANSACTION;
            RETURN;
        END;

        UPDATE i
        SET stock_disponible =
            stock_disponible - (ip.cantidad_utilizada * @cantidad)
        FROM Ingredientes i
        INNER JOIN Ingredientes_Producto ip
            ON ip.id_ingrediente = i.id_ingrediente
        WHERE ip.id_producto = @id_producto;

        UPDATE Productos
        SET stock_actual = stock_actual + @cantidad
        WHERE id_producto = @id_producto;

        COMMIT TRANSACTION;

        PRINT 'Producto elaborado correctamente.';
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE PROCEDURE sp_actualizar_stock_producto
    @id_producto INT,
    @cantidad INT,
    @usuario VARCHAR(60) = NULL
AS
BEGIN
    
    BEGIN TRY

        BEGIN TRANSACTION;
        DECLARE @stock_anterior INT;
        
        SELECT @stock_anterior = stock_actual FROM Productos WHERE id_producto = @id_producto;

        IF @stock_anterior IS NULL
        BEGIN
            THROW 50001, 'Producto no encontrado.', 1;
        END


        UPDATE Productos SET stock_actual = stock_actual + @cantidad WHERE id_producto = @id_producto;
        INSERT INTO Auditoria_Stock_Productos (id_producto, stock_anterior, stock_nuevo, fecha_cambio, usuario)
        VALUES (@id_producto, @stock_anterior, @stock_anterior + @cantidad, GETDATE(), @usuario);

        COMMIT TRANSACTION;
        PRINT 'Stock actualizado correctamente.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

CREATE PROCEDURE sp_consultar_ventas_empleado
    @id_empleado INT,
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
   
    SELECT
        v.id_venta,
        v.fecha,
        v.total,
        c.nombre + ' ' + c.apellido AS cliente,
        m.numero_mesa
    FROM Ventas v
    INNER JOIN Clientes c ON c.id_cliente = v.id_cliente
    INNER JOIN Mesas m ON m.id_mesa = v.id_mesa
    WHERE v.id_empleado = @id_empleado
      AND v.fecha BETWEEN @fecha_inicio AND @fecha_fin
    ORDER BY v.fecha DESC;
END;
GO

CREATE PROCEDURE sp_productos_mas_vendidos
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL
AS
BEGIN
  
    IF @fecha_inicio IS NULL SET @fecha_inicio = '1900-01-01';
    IF @fecha_fin IS NULL SET @fecha_fin = GETDATE();
    SELECT TOP 10
        p.nombre_producto,
        SUM(dv.cantidad) AS total_vendido,
        SUM(dv.subtotal) AS total_recaudado
    FROM Detalle_Ventas dv
    INNER JOIN Productos p ON p.id_producto = dv.id_producto
    INNER JOIN Ventas v ON v.id_venta = dv.id_venta
    WHERE v.fecha BETWEEN @fecha_inicio AND @fecha_fin
    GROUP BY p.nombre_producto
    ORDER BY total_vendido DESC;
END;
GO