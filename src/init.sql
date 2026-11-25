CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS rfid;
CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS audit;

--DOMAINs
DO $$ BEGIN
    CREATE DOMAIN core.country_code AS char(2) CHECK (VALUE ~ '^[A-Z]{2}$');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN core.latitude AS numeric(9,6) CHECK (VALUE BETWEEN -90 AND 90);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN core.longitude AS numeric(9,6) CHECK (VALUE BETWEEN -180 AND 180);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN core.email AS text CHECK (VALUE ~* '^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN core.phone AS text CHECK (VALUE ~ '^[+]?[0-9 ()-]{7,20}$');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN core.postal_code AS text CHECK (VALUE ~ '^[0-9A-Za-z -]{3,12}$');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN core.plate AS text CHECK (VALUE ~ '^[A-Z0-9]{5,8}$');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN rfid.epc_hex AS text CHECK (VALUE ~ '^[0-9A-F]{8,64}$');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN rfid.tid_hex AS text CHECK (VALUE ~ '^[0-9A-F]{16,48}$');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN rfid.rssi_dbm AS numeric(5,1) CHECK (VALUE BETWEEN -120 AND 0);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE DOMAIN rfid.power_dbm AS numeric(4,1) CHECK (VALUE BETWEEN 0 AND 36);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

--ENUMs
DO $$ BEGIN
    CREATE TYPE core.location_type AS ENUM ('HEADQUARTERS', 'BRANCH', 'WAREHOUSE', 'DISTRIBUTION_CENTER', 'GARAGE', 'YARD', 'WORKSHOP', 'CUSTOMER_SITE', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.zone_type AS ENUM ('DOCK', 'STORAGE', 'PARKING', 'GATE', 'WORKSHOP', 'OFFICE','LABORATORY', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.vehicle_category AS ENUM ('CAR', 'MOTORCYCLE', 'VAN', 'PICKUP', 'TRUCK', 'HEAVY_TRUCK', 'BUS', 'TRAILER', 'AMBULANCE', 'SPECIAL', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.vehicle_status AS ENUM ('ACTIVE', 'INACTIVE', 'IN_MAINTENANCE', 'RESERVED', 'SOLD', 'SCRAPPED', 'STOLEN');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.fuel_type AS ENUM ('GASOLINE', 'ETHANOL', 'FLEX', 'DIESEL', 'CNG', 'ELECTRIC', 'HYBRID', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.ownership_type AS ENUM ('OWNED', 'LEASED', 'RENTED', 'THIRD_PARTY');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.compartment_type AS ENUM ('CABIN', 'TRUNK', 'CARGO_BOX', 'TOOLBOX', 'ROOF_RACK', 'SIDE_BAY', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.equipment_status AS ENUM ('IN_STOCK', 'ASSIGNED', 'IN_TRANSIT', 'IN_MAINTENANCE', 'LOANED', 'QUARANTINE', 'LOST', 'DISCARDED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.equipment_condition AS ENUM ('NEW', 'GOOD', 'FAIR', 'POOR', 'DAMAGED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.person_type AS ENUM ('EMPLOYEE', 'DRIVER', 'TECHNICIAN', 'CONTRACTOR', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE core.user_role AS ENUM ('ADMIN', 'MANAGER', 'OPERATOR', 'AUDITOR', 'VIEWER', 'SERVICE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.tag_type AS ENUM ('UHF_EPC_GEN2', 'UHF_EPC_GEN2V2', 'HF_ISO15693', 'HF_NFC', 'LF_125KHZ', 'ACTIVE_BLE', 'ACTIVE_2_4GHZ');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.tag_form_factor AS ENUM ('ADHESIVE_LABEL', 'HARD_TAG', 'ON_METAL', 'WINDSHIELD', 'CABLE_TIE', 'EMBEDDED', 'KEY_FOB', 'CARD');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.tag_status AS ENUM ('NEW', 'ENCODED', 'ACTIVE', 'DAMAGED', 'LOST', 'RETIRED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.binding_entity AS ENUM ('EQUIPMENT', 'VEHICLE', 'PERSON', 'LOCATION');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.reader_type AS ENUM ('FIXED_PORTAL', 'FIXED_SINGLE_ANTENNA', 'HANDHELD', 'VEHICLE_MOUNTED', 'DESKTOP_ENCODER', 'GATEWAY_BLE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.reader_status AS ENUM ('ONLINE', 'OFFLINE', 'DEGRADED', 'MAINTENANCE', 'DECOMMISSIONED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.reader_protocol AS ENUM ('LLRP', 'MQTT', 'HTTP_REST', 'WEBSOCKET', 'SERIAL', 'TCP_RAW', 'VENDOR_SDK');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.rf_region AS ENUM ('ANATEL_BR', 'FCC_US', 'ETSI_EU', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.antenna_polarization AS ENUM ('LINEAR', 'CIRCULAR_RIGHT', 'CIRCULAR_LEFT');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.read_direction AS ENUM ('IN', 'OUT', 'UNKNOWN');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.read_source AS ENUM ('FIXED_READER', 'HANDHELD', 'MOBILE_APP', 'IMPORT', 'SIMULATOR');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.session_type AS ENUM ('VEHICLE_CHECK_OUT', 'VEHICLE_CHECK_IN', 'VEHICLE_AUDIT', 'LOCATION_INVENTORY', 'SPOT_CHECK', 'PORTAL_PASS');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.session_status AS ENUM ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'COMPLETED_WITH_DIVERGENCE', 'CANCELLED', 'EXPIRED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.result_status AS ENUM ('OK', 'MISSING', 'EXTRA', 'UNKNOWN_TAG', 'WRONG_VEHICLE', 'INACTIVE_TAG', 'DAMAGED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE rfid.resolution_status AS ENUM ('PENDING', 'ACKNOWLEDGED', 'RESOLVED', 'IGNORED', 'ESCALATED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE ops.movement_type AS ENUM ('LOAD', 'UNLOAD', 'CHECK_IN', 'CHECK_OUT', 'TRANSFER_VEHICLE', 'TRANSFER_LOCATION', 'LOSS', 'FOUND', 'MAINTENANCE_OUT', 'MAINTENANCE_IN', 'DISPOSAL', 'ADJUSTMENT');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE ops.detection_method AS ENUM ('RFID_PORTAL', 'RFID_HANDHELD', 'MANUAL', 'BARCODE', 'SYSTEM');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE ops.assignment_type AS ENUM ('BASE', 'TEMPORARY', 'TRANSFER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE ops.alert_type AS ENUM ('EQUIPMENT_MISSING', 'UNAUTHORIZED_EXIT', 'UNKNOWN_TAG_DETECTED', 'WRONG_VEHICLE', 'KIT_INCOMPLETE', 'READER_OFFLINE', 'LOW_READ_RATE', 'TAG_DUPLICATED', 'CALIBRATION_DUE', 'MAINTENANCE_DUE', 'WARRANTY_EXPIRING', 'GEOFENCE_VIOLATION');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE ops.alert_severity AS ENUM ('INFO', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE ops.alert_status AS ENUM ('OPEN', 'ACKNOWLEDGED', 'IN_PROGRESS', 'RESOLVED', 'DISMISSED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE ops.maintenance_type AS ENUM ('PREVENTIVE', 'CORRECTIVE', 'CALIBRATION', 'INSPECTION', 'UPGRADE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE ops.maintenance_status AS ENUM ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'OVERDUE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    CREATE TYPE audit.action_type AS ENUM ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

--CORE TABLES
CREATE TABLE IF NOT EXISTS core.organization (
    organization_id bigint GENERATED ALWAYS AS IDENTITY,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL,
    legal_name text NOT NULL,
    trade_name text,
    tax_id text,
    country core.country_code DEFAULT 'BR' NOT NULL,
    timezone text DEFAULT 'America/Sao_Paulo' NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamptz,
    CONSTRAINT pk_organization PRIMARY KEY (organization_id)
);

CREATE TABLE IF NOT EXISTS core.supplier (
    supplier_id bigint GENERATED ALWAYS AS IDENTITY,
    organization_id bigint NOT NULL,
    name text NOT NULL,
    tax_id text,
    contact_name text,
    email core.email,
    phone core.phone,
    website text,
    is_active boolean DEFAULT true NOT NULL,
    notes text,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamptz,
    CONSTRAINT pk_supplier PRIMARY KEY (supplier_id)
);

CREATE TABLE IF NOT EXISTS core.location (
    location_id bigint GENERATED ALWAYS AS IDENTITY,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id bigint NOT NULL,
    parent_location_id bigint,
    code text NOT NULL,
    name text NOT NULL,
    type core.location_type DEFAULT 'BRANCH' NOT NULL,
    address_line text NOT NULL,
    number text,
    complement text,
    district text,
    postal_code core.postal_code,
    city text NOT NULL,
    state_province text,
    country core.country_code DEFAULT 'BR' NOT NULL,
    latitude core.latitude,
    longitude core.longitude,
    geofence_radius_m integer,
    timezone text DEFAULT 'America/Sao_Paulo' NOT NULL,
    phone core.phone,
    email core.email,
    manager_person_id bigint,
    cost_center text,
    operating_hours jsonb,
    opened_on date,
    closed_on date,
    is_active boolean DEFAULT true NOT NULL,
    notes text,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamptz,
    CONSTRAINT pk_location PRIMARY KEY (location_id)
);

CREATE TABLE IF NOT EXISTS core.location_zone (
    location_zone_id bigint GENERATED ALWAYS AS IDENTITY,
    location_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    zone_type core.zone_type DEFAULT 'OTHER' NOT NULL,
    has_rfid_coverage boolean DEFAULT false NOT NULL,
    capacity_vehicles integer,
    is_active boolean DEFAULT true NOT NULL,
    notes text,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamptz,
    CONSTRAINT pk_location_zone PRIMARY KEY (location_zone_id)
);

CREATE TABLE IF NOT EXISTS core.vehicle (
    vehicle_id bigint GENERATED ALWAYS AS IDENTITY,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id bigint NOT NULL,
    fleet_code text NOT NULL,
    plate core.plate NOT NULL,
    renavam text,
    chassis_vin text,
    brand text NOT NULL,
    model text NOT NULL,
    year_manufacture smallint,
    year_model smallint,
    color text,
    category core.vehicle_category DEFAULT 'VAN' NOT NULL,
    ownership_type core.ownership_type DEFAULT 'OWNED' NOT NULL,
    status core.vehicle_status DEFAULT 'ACTIVE' NOT NULL,
    base_location_id bigint NOT NULL,
    current_location_id bigint,
    current_zone_id bigint,
    default_kit_id bigint,
    default_driver_id bigint,
    capacity_kg numeric(10,2),
    capacity_m3 numeric(8,2),
    seats smallint,
    odometer_km numeric(10,1),
    odometer_updated_at timestamptz,
    last_latitude core.latitude,
    last_longitude core.longitude,
    last_position_at timestamptz,
    telematics_device_id text,
    insurance_policy_number text,
    insurance_expires_on date,
    licensing_expires_on date,
    acquired_on date,
    acquisition_cost numeric(14,2),
    currency char(3) DEFAULT 'BRL' NOT NULL,
    sold_on date,
    is_active boolean DEFAULT true NOT NULL,
    notes text,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_at timestamptz,
    CONSTRAINT pk_vehicle PRIMARY KEY (vehicle_id)
);