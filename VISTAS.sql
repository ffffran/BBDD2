USE BBDD2_UTN;
GO

CREATE VIEW vista_ventas_diarias AS
SELECT
    v.fecha,
    mp.nombre_metodo AS metodo_pago,
    cp.nombre_categoria AS categoria,
    COUNT(v.id_venta) AS cantidad_ventas,
    SUM(v.total) AS total_recaudado
FROM Ventas v
INNER JOIN Metodo_Pago_Venta mpv ON mpv.id_venta = v.id_venta
INNER JOIN Metodos_Pago mp ON mp.id_metodo_pago = mpv.id_metodo_pago
INNER JOIN Detalle_Ventas dv ON dv.id_venta = v.id_venta
INNER JOIN Productos p ON p.id_producto = dv.id_producto
INNER JOIN Categorias_Productos cp ON cp.id_categoria = p.id_categoria
GROUP BY v.fecha, mp.nombre_metodo, cp.nombre_categoria;
GO

CREATE VIEW vista_stock_critico AS
SELECT
    'Producto' AS tipo,
    nombre_producto AS nombre,
    stock_actual AS stock_disponible,
    stock_minimo
FROM Productos
WHERE stock_actual < stock_minimo AND estado = 1
UNION ALL
SELECT
    'Ingrediente' AS tipo,
    nombre AS nombre,
    stock_disponible,
    NULL AS stock_minimo
FROM Ingredientes
WHERE stock_disponible <= 0;
GO

CREATE VIEW vista_rentabilidad_productos AS
SELECT
    p.nombre_producto,
    cp.nombre_categoria AS categoria,
    p.precio_compra,
    p.precio_venta,
    (p.precio_venta - p.precio_compra) AS ganancia_unitaria
FROM Productos p
INNER JOIN Categorias_Productos cp ON cp.id_categoria = p.id_categoria
WHERE p.estado = 1;
GO

CREATE VIEW vista_ventas_por_mesa AS
SELECT
    m.id_mesa,
    m.numero_mesa,
    COUNT(v.id_venta) AS cantidad_ventas,
    SUM(v.total) AS total_recaudado
FROM Mesas m
LEFT JOIN Ventas v ON v.id_mesa = m.id_mesa
GROUP BY m.id_mesa, m.numero_mesa;
GO

CREATE VIEW vista_ingredientes_con_receta AS
SELECT
    p.id_producto,
    p.nombre_producto,
    i.id_ingrediente,
    i.nombre AS nombre_ingrediente,
    ip.cantidad_utilizada
FROM Ingredientes_Producto ip
INNER JOIN Productos p ON p.id_producto = ip.id_producto
INNER JOIN Ingredientes i ON i.id_ingrediente = ip.id_ingrediente;
GO