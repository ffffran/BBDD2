CREATE TRIGGER trg_actualizar_stock_al_vender
ON Detalle_Ventas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.stock_actual = p.stock_actual - i.cantidad
    FROM Productos p
    INNER JOIN inserted i ON p.id_producto = i.id_producto;

    UPDATE ing
    SET ing.stock_disponible = ing.stock_disponible - (i.cantidad * ip.cantidad_utilizada)
    FROM Ingredientes ing
    INNER JOIN Ingredientes_Producto ip ON ip.id_ingrediente = ing.id_ingrediente
    INNER JOIN inserted i ON ip.id_producto = i.id_producto;
END;
GO

CREATE TRIGGER trg_evitar_venta_sin_stock
ON Detalle_Ventas
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Productos p ON p.id_producto = i.id_producto
        WHERE i.cantidad <= 0 OR p.stock_actual < i.cantidad
    )
    BEGIN
        THROW 50001, 'Stock insuficiente para uno o más productos O Cantidad Incorrecta.', 1;
    END

    INSERT INTO Detalle_Ventas (id_venta, id_producto, cantidad,
                                precio_unitario, subtotal)
    SELECT id_venta, id_producto, cantidad,
           precio_unitario, subtotal
    FROM inserted;
END;
GO

CREATE TRIGGER trg_auditar_cambio_precio_compra
ON Detalle_Compras
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(costo_unitario)
    BEGIN
        INSERT INTO Auditoria_Precios_Compra
            (id_detalle, precio_anterior, precio_nuevo, fecha_cambio)
        SELECT
            i.id_detalle,
            d.costo_unitario AS precio_anterior,
            i.costo_unitario AS precio_nuevo,
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON d.id_detalle = i.id_detalle
        WHERE i.costo_unitario <> d.costo_unitario;
    END
END;
