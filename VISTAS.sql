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
