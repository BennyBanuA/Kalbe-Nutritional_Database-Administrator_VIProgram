-- Database: kalbe

-- DROP DATABASE IF EXISTS kalbe;

CREATE DATABASE kalbe
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_Indonesia.1252'
    LC_CTYPE = 'English_Indonesia.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
	
CREATE SCHEMA app;

CREATE TABLE app.Product(
	"Product_Id" serial PRIMARY KEY,
	"Nama_Produk" varchar(255) NOT NULL
);

COPY app.Product ("Nama_Produk")
FROM '/Users/BENI/Documents/project/RakaminxKalbe/product.csv' DELIMITER ';' CSV HEADER;

SELECT*FROM app.product

-------------------------
CREATE TABLE app.Shipments (
    "Shipment_ID" serial PRIMARY KEY,
	"Store_Destination" varchar(255) NOT NULL,
    "Store_Address" varchar(255),
	"Operator" varchar(255) NOT NULL,
	"Shipping_Vehicle" varchar(255),
    "No_Polisi" varchar(20),
    "Shipping_Driver" varchar(255),
    "Shipping_CoDriver" varchar(255),
    "Sending_Time" timestamp NOT NULL,
    "DeliveredTime" timestamp,
    "ReceivedBy" varchar(255)
);

COPY app.Shipments ( "Store_Destination",
					"Store_Address", "Operator", "Shipping_Vehicle",
				    "No_Polisi", "Shipping_Driver", "Shipping_CoDriver",
				    "Sending_Time", "DeliveredTime", "ReceivedBy")
FROM '/Users/BENI/Documents/project/RakaminxKalbe/shipments.csv' DELIMITER ';' CSV HEADER;

SELECT*FROM app.Shipments

CREATE INDEX idx_SendingTime ON app.Shipments ("Sending_Time");

-------------------------------------------------------------
CREATE TABLE app.ShipmentDetails (
    "ShipmentDetailID" serial PRIMARY KEY,
    "Shipment_ID" integer REFERENCES app.Shipments ("Shipment_ID"),
    "Product_Id" integer REFERENCES app.Product ("Product_Id"),
	"Nama_Produk" varchar(255),
    "Qty" integer,
    "Unit" varchar(10),
    FOREIGN KEY ("Shipment_ID") REFERENCES app.Shipments ("Shipment_ID"),
    FOREIGN KEY ("Product_Id") REFERENCES app.Product ("Product_Id")
);

CREATE INDEX idx_ShipmentID ON app.ShipmentDetails ("Shipment_ID");

COPY app.ShipmentDetails ("Shipment_ID","Product_Id", "Nama_Produk","Qty", "Unit") 
FROM '/Users/BENI/Documents/project/RakaminxKalbe/shipments_detail.csv' DELIMITER ';' CSV HEADER;

SELECT*FROM app.ShipmentDetails

--challenge--
-- meanmpilkan 2 driver dengan pengiriman terbanyak ---
SELECT "Shipping_Driver", COUNT(*) AS "Jumlah_Pengiriman"
FROM app.Shipments
WHERE
    EXTRACT(MONTH FROM "Sending_Time") = 5
    AND EXTRACT(YEAR FROM "Sending_Time") = 2023
GROUP BY
    "Shipping_Driver"
ORDER BY
    "Jumlah_Pengiriman" DESC
LIMIT 2;

--- 2 ---
SELECT
    app.Product."Nama_Produk",
    SUM("Qty") AS "Total_Pengiriman"
FROM
    app.ShipmentDetails 
JOIN
    app.Shipments ON app.ShipmentDetails."Shipment_ID" = app.Shipments."Shipment_ID"
JOIN
    app.Product ON app.ShipmentDetails."Product_Id" = app.Product."Product_Id"
WHERE
    EXTRACT(MONTH FROM app.Shipments."Sending_Time") = 5
    AND EXTRACT(YEAR FROM app.Shipments."Sending_Time") = 2023
GROUP BY
    app.Product."Nama_Produk"
ORDER BY
    "Total_Pengiriman" DESC
LIMIT 10;

---- 3 ----
SELECT * FROM app.Shipments
WHERE "DeliveredTime" IS NULL;


