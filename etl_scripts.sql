INSERT INTO dw.dim_date (full_date, day, month, quarter, year, day_name, is_weekend)
SELECT
    d::date AS full_date,
    EXTRACT(DAY FROM d) AS day,
    EXTRACT(MONTH FROM d) AS month,
    EXTRACT(QUARTER FROM d) AS quarter,
    EXTRACT(YEAR FROM d) AS year,
    TO_CHAR(d, 'Day') AS day_name,
    CASE WHEN EXTRACT(DOW FROM d) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM generate_series('2009-01-01'::date, '2012-12-31'::date, '1 day'::interval) d
ON CONFLICT (date_id) DO NOTHING;


INSERT INTO dw.dim_customer
SELECT
    customer_id,
    first_name,
    last_name,
    company,
    address,
    city,
    state,
    country,
    postal_code,
    phone,
    email
FROM public.customer
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO dw.dim_artist
SELECT artist_id, name
FROM public.artist
ON CONFLICT (artist_id) DO NOTHING;

INSERT INTO dw.dim_album
SELECT album_id, title, artist_id
FROM public.album
ON CONFLICT (album_id) DO NOTHING;

INSERT INTO dw.dim_genre
SELECT genre_id, name
FROM public.genre
ON CONFLICT (genre_id) DO NOTHING;


INSERT INTO dw.dim_media_type
SELECT media_type_id, name
FROM public.media_type
ON CONFLICT (media_type_id) DO NOTHING;


INSERT INTO dw.dim_track
SELECT
    track_id,
    name,
    album_id,
    genre_id,
    media_type_id,
    composer,
    milliseconds,
    unit_price
FROM public.track
ON CONFLICT (track_id) DO NOTHING;

INSERT INTO dw.fact_sales (invoice_id, customer_id, date_id, total_amount, total_tracks)
SELECT
    i.invoice_id,
    i.customer_id,
    dd.date_id,
    i.total AS total_amount,
    COUNT(il.track_id) AS total_tracks
FROM public.invoice i
JOIN dw.dim_date dd ON i.invoice_date::date = dd.full_date
JOIN public.invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY i.invoice_id, i.customer_id, dd.date_id
ON CONFLICT (sales_id) DO NOTHING;

INSERT INTO dw.fact_sales_extended (invoice_id, invoice_line_id, customer_id, date_id, track_id, quantity, unit_price, line_total)
SELECT
    i.invoice_id,
    il.invoice_line_id,
    i.customer_id,
    dd.date_id,
    il.track_id,
    il.quantity,
    il.unit_price,
    il.quantity * il.unit_price AS line_total
FROM public.invoice i
JOIN dw.dim_date dd ON i.invoice_date::date = dd.full_date
JOIN public.invoice_line il ON i.invoice_id = il.invoice_id
ON CONFLICT (sales_extended_id) DO NOTHING;