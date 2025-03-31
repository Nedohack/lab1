CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE dw.dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL,
    day_name VARCHAR(10),
    is_weekend BOOLEAN
);


CREATE TABLE dw.dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    company VARCHAR(100),
    address VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE dw.fact_sales (
    sales_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    customer_id INT REFERENCES dw.dim_customer(customer_id),
    date_id INT REFERENCES dw.dim_date(date_id),
    total_amount DECIMAL(10, 2) NOT NULL,
    total_tracks INT NOT NULL
);

CREATE TABLE dw.dim_artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE dw.dim_album (
    album_id INT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    artist_id INT REFERENCES dw.dim_artist(artist_id)
);

CREATE TABLE dw.dim_track (
    track_id INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    album_id INT REFERENCES dw.dim_album(album_id),
    genre_id INT,
    media_type_id INT,
    composer VARCHAR(200),
    milliseconds INT,
    unit_price DECIMAL(10, 2)
);


CREATE TABLE dw.dim_genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);


CREATE TABLE dw.dim_media_type (
    media_type_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);


CREATE TABLE dw.fact_sales_extended (
    sales_extended_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    invoice_line_id INT NOT NULL,
    customer_id INT REFERENCES dw.dim_customer(customer_id),
    date_id INT REFERENCES dw.dim_date(date_id),
    track_id INT REFERENCES dw.dim_track(track_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(10, 2) NOT NULL
);