--- membuat user backend
CREATE USER backend_user WITH PASSWORD 'password';
GRANT CONNECT ON DATABASE kalbe TO backend_user;
GRANT USAGE ON SCHEMA app TO backend_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO backend_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_user;


CREATE OR REPLACE FUNCTION generate_shipment_id()
RETURNS integer AS $$
DECLARE
    today date;
    max_id integer;
BEGIN
    today := CURRENT_DATE;
    
    -- Mengambil nilai maksimum ID Shipment pada tanggal yang sama
    SELECT MAX("Shipment_ID") INTO max_id FROM app.Shipments WHERE DATE("Sending_Time") = today;
    max_id := max_id + 1;
    
    RETURN max_id;
END;
$$ LANGUAGE plpgsql;

-- store procedure --

-- create_shipment --
CREATE OR REPLACE PROCEDURE create_shipment(
    store_destination varchar,
    store_address varchar,
    operator_name varchar,
    shipping_vehicle varchar,
    no_polisi varchar,
    shipping_driver varchar,
    shipping_co_driver varchar,
    sending_time timestamp,
    received_by varchar
)
LANGUAGE plpgsql AS $$
DECLARE
    shipment_id integer;
BEGIN
     -- memanggil fungsi generate_shipment_id() untuk mendapatkan ID Shipment
    SELECT generate_shipment_id() INTO shipment_id;
    
    -- menyimpan data pengiriman ke tabel app.Shipments
    INSERT INTO app.Shipments (
        "Shipment_ID",
        "Store_Destination",
        "Store_Address",
        "Operator",
        "Shipping_Vehicle",
        "No_Polisi",
        "Shipping_Driver",
        "Shipping_CoDriver",
        "Sending_Time",
        "ReceivedBy"
    )
    VALUES (
        shipment_id,
        store_destination,
        store_address,
        operator_name,
        shipping_vehicle,
        no_polisi,
        shipping_driver,
        shipping_co_driver,
        sending_time,
        received_by
    );
END;
$$;

-- store procedur add produk to shipment --
CREATE OR REPLACE PROCEDURE add_product_to_shipment(
    shipment_id integer,
    product_id integer,
    qty integer,
    unit varchar
)
LANGUAGE plpgsql AS $$
BEGIN
    -- menyimpan data detail pengiriman ke dalam tabel app.ShipmentDetails
    INSERT INTO app.ShipmentDetails (
        "Shipment_ID",
        "Product_Id",
        "Qty",
        "Unit"
    )
    VALUES (
        shipment_id,
        product_id,
        qty,
        unit
    );
END;
$$;

-- get all data -- 
CREATE OR REPLACE FUNCTION GetAllData()
RETURNS TABLE (
    "Product_Id" integer,
    "Nama_Produk" varchar(255),
    "Shipment_ID" integer,
    "Store_Destination" varchar(255),
    "Store_Address" varchar(255),
    "Operator" varchar(255),
    "Shipping_Vehicle" varchar(255),
    "No_Polisi" varchar(20),
    "Shipping_Driver" varchar(255),
    "Shipping_CoDriver" varchar(255),
    "Sending_Time" timestamp,
    "DeliveredTime" timestamp,
    "ReceivedBy" varchar(255),
    "ShipmentDetailID" integer,
    "Qty" integer,
    "Unit" varchar(10)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p."Product_Id",
        p."Nama_Produk",
        s."Shipment_ID",
        s."Store_Destination",
        s."Store_Address",
        s."Operator",
        s."Shipping_Vehicle",
        s."No_Polisi",
        s."Shipping_Driver",
        s."Shipping_CoDriver",
        s."Sending_Time",
        s."DeliveredTime",
        s."ReceivedBy",
        sd."ShipmentDetailID",
        sd."Qty",
        sd."Unit"
    FROM
        app.ShipmentDetails as sd
    JOIN
        app.Shipments as s ON sd."Shipment_ID" = s."Shipment_ID"
    JOIN
        app.Product as p ON sd."Product_Id" = p."Product_Id";
END;
$$ LANGUAGE plpgsql;


SELECT * FROM GetAllData();

COPY (SELECT * FROM GetAllData()) TO 'C:\\Users\\BENI\\Documents\\project\\RakaminxKalbe\\backup_file.csv' WITH CSV HEADER;


DROP FUNCTION IF EXISTS GetAllData();


