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
