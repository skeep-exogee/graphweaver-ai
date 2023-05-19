--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3
-- Dumped by pg_dump version 14.6 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: timestamp_iso8601(timestamp with time zone, text); Type: FUNCTION; Schema: public; Owner: skeep
--

CREATE FUNCTION public.timestamp_iso8601(ts timestamp with time zone, tz text) RETURNS text
    LANGUAGE plpgsql
    AS $$
		declare
		  res text;
		begin
		  set datestyle = 'ISO';
		  perform set_config('timezone', tz, true);
		  res := ts::timestamptz(3)::text;
		  reset datestyle;
		  reset timezone;
		  return replace(res, ' ', 'T') || ':00';
		end; $$;


ALTER FUNCTION public.timestamp_iso8601(ts timestamp with time zone, tz text) OWNER TO skeep;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: absence; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.absence (
    id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    reason character varying(255),
    driver_id bigint NOT NULL
);


ALTER TABLE public.absence OWNER TO skeep;

--
-- Name: absence_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.absence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.absence_id_seq OWNER TO skeep;

--
-- Name: absence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.absence_id_seq OWNED BY public.absence.id;


--
-- Name: allowed_truck; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.allowed_truck (
    id bigint NOT NULL,
    account_id uuid NOT NULL,
    contact_id uuid,
    truck_id bigint NOT NULL,
    notes character varying(255)
);


ALTER TABLE public.allowed_truck OWNER TO skeep;

--
-- Name: allowed_truck_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.allowed_truck_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.allowed_truck_id_seq OWNER TO skeep;

--
-- Name: allowed_truck_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.allowed_truck_id_seq OWNED BY public.allowed_truck.id;


--
-- Name: associated_product; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.associated_product (
    id bigint NOT NULL,
    job_id bigint,
    quantity numeric(12,4) NOT NULL,
    crm_product_id uuid NOT NULL,
    crm_unit_of_measure_id uuid NOT NULL,
    tip_ticket_id bigint,
    movement text DEFAULT 'NIL'::text NOT NULL,
    notes text,
    overridden_unit_price numeric(12,4),
    matching_tag uuid NOT NULL,
    CONSTRAINT associated_product_movement_check CHECK ((movement = ANY (ARRAY['DELIVER'::text, 'PICKUP'::text, 'NIL'::text]))),
    CONSTRAINT associated_product_must_have_job_or_tip_ticket_check CHECK (((job_id IS NOT NULL) OR (tip_ticket_id IS NOT NULL)))
);


ALTER TABLE public.associated_product OWNER TO skeep;

--
-- Name: associated_product_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.associated_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.associated_product_id_seq OWNER TO skeep;

--
-- Name: associated_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.associated_product_id_seq OWNED BY public.associated_product.id;


--
-- Name: audit_change; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.audit_change (
    id bigint NOT NULL,
    type text NOT NULL,
    entity_id character varying(255) NOT NULL,
    entity_type character varying(255) NOT NULL,
    created_by character varying(255) NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    data jsonb,
    created_by_user_id character varying(255) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT audit_change_type_check CHECK ((type = ANY (ARRAY['create'::text, 'update'::text, 'delete'::text, 'update_early'::text, 'delete_early'::text])))
);


ALTER TABLE public.audit_change OWNER TO skeep;

--
-- Name: audit_change_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.audit_change_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_change_id_seq OWNER TO skeep;

--
-- Name: audit_change_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.audit_change_id_seq OWNED BY public.audit_change.id;


--
-- Name: audit_related_entity_change; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.audit_related_entity_change (
    id bigint NOT NULL,
    change_id bigint NOT NULL,
    related_entity_type character varying(255) NOT NULL,
    related_entity_id character varying(255) NOT NULL
);


ALTER TABLE public.audit_related_entity_change OWNER TO skeep;

--
-- Name: audit_related_entity_change_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.audit_related_entity_change_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_related_entity_change_id_seq OWNER TO skeep;

--
-- Name: audit_related_entity_change_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.audit_related_entity_change_id_seq OWNED BY public.audit_related_entity_change.id;


--
-- Name: auth_okta_group_role; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.auth_okta_group_role (
    id bigint NOT NULL,
    okta_group character varying(255) NOT NULL,
    role text NOT NULL,
    CONSTRAINT auth_okta_group_role_role_check CHECK ((role = ANY (ARRAY['ALLOCATOR_CI'::text, 'ALLOCATOR_BD'::text, 'ALLOCATOR_HAULAGE'::text, 'DRIVER_CI'::text, 'DRIVER_BD'::text, 'DRIVER_TT'::text, 'DRIVER_SUPERVISOR_CI'::text, 'DRIVER_SUPERVISOR_BD'::text, 'CUSTOMER_SERVICE'::text, 'SALES_SUPPORT_CI'::text, 'SALES_SUPPORT_BD'::text, 'RECYCLING_WEIGHBRIDGE_OPERATOR'::text, 'RECYCLING_TEAM_LEAD'::text, 'RECYCLING_SPOTTER'::text, 'FINANCE_ALL'::text, 'MANAGEMENT_CI'::text, 'MANAGEMENT_BD'::text, 'MANAGEMENT_RECYCLING'::text, 'MANAGEMENT_HAULAGE'::text, 'MANAGEMENT_ASSETS'::text, 'READONLY_CI'::text, 'READONLY_BD'::text, 'READONLY_RECYCLING'::text, 'READONLY_TT'::text, 'READONLY_SEQ'::text, 'READONLY_PC'::text, 'ADMIN_IT_SUPPORT'::text, 'ADMIN_IT_SUPERUSER'::text, 'SALES_SUPPORT_BD'::text, 'SALES_SUPPORT_CI'::text, 'RECYCLING_WEIGHBRIDGE_OPERATOR'::text, 'DRIVER'::text, 'ALLOCATOR_NIGHT'::text])))
);


ALTER TABLE public.auth_okta_group_role OWNER TO skeep;

--
-- Name: auth_okta_group_role_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.auth_okta_group_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_okta_group_role_id_seq OWNER TO skeep;

--
-- Name: auth_okta_group_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.auth_okta_group_role_id_seq OWNED BY public.auth_okta_group_role.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.auth_permission (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    description character varying(255)
);


ALTER TABLE public.auth_permission OWNER TO skeep;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO skeep;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: bin_image; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.bin_image (
    id bigint NOT NULL,
    crm_bin_id uuid,
    large_image_key character varying(255),
    small_image_key character varying(255),
    state text,
    CONSTRAINT bin_image_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.bin_image OWNER TO skeep;

--
-- Name: bin_image_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.bin_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bin_image_id_seq OWNER TO skeep;

--
-- Name: bin_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.bin_image_id_seq OWNED BY public.bin_image.id;


--
-- Name: bin_record; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.bin_record (
    id bigint NOT NULL,
    serial_number character varying(255) NOT NULL,
    qr_code character varying(255),
    job_id bigint NOT NULL,
    type text DEFAULT 'PICKUP'::text NOT NULL,
    sequence bigint NOT NULL,
    CONSTRAINT bin_record_type_check CHECK ((type = ANY (ARRAY['PICKUP'::text, 'DELIVER'::text, 'RETURN'::text])))
);


ALTER TABLE public.bin_record OWNER TO skeep;

--
-- Name: bin_serial_number_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.bin_serial_number_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bin_serial_number_id_seq OWNER TO skeep;

--
-- Name: bin_serial_number_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.bin_serial_number_id_seq OWNED BY public.bin_record.id;


--
-- Name: bins_on_site; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.bins_on_site (
    id bigint NOT NULL,
    status text NOT NULL,
    site_id uuid NOT NULL,
    product_id uuid NOT NULL,
    location text,
    delivery_job_id bigint,
    pickup_job_id bigint,
    delivery_on date,
    pickup_on date,
    created_at timestamp(0) with time zone NOT NULL,
    is_customer_owned_bin boolean DEFAULT false NOT NULL,
    crm_bin_location_id uuid,
    account_id uuid,
    last_rental_processed_on date,
    CONSTRAINT bins_on_site_location_check CHECK ((location = ANY (ARRAY['CRANED_ON_PRIVATE'::text, 'DRIVEWAY_PRIVATE_PROPERTY'::text, 'ROAD'::text, 'NATURE_STRIP'::text, 'LANEWAY'::text, 'FOOTPATH'::text, 'BEHIND_BOUNDARY_FENCE'::text, 'OTHER'::text]))),
    CONSTRAINT bins_on_site_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'READY'::text, 'DELETED'::text, 'PICKED_UP'::text])))
);


ALTER TABLE public.bins_on_site OWNER TO skeep;

--
-- Name: bins_on_site_adjustment; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.bins_on_site_adjustment (
    id bigint NOT NULL,
    crm_product_id uuid NOT NULL,
    crm_site_location_id uuid NOT NULL,
    crm_bin_location_id uuid NOT NULL,
    quantity_adjustment bigint NOT NULL,
    notes text
);


ALTER TABLE public.bins_on_site_adjustment OWNER TO skeep;

--
-- Name: bins_on_site_adjustment_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.bins_on_site_adjustment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bins_on_site_adjustment_id_seq OWNER TO skeep;

--
-- Name: bins_on_site_adjustment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.bins_on_site_adjustment_id_seq OWNED BY public.bins_on_site_adjustment.id;


--
-- Name: bins_on_site_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.bins_on_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bins_on_site_id_seq OWNER TO skeep;

--
-- Name: bins_on_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.bins_on_site_id_seq OWNED BY public.bins_on_site.id;


--
-- Name: business_unit; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.business_unit (
    id bigint NOT NULL,
    name text NOT NULL,
    CONSTRAINT business_unit_name_check CHECK ((name = ANY (ARRAY['CI'::text, 'BD'::text, 'WB'::text])))
);


ALTER TABLE public.business_unit OWNER TO skeep;

--
-- Name: business_unit_assigned_tip_sites; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.business_unit_assigned_tip_sites (
    business_unit_id bigint NOT NULL,
    tip_site_id bigint NOT NULL
);


ALTER TABLE public.business_unit_assigned_tip_sites OWNER TO skeep;

--
-- Name: business_unit_assigned_trucks; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.business_unit_assigned_trucks (
    business_unit_id bigint NOT NULL,
    truck_id bigint NOT NULL
);


ALTER TABLE public.business_unit_assigned_trucks OWNER TO skeep;

--
-- Name: business_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.business_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.business_unit_id_seq OWNER TO skeep;

--
-- Name: business_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.business_unit_id_seq OWNED BY public.business_unit.id;


--
-- Name: business_unit_tag; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.business_unit_tag (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.business_unit_tag OWNER TO skeep;

--
-- Name: business_unit_tag_business_units; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.business_unit_tag_business_units (
    business_unit_tag_id bigint NOT NULL,
    business_unit_id bigint NOT NULL
);


ALTER TABLE public.business_unit_tag_business_units OWNER TO skeep;

--
-- Name: business_unit_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.business_unit_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.business_unit_tag_id_seq OWNER TO skeep;

--
-- Name: business_unit_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.business_unit_tag_id_seq OWNED BY public.business_unit_tag.id;


--
-- Name: business_unit_tags; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.business_unit_tags (
    business_unit_id bigint NOT NULL,
    business_unit_tag_id bigint NOT NULL
);


ALTER TABLE public.business_unit_tags OWNER TO skeep;

--
-- Name: compatible_truck_license; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.compatible_truck_license (
    id bigint NOT NULL,
    license_type_id bigint NOT NULL,
    crm_service_type_id uuid
);


ALTER TABLE public.compatible_truck_license OWNER TO skeep;

--
-- Name: compatible_truck_license_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.compatible_truck_license_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.compatible_truck_license_id_seq OWNER TO skeep;

--
-- Name: compatible_truck_license_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.compatible_truck_license_id_seq OWNED BY public.compatible_truck_license.id;


--
-- Name: completed_bin_service; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.completed_bin_service (
    id bigint NOT NULL,
    count integer NOT NULL,
    weight integer,
    bin_issue text NOT NULL,
    job_id bigint NOT NULL,
    comments character varying(255),
    num_of_bales integer,
    description character varying(255),
    sequence bigint,
    matching_tag uuid NOT NULL,
    CONSTRAINT completed_bin_service_issue_check CHECK ((bin_issue = ANY (ARRAY['NO_ISSUE'::text, 'BIN_NOT_OUT'::text, 'CONTAMINATED'::text, 'NO_ACCESS'::text, 'BIN_EMPTY'::text, 'EXTRA_BINS'::text, 'NOT_REPAIRED'::text])))
);


ALTER TABLE public.completed_bin_service OWNER TO skeep;

--
-- Name: completed_bin_service_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.completed_bin_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.completed_bin_service_id_seq OWNER TO skeep;

--
-- Name: completed_bin_service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.completed_bin_service_id_seq OWNED BY public.completed_bin_service.id;


--
-- Name: council_permit; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.council_permit (
    id bigint NOT NULL,
    council_name character varying(50),
    state text,
    site_type text,
    bin_location text,
    permit_required boolean,
    permit_duration_days bigint,
    permit_fee numeric(12,4),
    metered boolean,
    approval_lead_time_days bigint,
    preferred_permit_submission text,
    file_path character varying(50),
    council_website_link character varying(255),
    comments character varying(255),
    last_modified date,
    crm_bin_location_id uuid,
    metered_parking_fee character varying(255),
    non_metered_parking_fee character varying(255),
    council_conditions character varying(255),
    can_place_on_nature_strip boolean DEFAULT false NOT NULL,
    is_metered_or_non_metered_bay_applicable boolean DEFAULT false NOT NULL,
    can_add_three_days_to_permit boolean DEFAULT false NOT NULL,
    CONSTRAINT council_permit_bin_location_check CHECK ((bin_location = ANY (ARRAY['CRANED_ON_PRIVATE'::text, 'DRIVEWAY_PRIVATE_PROPERTY'::text, 'ROAD'::text, 'NATURE_STRIP'::text, 'LANEWAY'::text, 'FOOTPATH'::text, 'BEHIND_BOUNDARY_FENCE'::text, 'OTHER'::text]))),
    CONSTRAINT council_permit_preferred_permit_submission_check CHECK ((preferred_permit_submission = ANY (ARRAY['email'::text, 'website'::text]))),
    CONSTRAINT council_permit_site_type_check CHECK ((site_type = ANY (ARRAY['BUILDING'::text, 'RESIDENTIAL'::text]))),
    CONSTRAINT council_permit_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.council_permit OWNER TO skeep;

--
-- Name: council_permit_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.council_permit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.council_permit_id_seq OWNER TO skeep;

--
-- Name: council_permit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.council_permit_id_seq OWNED BY public.council_permit.id;


--
-- Name: crm_event; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.crm_event (
    id bigint NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type text NOT NULL,
    entity_id uuid NOT NULL,
    entity_type text NOT NULL,
    version integer NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    received_at timestamp(0) with time zone NOT NULL,
    last_attempt_at timestamp(0) with time zone,
    CONSTRAINT crm_event_entity_type_check CHECK ((entity_type = ANY (ARRAY['ACCOUNT'::text, 'AGREEMENT'::text, 'AGREEMENT_LINE'::text, 'SERVICE_SCHEDULE_OVERRIDE'::text, 'SITE_LOCATION'::text]))),
    CONSTRAINT crm_event_event_type_check CHECK ((event_type = ANY (ARRAY['ACTIVATED'::text, 'REACTIVATED'::text, 'DEACTIVATED'::text, 'REVISED'::text, 'RESIGNED'::text, 'CANCELLED'::text, 'ON_HOLD_STATUS_ACTIVE'::text, 'ON_HOLD_STATUS_ACCOUNT_HOLD'::text, 'ON_HOLD_STATUS_CREDIT_HOLD'::text, 'ON_HOLD_STATUS_DEACTIVATED'::text, 'ON_HOLD_STATUS_PROVISIONAL'::text, 'ADDRESS_CREATED'::text, 'ADDRESS_UPDATED'::text]))),
    CONSTRAINT crm_event_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'COMPLETE'::text, 'FAILED'::text])))
);


ALTER TABLE public.crm_event OWNER TO skeep;

--
-- Name: crm_event_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.crm_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.crm_event_id_seq OWNER TO skeep;

--
-- Name: crm_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.crm_event_id_seq OWNED BY public.crm_event.id;


--
-- Name: delivery_docket_email_item; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.delivery_docket_email_item (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    email_override boolean DEFAULT false NOT NULL,
    additional_email_recipients text[],
    all_sent_email_recipients text[],
    attempts integer DEFAULT 0 NOT NULL,
    crm_email_id uuid,
    last_attempt timestamp with time zone,
    CONSTRAINT delivery_docket_email_item_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'COMPLETE'::text, 'FAILED'::text])))
);


ALTER TABLE public.delivery_docket_email_item OWNER TO skeep;

--
-- Name: delivery_docket_email_item_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.delivery_docket_email_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.delivery_docket_email_item_id_seq OWNER TO skeep;

--
-- Name: delivery_docket_email_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.delivery_docket_email_item_id_seq OWNED BY public.delivery_docket_email_item.id;


--
-- Name: depot; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.depot (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    address1 character varying(255),
    address2 character varying(255),
    city character varying(255),
    state text,
    postcode character varying(4),
    location public.geography(Point,4326),
    CONSTRAINT depot_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.depot OWNER TO skeep;

--
-- Name: depot_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.depot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.depot_id_seq OWNER TO skeep;

--
-- Name: depot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.depot_id_seq OWNED BY public.depot.id;


--
-- Name: driver; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.driver (
    id bigint NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    mobile_phone_number character varying(255) NOT NULL,
    email character varying(255),
    parks_at_id bigint,
    parks_at_home boolean DEFAULT false NOT NULL,
    epa_password character varying(255),
    note_for_allocators character varying(255),
    note_for_allocators_name character varying(255),
    note_for_allocators_last_updated timestamp(0) with time zone,
    expected_shift_start_time time without time zone,
    expected_shift_end_time time without time zone,
    expected_shift_days jsonb,
    start_date date,
    end_date date,
    trainer boolean DEFAULT false,
    personal_email character varying(254),
    personal_mobile_phone_number character varying(255),
    blood_group character varying(255),
    emergency_contact character varying(255),
    supervisor_name character varying(255),
    supervisor_mobile_phone_number character varying(255),
    allocator_name character varying(255),
    allocator_mobile_phone_number character varying(255),
    is_owner_of_id bigint,
    locked_out boolean DEFAULT false,
    version integer DEFAULT 0 NOT NULL,
    active boolean,
    driver_comments character varying(255),
    payroll_id character varying(255),
    imei_number character varying(255),
    signature_on_file boolean,
    success_factor_user_id character varying(255),
    accepted_device_terms boolean,
    accepted_device_terms_date date,
    watched_induction_video boolean,
    supervisor_start_time time without time zone,
    supervisor_id bigint,
    shift_licence_type_id bigint,
    driver_type text,
    state text,
    business_unit_id bigint,
    CONSTRAINT driver_driver_type_check CHECK ((driver_type = ANY (ARRAY['BINGO'::text, 'EXTERNAL'::text, 'SUBCONTRACTOR'::text]))),
    CONSTRAINT driver_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.driver OWNER TO skeep;

--
-- Name: driver_assigned_to_regions; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.driver_assigned_to_regions (
    driver_id bigint NOT NULL,
    region_id bigint NOT NULL
);


ALTER TABLE public.driver_assigned_to_regions OWNER TO skeep;

--
-- Name: driver_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.driver_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.driver_id_seq OWNER TO skeep;

--
-- Name: driver_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.driver_id_seq OWNED BY public.driver.id;


--
-- Name: driver_license; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.driver_license (
    id bigint NOT NULL,
    licence_number character varying(255) NOT NULL,
    licence_state text NOT NULL,
    expires_at date,
    type_id bigint NOT NULL,
    driver_id bigint NOT NULL,
    CONSTRAINT driver_license_licence_state_check CHECK ((licence_state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.driver_license OWNER TO skeep;

--
-- Name: driver_license_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.driver_license_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.driver_license_id_seq OWNER TO skeep;

--
-- Name: driver_license_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.driver_license_id_seq OWNED BY public.driver_license.id;


--
-- Name: driver_trained_service_types; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.driver_trained_service_types (
    id bigint NOT NULL,
    driver_id bigint NOT NULL,
    crm_service_type_id uuid,
    preferred boolean
);


ALTER TABLE public.driver_trained_service_types OWNER TO skeep;

--
-- Name: driver_trained_service_types_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.driver_trained_service_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.driver_trained_service_types_id_seq OWNER TO skeep;

--
-- Name: driver_trained_service_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.driver_trained_service_types_id_seq OWNED BY public.driver_trained_service_types.id;


--
-- Name: driver_truck_allocation; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.driver_truck_allocation (
    id bigint NOT NULL,
    driver_id bigint NOT NULL,
    truck_id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date,
    driver_changed_truck boolean
);


ALTER TABLE public.driver_truck_allocation OWNER TO skeep;

--
-- Name: driver_truck_allocation_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.driver_truck_allocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.driver_truck_allocation_id_seq OWNER TO skeep;

--
-- Name: driver_truck_allocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.driver_truck_allocation_id_seq OWNED BY public.driver_truck_allocation.id;


--
-- Name: heartbeat; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.heartbeat (
    id bigint NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    path character varying(255) NOT NULL,
    updated_at timestamp(0) with time zone NOT NULL
);


ALTER TABLE public.heartbeat OWNER TO skeep;

--
-- Name: heartbeat_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.heartbeat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.heartbeat_id_seq OWNER TO skeep;

--
-- Name: heartbeat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.heartbeat_id_seq OWNED BY public.heartbeat.id;


--
-- Name: internal_metadata; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.internal_metadata (
    id bigint NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.internal_metadata OWNER TO skeep;

--
-- Name: internal_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.internal_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.internal_metadata_id_seq OWNER TO skeep;

--
-- Name: internal_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.internal_metadata_id_seq OWNED BY public.internal_metadata.id;


--
-- Name: mybingo_invoice_payment; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_invoice_payment (
    id bigint NOT NULL,
    mode integer NOT NULL,
    crm_invoice_id character varying(255) NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    is_deleted boolean DEFAULT false,
    payment_id character varying(255),
    crm_account_id uuid NOT NULL
);


ALTER TABLE public.mybingo_invoice_payment OWNER TO skeep;

--
-- Name: invoice_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.invoice_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoice_payment_id_seq OWNER TO skeep;

--
-- Name: invoice_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.invoice_payment_id_seq OWNED BY public.mybingo_invoice_payment.id;


--
-- Name: job; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.job (
    id bigint NOT NULL,
    status text DEFAULT 'NOT_BOOKED_IN'::text NOT NULL,
    type text NOT NULL,
    business_unit_id bigint NOT NULL,
    waste_type_id uuid,
    fixed_date_time timestamp(0) with time zone,
    priority text DEFAULT 'NORMAL'::text NOT NULL,
    preferred_time_window_id bigint,
    crm_service_agreement_line_id uuid,
    allocated_date date,
    crm_account_id uuid,
    crm_site_destination_id uuid,
    crm_service_type_id uuid,
    weight_limit integer,
    customer_signature_id bigint,
    mark_driver_notes_as_important boolean DEFAULT false NOT NULL,
    job_notes character varying(255),
    tip_site_destination_id bigint,
    is_hazardous_waste boolean DEFAULT false NOT NULL,
    consignment_number character varying(255),
    customer_signature_name character varying(255),
    council_permit_number character varying(255),
    council_permit_number_required boolean DEFAULT false NOT NULL,
    is_damage_waived boolean DEFAULT false NOT NULL,
    is_section8checked boolean DEFAULT false NOT NULL,
    is_council_permit_required boolean DEFAULT false NOT NULL,
    has_driver_received_cash boolean DEFAULT false NOT NULL,
    site_inspection_issues jsonb,
    crm_service_agreement_id uuid,
    initial_allocated_date date,
    transferred_from_business_unit_id bigint,
    time_slot character varying(255),
    access_time character varying(255),
    expected_weight text,
    region_override_id bigint,
    ordered_by_contact_id uuid,
    site_contact_id uuid,
    bin_is_contaminated boolean DEFAULT false NOT NULL,
    is_reviewed boolean DEFAULT false NOT NULL,
    cancel_reason text,
    door_direction text,
    crm_bin_location_destination_id uuid,
    tip_site_load_id bigint,
    crm_site_load_id uuid,
    pit_size character varying,
    pit_number character varying,
    trade_waste_number character varying,
    po_number character varying(50),
    pickup_job_id bigint,
    customer_has_been_informed_of_hire_period boolean,
    cancellation_is_chargeable boolean DEFAULT false NOT NULL,
    crm_bin_location_source_id uuid,
    completed_bin_service_note jsonb,
    superseded_job_id bigint,
    crm_initial_bin_location_destination_id uuid,
    previous_on_hold_status text,
    crm_preferred_truck_size_id uuid,
    council_permit_picked_up boolean DEFAULT false,
    CONSTRAINT job_door_direction_check CHECK ((door_direction = ANY (ARRAY['NO_SPECIFIC_DIRECTION'::text, 'DOOR_TOWARDS_CAB'::text, 'DOOR_AWAY_FROM_CAB'::text]))),
    CONSTRAINT job_expected_weight_check CHECK ((expected_weight = ANY (ARRAY['Light'::text, 'Medium'::text, 'Heavy'::text]))),
    CONSTRAINT job_status_check CHECK ((status = ANY (ARRAY['NOT_BOOKED_IN'::text, 'BOOKED_IN'::text, 'ALLOCATED'::text, 'DESPATCHED'::text, 'EN_ROUTE'::text, 'ARRIVED'::text, 'DONE'::text, 'TIPPED'::text, 'INCOMPLETE'::text, 'CANCELLED'::text, 'ON_HOLD'::text, 'PENDING'::text, 'MISSED_SERVICE'::text, 'PARTIALLY_COMPLETE'::text, 'ATTEMPTED'::text, 'PICKED_UP'::text, 'SUPERSEDED'::text]))),
    CONSTRAINT job_type_check CHECK ((type = ANY (ARRAY['DELIVER'::text, 'COLLECT'::text, 'PICKUP'::text, 'CHANGEOVER'::text, 'RELOCATE'::text, 'WAIT_AND_LOAD'::text, 'TRANSFER'::text, 'TIP'::text, 'PARK_UP'::text, 'TIP_AND_RETURN'::text, 'BIN_REPAIR'::text, 'BIN_REPLACEMENT'::text]))),
    CONSTRAINT priority CHECK ((priority = ANY (ARRAY['NORMAL'::text, 'HIGH'::text, 'URGENT'::text])))
);


ALTER TABLE public.job OWNER TO skeep;

--
-- Name: job_accessories_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.job_accessories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_accessories_id_seq OWNER TO skeep;

--
-- Name: job_attempt; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.job_attempt (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    driver_id bigint NOT NULL,
    truck_id bigint,
    attempt_order integer DEFAULT 1 NOT NULL,
    enroute_at timestamp(0) with time zone,
    arrived_at timestamp(0) with time zone,
    finished_at timestamp(0) with time zone,
    incomplete_job_notes text,
    destination_tip_summary_id bigint,
    tipping_notes text,
    load_tip_summary_id bigint,
    needs_to_be_tipped boolean DEFAULT false NOT NULL,
    trailer_id bigint,
    load_tip_status text DEFAULT 'NONE'::text NOT NULL,
    destination_tip_status text DEFAULT 'NONE'::text NOT NULL,
    destination_enroute_at timestamp(0) with time zone,
    destination_arrived_at timestamp(0) with time zone,
    destination_finished_at timestamp(0) with time zone,
    CONSTRAINT job_attempt_destination_tip_status_check CHECK ((destination_tip_status = ANY (ARRAY['NONE'::text, 'DOES_NOT_TIP'::text, 'WAITING_TO_TIP'::text, 'HAS_BEEN_TIPPED'::text, 'TIPPED_LOAD_REJECTED'::text, 'TIP_REALLOCATED'::text, 'OTHER'::text]))),
    CONSTRAINT job_attempt_load_tip_status_check CHECK ((load_tip_status = ANY (ARRAY['NONE'::text, 'DOES_NOT_TIP'::text, 'WAITING_TO_TIP'::text, 'HAS_BEEN_TIPPED'::text, 'OTHER'::text])))
);


ALTER TABLE public.job_attempt OWNER TO skeep;

--
-- Name: job_attempt_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.job_attempt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_attempt_id_seq OWNER TO skeep;

--
-- Name: job_attempt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.job_attempt_id_seq OWNED BY public.job_attempt.id;


--
-- Name: job_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_id_seq OWNER TO skeep;

--
-- Name: job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.job_id_seq OWNED BY public.job.id;


--
-- Name: job_permit; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.job_permit (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    permit_number character varying(255) NOT NULL,
    charges numeric(12,4) NOT NULL,
    council_id bigint NOT NULL,
    expiry_date date NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    archived_at timestamp(0) with time zone
);


ALTER TABLE public.job_permit OWNER TO skeep;

--
-- Name: job_permit_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.job_permit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_permit_id_seq OWNER TO skeep;

--
-- Name: job_permit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.job_permit_id_seq OWNED BY public.job_permit.id;


--
-- Name: job_photo_collection; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.job_photo_collection (
    id bigint NOT NULL,
    type text NOT NULL,
    job_id bigint NOT NULL,
    CONSTRAINT job_photo_collection_type_check CHECK ((type = ANY (ARRAY['EVIDENCE'::text, 'TIPPING'::text, 'BIN_LOCATION'::text, 'BIN_SERIAL'::text, 'BIN_PU_DEL'::text, 'BIN_EMPTY_FULL'::text, 'BIN_SERVICED'::text, 'BIN_CONTAMINATED'::text, 'CASH_PAYMENT_EVIDENCE'::text])))
);


ALTER TABLE public.job_photo_collection OWNER TO skeep;

--
-- Name: job_photo_collection_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.job_photo_collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_photo_collection_id_seq OWNER TO skeep;

--
-- Name: job_photo_collection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.job_photo_collection_id_seq OWNED BY public.job_photo_collection.id;


--
-- Name: region; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.region (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    polygon public.geography(Polygon,4326),
    colour character(7) NOT NULL,
    state text NOT NULL,
    CONSTRAINT region_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.region OWNER TO skeep;

--
-- Name: site_location_point; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.site_location_point (
    id bigint NOT NULL,
    crm_site_location_id uuid NOT NULL,
    crm_site_location_version_id character varying(20) NOT NULL,
    location public.geography(Point,4326) NOT NULL,
    created_at timestamp(0) with time zone NOT NULL
);


ALTER TABLE public.site_location_point OWNER TO skeep;

--
-- Name: job_regions; Type: VIEW; Schema: public; Owner: skeep
--

CREATE VIEW public.job_regions AS
 SELECT e2.id AS job_id,
    e1.id AS region_id
   FROM public.site_location_point e0,
    public.region e1,
    public.job e2
  WHERE (public.st_intersects(e1.polygon, e0.location) AND (e0.crm_site_location_id = e2.crm_site_destination_id));


ALTER TABLE public.job_regions OWNER TO skeep;

--
-- Name: job_sms_log; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.job_sms_log (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    type character varying NOT NULL,
    created_at timestamp(0) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT job_sms_log_check CHECK (((type)::text = ANY ((ARRAY['NONE'::character varying, 'EN_ROUTE'::character varying, 'DAY2'::character varying, 'TOM'::character varying, 'DAYS21'::character varying])::text[])))
);


ALTER TABLE public.job_sms_log OWNER TO skeep;

--
-- Name: job_sms_log_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.job_sms_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_sms_log_id_seq OWNER TO skeep;

--
-- Name: job_sms_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.job_sms_log_id_seq OWNED BY public.job_sms_log.id;


--
-- Name: tip_summary_waste_breakdown; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.tip_summary_waste_breakdown (
    id bigint NOT NULL,
    job_id bigint,
    waste_type_id character varying(255) NOT NULL,
    percentage numeric(5,2) NOT NULL,
    tip_summary_id bigint
);


ALTER TABLE public.tip_summary_waste_breakdown OWNER TO skeep;

--
-- Name: job_waste_breakdown_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.job_waste_breakdown_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_waste_breakdown_id_seq OWNER TO skeep;

--
-- Name: job_waste_breakdown_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.job_waste_breakdown_id_seq OWNED BY public.tip_summary_waste_breakdown.id;


--
-- Name: license_type; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.license_type (
    id bigint NOT NULL,
    abbreviation character varying(5),
    name character varying(255) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.license_type OWNER TO skeep;

--
-- Name: license_type_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.license_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.license_type_id_seq OWNER TO skeep;

--
-- Name: license_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.license_type_id_seq OWNED BY public.license_type.id;


--
-- Name: migration; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.migration (
    id integer NOT NULL,
    last_migration numeric NOT NULL,
    run_at timestamp(0) with time zone NOT NULL
);


ALTER TABLE public.migration OWNER TO skeep;

--
-- Name: migration_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.migration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migration_id_seq OWNER TO skeep;

--
-- Name: migration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.migration_id_seq OWNED BY public.migration.id;


--
-- Name: mybingo_announcement; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_announcement (
    id bigint NOT NULL,
    url character varying(1024),
    value text,
    is_published boolean,
    is_active boolean,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone
);


ALTER TABLE public.mybingo_announcement OWNER TO skeep;

--
-- Name: mybingo_announcement_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_announcement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_announcement_id_seq OWNER TO skeep;

--
-- Name: mybingo_announcement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_announcement_id_seq OWNED BY public.mybingo_announcement.id;


--
-- Name: mybingo_document; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_document (
    id bigint NOT NULL,
    crm_account_id uuid NOT NULL,
    document_type smallint NOT NULL,
    document_name character varying(255) NOT NULL,
    file_name character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    crm_site_id uuid,
    added_by_id bigint,
    updated_by_id bigint,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone
);


ALTER TABLE public.mybingo_document OWNER TO skeep;

--
-- Name: mybingo_document_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_document_id_seq OWNER TO skeep;

--
-- Name: mybingo_document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_document_id_seq OWNED BY public.mybingo_document.id;


--
-- Name: mybingo_email_type; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_email_type (
    id bigint NOT NULL,
    name character varying(512),
    request_area_id integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.mybingo_email_type OWNER TO skeep;

--
-- Name: mybingo_email_type_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_email_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_email_type_id_seq OWNER TO skeep;

--
-- Name: mybingo_email_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_email_type_id_seq OWNED BY public.mybingo_email_type.id;


--
-- Name: mybingo_information_type; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_information_type (
    id bigint NOT NULL,
    name character varying(512),
    request_area_id integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.mybingo_information_type OWNER TO skeep;

--
-- Name: mybingo_information_type_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_information_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_information_type_id_seq OWNER TO skeep;

--
-- Name: mybingo_information_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_information_type_id_seq OWNED BY public.mybingo_information_type.id;


--
-- Name: mybingo_notification; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_notification (
    id bigint NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    crm_account_id uuid NOT NULL,
    notification_type smallint NOT NULL,
    title character varying(255),
    message character varying(255),
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone,
    is_admin_notification boolean DEFAULT false NOT NULL,
    crm_site_id uuid
);


ALTER TABLE public.mybingo_notification OWNER TO skeep;

--
-- Name: mybingo_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_notification_id_seq OWNER TO skeep;

--
-- Name: mybingo_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_notification_id_seq OWNED BY public.mybingo_notification.id;


--
-- Name: mybingo_order_blocked_time_slot; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_order_blocked_time_slot (
    id bigint NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    date date NOT NULL,
    is_for_vip_customer boolean DEFAULT false NOT NULL,
    state text NOT NULL,
    time_slot_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(0) with time zone DEFAULT now() NOT NULL,
    updated_at timestamp(0) with time zone NOT NULL,
    CONSTRAINT mybingo_order_blocked_time_slot_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.mybingo_order_blocked_time_slot OWNER TO skeep;

--
-- Name: mybingo_order_blocked_time_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_order_blocked_time_slot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_order_blocked_time_slot_id_seq OWNER TO skeep;

--
-- Name: mybingo_order_blocked_time_slot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_order_blocked_time_slot_id_seq OWNED BY public.mybingo_order_blocked_time_slot.id;


--
-- Name: mybingo_order_cut_off_time; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_order_cut_off_time (
    id bigint NOT NULL,
    cut_off_time time without time zone NOT NULL,
    lead_days integer NOT NULL,
    is_vip_customer_cut_off_time boolean DEFAULT false NOT NULL,
    state text NOT NULL,
    job_type text DEFAULT 'DELIVER'::text NOT NULL,
    is_saturday_cut_off_time boolean DEFAULT false NOT NULL,
    time_slot_id bigint,
    CONSTRAINT mybingo_order_cut_off_time_job_type_check CHECK ((job_type = ANY (ARRAY['DELIVER'::text, 'COLLECT'::text, 'PICKUP'::text, 'CHANGEOVER'::text, 'RELOCATE'::text, 'WAIT_AND_LOAD'::text, 'TRANSFER'::text, 'TIP'::text, 'PARK_UP'::text, 'TIP_AND_RETURN'::text, 'BIN_REPAIR'::text, 'BIN_REPLACEMENT'::text]))),
    CONSTRAINT mybingo_order_cut_off_time_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.mybingo_order_cut_off_time OWNER TO skeep;

--
-- Name: COLUMN mybingo_order_cut_off_time.lead_days; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.mybingo_order_cut_off_time.lead_days IS 'Number of days to the delivery date';


--
-- Name: mybingo_order_cut_off_time_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_order_cut_off_time_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_order_cut_off_time_id_seq OWNER TO skeep;

--
-- Name: mybingo_order_cut_off_time_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_order_cut_off_time_id_seq OWNED BY public.mybingo_order_cut_off_time.id;


--
-- Name: mybingo_order_cut_off_time_time_slot; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_order_cut_off_time_time_slot (
    id bigint NOT NULL,
    cut_off_time_id bigint NOT NULL,
    time_slot_id bigint NOT NULL,
    sort_order integer NOT NULL
);


ALTER TABLE public.mybingo_order_cut_off_time_time_slot OWNER TO skeep;

--
-- Name: COLUMN mybingo_order_cut_off_time_time_slot.sort_order; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.mybingo_order_cut_off_time_time_slot.sort_order IS 'The order in which to display the time slot';


--
-- Name: mybingo_order_cut_off_time_time_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_order_cut_off_time_time_slot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_order_cut_off_time_time_slot_id_seq OWNER TO skeep;

--
-- Name: mybingo_order_cut_off_time_time_slot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_order_cut_off_time_time_slot_id_seq OWNED BY public.mybingo_order_cut_off_time_time_slot.id;


--
-- Name: mybingo_order_time_slot; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_order_time_slot (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    short_name character varying(255) NOT NULL
);


ALTER TABLE public.mybingo_order_time_slot OWNER TO skeep;

--
-- Name: mybingo_order_time_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_order_time_slot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_order_time_slot_id_seq OWNER TO skeep;

--
-- Name: mybingo_order_time_slot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_order_time_slot_id_seq OWNED BY public.mybingo_order_time_slot.id;


--
-- Name: mybingo_permission; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_permission (
    id bigint NOT NULL,
    permission_name character varying(255) NOT NULL
);


ALTER TABLE public.mybingo_permission OWNER TO skeep;

--
-- Name: mybingo_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_permission_id_seq OWNER TO skeep;

--
-- Name: mybingo_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_permission_id_seq OWNED BY public.mybingo_permission.id;


--
-- Name: mybingo_request; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_request (
    id bigint NOT NULL,
    crm_account_id uuid NOT NULL,
    crm_site_id uuid,
    request_area smallint NOT NULL,
    request_type_id bigint,
    skip_order_id character varying(255),
    invoice_id uuid,
    service_details text,
    estimated_date timestamp(0) with time zone,
    request_status smallint NOT NULL,
    is_compactor_service boolean NOT NULL,
    preferred_date_of_service timestamp(0) with time zone,
    description text,
    waste_type_id character varying(255),
    commercial_bin_on_site_id character varying(255),
    action_type smallint,
    amend_bin_type smallint,
    quantity integer,
    requested_by_id bigint,
    admin_user_first_name character varying(255),
    admin_user_last_name character varying(255),
    admin_user_email character varying(255),
    admin_mobile character varying(255),
    completed_date timestamp(0) with time zone,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone,
    email_recipient character varying(255),
    comments text,
    service_type smallint
);


ALTER TABLE public.mybingo_request OWNER TO skeep;

--
-- Name: mybingo_request_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_request_id_seq OWNER TO skeep;

--
-- Name: mybingo_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_request_id_seq OWNED BY public.mybingo_request.id;


--
-- Name: mybingo_request_type; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_request_type (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    request_completion_buffer_days integer,
    request_area smallint NOT NULL
);


ALTER TABLE public.mybingo_request_type OWNER TO skeep;

--
-- Name: mybingo_request_type_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_request_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_request_type_id_seq OWNER TO skeep;

--
-- Name: mybingo_request_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_request_type_id_seq OWNED BY public.mybingo_request_type.id;


--
-- Name: mybingo_role_permission; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_role_permission (
    id bigint NOT NULL,
    role smallint NOT NULL,
    permission_id bigint NOT NULL,
    read boolean NOT NULL,
    write boolean NOT NULL,
    read_limited boolean NOT NULL,
    write_limited boolean NOT NULL
);


ALTER TABLE public.mybingo_role_permission OWNER TO skeep;

--
-- Name: mybingo_role_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_role_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_role_permission_id_seq OWNER TO skeep;

--
-- Name: mybingo_role_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_role_permission_id_seq OWNED BY public.mybingo_role_permission.id;


--
-- Name: mybingo_system_document; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_system_document (
    id bigint NOT NULL,
    document_name character varying(255) NOT NULL,
    document_category smallint NOT NULL,
    document_type smallint NOT NULL,
    key character varying(255),
    external_link character varying(255),
    is_deletable boolean DEFAULT false,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone,
    is_presentable_to_non_bingo_admin_user boolean DEFAULT false
);


ALTER TABLE public.mybingo_system_document OWNER TO skeep;

--
-- Name: mybingo_system_document_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_system_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_system_document_id_seq OWNER TO skeep;

--
-- Name: mybingo_system_document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_system_document_id_seq OWNED BY public.mybingo_system_document.id;


--
-- Name: mybingo_user; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_user (
    id bigint NOT NULL,
    cognito_username character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    email character varying(255),
    mobile character varying(255),
    user_account_status integer,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone,
    bingo_user_role_id integer,
    object_id character varying(255),
    registered_on timestamp(0) with time zone,
    is_deleted boolean DEFAULT false
);


ALTER TABLE public.mybingo_user OWNER TO skeep;

--
-- Name: COLUMN mybingo_user.object_id; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.mybingo_user.object_id IS 'Used for the App PIN';


--
-- Name: mybingo_user_account_favourite; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_user_account_favourite (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    crm_account_id uuid NOT NULL,
    is_deleted boolean DEFAULT false,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone
);


ALTER TABLE public.mybingo_user_account_favourite OWNER TO skeep;

--
-- Name: mybingo_user_account_favourite_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_user_account_favourite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_user_account_favourite_id_seq OWNER TO skeep;

--
-- Name: mybingo_user_account_favourite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_user_account_favourite_id_seq OWNED BY public.mybingo_user_account_favourite.id;


--
-- Name: mybingo_user_business_account_mapping; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_user_business_account_mapping (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role smallint NOT NULL,
    crm_account_id uuid NOT NULL,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone,
    is_deleted boolean DEFAULT false,
    is_active boolean DEFAULT true
);


ALTER TABLE public.mybingo_user_business_account_mapping OWNER TO skeep;

--
-- Name: mybingo_user_business_account_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_user_business_account_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_user_business_account_mapping_id_seq OWNER TO skeep;

--
-- Name: mybingo_user_business_account_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_user_business_account_mapping_id_seq OWNED BY public.mybingo_user_business_account_mapping.id;


--
-- Name: mybingo_user_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_user_id_seq OWNER TO skeep;

--
-- Name: mybingo_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_user_id_seq OWNED BY public.mybingo_user.id;


--
-- Name: mybingo_user_notification; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_user_notification (
    id bigint NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    user_id bigint NOT NULL,
    mybingo_notification_id bigint NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    created_on timestamp(0) with time zone
);


ALTER TABLE public.mybingo_user_notification OWNER TO skeep;

--
-- Name: mybingo_user_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_user_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_user_notification_id_seq OWNER TO skeep;

--
-- Name: mybingo_user_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_user_notification_id_seq OWNED BY public.mybingo_user_notification.id;


--
-- Name: mybingo_user_site_favourite; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_user_site_favourite (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    crm_site_id uuid,
    is_deleted boolean DEFAULT false,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone
);


ALTER TABLE public.mybingo_user_site_favourite OWNER TO skeep;

--
-- Name: mybingo_user_site_favourite_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_user_site_favourite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_user_site_favourite_id_seq OWNER TO skeep;

--
-- Name: mybingo_user_site_favourite_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_user_site_favourite_id_seq OWNED BY public.mybingo_user_site_favourite.id;


--
-- Name: mybingo_user_site_mapping; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.mybingo_user_site_mapping (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    crm_account_id uuid,
    crm_site_id uuid,
    created_on timestamp(0) with time zone,
    updated_on timestamp(0) with time zone,
    is_deleted boolean DEFAULT false
);


ALTER TABLE public.mybingo_user_site_mapping OWNER TO skeep;

--
-- Name: mybingo_user_site_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.mybingo_user_site_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mybingo_user_site_mapping_id_seq OWNER TO skeep;

--
-- Name: mybingo_user_site_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.mybingo_user_site_mapping_id_seq OWNED BY public.mybingo_user_site_mapping.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.notification (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    actions jsonb NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    has_been_read boolean DEFAULT true NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    topic text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.notification OWNER TO skeep;

--
-- Name: notification_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_id_seq OWNER TO skeep;

--
-- Name: notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.notification_id_seq OWNED BY public.notification.id;


--
-- Name: order; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public."order" (
    id bigint NOT NULL,
    status text NOT NULL,
    prepaid boolean NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    crm_sales_order_id uuid,
    order_number character varying(255),
    initial_price numeric(12,4),
    referred_by character varying(255),
    historical_data boolean DEFAULT false NOT NULL,
    CONSTRAINT order_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'READY'::text])))
);


ALTER TABLE public."order" OWNER TO skeep;

--
-- Name: COLUMN "order".crm_sales_order_id; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public."order".crm_sales_order_id IS 'This gets set by crm-order-sync';


--
-- Name: COLUMN "order".order_number; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public."order".order_number IS 'This gets set by crm-order-sync';


--
-- Name: order_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_id_seq OWNER TO skeep;

--
-- Name: order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.order_id_seq OWNED BY public."order".id;


--
-- Name: order_line; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.order_line (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    charge_for_service boolean,
    crm_sales_order_detail_id uuid,
    calculated_unit_price numeric(12,4),
    price_calculation_method text,
    rental_period_start date,
    rental_period_end date,
    notes text,
    initial_calculated_unit_price numeric(12,4),
    matching_tag character varying(255),
    quantity numeric(12,4),
    crm_product_id uuid,
    crm_unit_of_measure_id uuid,
    job_id bigint,
    tip_ticket_id bigint,
    overridden_unit_price numeric(12,4),
    unit_price numeric(12,4),
    mark_for_deletion boolean DEFAULT false,
    rental_frequency text,
    parent_matching_tag character varying(255),
    tax numeric(12,4),
    deleted boolean DEFAULT false NOT NULL,
    report_comment text,
    CONSTRAINT order_line_must_have_job_or_tip_ticket_check CHECK (((job_id IS NOT NULL) OR (tip_ticket_id IS NOT NULL))),
    CONSTRAINT order_line_rental_frequency_check CHECK ((rental_frequency = ANY (ARRAY['WEEKLY'::text, 'MONTHLY'::text, 'NONE'::text])))
);


ALTER TABLE public.order_line OWNER TO skeep;

--
-- Name: order_line_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.order_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_line_id_seq OWNER TO skeep;

--
-- Name: order_line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.order_line_id_seq OWNED BY public.order_line.id;


--
-- Name: order_sync_attempt_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.order_sync_attempt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_sync_attempt_id_seq OWNER TO skeep;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.payment (
    id bigint NOT NULL,
    amount numeric(8,2) NOT NULL,
    currency text NOT NULL,
    type text NOT NULL,
    reference_id character varying(255),
    merchant_transaction_id text NOT NULL,
    crm_account_id uuid NOT NULL,
    stored_card_id bigint,
    order_id bigint NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    transaction_type text DEFAULT 'DEBIT'::text NOT NULL,
    message text,
    status text DEFAULT 'WAITING'::text NOT NULL,
    terminal_id text,
    CONSTRAINT payment_currency_check CHECK ((currency = 'AUD'::text)),
    CONSTRAINT payment_transaction_type_check CHECK ((transaction_type = ANY (ARRAY['DEBIT'::text, 'REFUND'::text]))),
    CONSTRAINT payment_type_check CHECK ((type = ANY (ARRAY['CREDIT_CARD'::text, 'CASH'::text, 'ACCOUNT'::text, 'EFTPOS'::text, 'ONLINE'::text]))),
    CONSTRAINT status_check CHECK ((status = ANY (ARRAY['WAITING'::text, 'SUCCESS'::text, 'FAILED'::text])))
);


ALTER TABLE public.payment OWNER TO skeep;

--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payment_id_seq OWNER TO skeep;

--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


--
-- Name: photo; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.photo (
    id bigint NOT NULL,
    job_photo_collection_id bigint,
    path character varying(255),
    completed_bin_service_id bigint,
    truck_inspection_id bigint,
    "timestamp" timestamp(0) with time zone DEFAULT now() NOT NULL,
    truck_issue_reference_id bigint,
    is_tip_summary_spotter_photo_for_id bigint,
    is_tip_summary_contaminated_photo_for_id bigint,
    client_id character varying(255),
    uploaded boolean DEFAULT true NOT NULL,
    source text DEFAULT 'S3_MEDIA_BUCKET'::text NOT NULL,
    deleted boolean DEFAULT false,
    CONSTRAINT photo_source_check CHECK ((source = 'S3_MEDIA_BUCKET'::text))
);


ALTER TABLE public.photo OWNER TO skeep;

--
-- Name: photo_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.photo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.photo_id_seq OWNER TO skeep;

--
-- Name: photo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.photo_id_seq OWNED BY public.photo.id;


--
-- Name: public_holiday; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.public_holiday (
    id bigint NOT NULL,
    date date NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    more_information character varying(255),
    state text NOT NULL,
    CONSTRAINT public_holiday_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.public_holiday OWNER TO skeep;

--
-- Name: public_holiday_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.public_holiday_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.public_holiday_id_seq OWNER TO skeep;

--
-- Name: public_holiday_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.public_holiday_id_seq OWNED BY public.public_holiday.id;


--
-- Name: region_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.region_id_seq OWNER TO skeep;

--
-- Name: region_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.region_id_seq OWNED BY public.region.id;


--
-- Name: roster_entry; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.roster_entry (
    id bigint NOT NULL,
    driver_id bigint NOT NULL,
    date date NOT NULL,
    start_time time without time zone,
    end_time time without time zone,
    type text NOT NULL,
    CONSTRAINT roster_entry_type_check CHECK ((type = ANY (ARRAY['WORKING'::text, 'ANNUAL_LEAVE'::text, 'PERSONAL_LEAVE'::text, 'NOT_WORKING'::text, 'WORKERS_COMP'::text])))
);


ALTER TABLE public.roster_entry OWNER TO skeep;

--
-- Name: roster_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.roster_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roster_entry_id_seq OWNER TO skeep;

--
-- Name: roster_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.roster_entry_id_seq OWNED BY public.roster_entry.id;


--
-- Name: runsheet; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.runsheet (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    state text NOT NULL,
    date date NOT NULL,
    from_template_id bigint,
    business_unit_id bigint NOT NULL,
    crm_service_type_id uuid,
    CONSTRAINT runsheet_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.runsheet OWNER TO skeep;

--
-- Name: runsheet_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.runsheet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.runsheet_id_seq OWNER TO skeep;

--
-- Name: runsheet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.runsheet_id_seq OWNED BY public.runsheet.id;


--
-- Name: runsheet_job_ordering; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.runsheet_job_ordering (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    runsheet_id bigint NOT NULL,
    ordering double precision NOT NULL
);


ALTER TABLE public.runsheet_job_ordering OWNER TO skeep;

--
-- Name: runsheet_job_ordering_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.runsheet_job_ordering_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.runsheet_job_ordering_id_seq OWNER TO skeep;

--
-- Name: runsheet_job_ordering_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.runsheet_job_ordering_id_seq OWNED BY public.runsheet_job_ordering.id;


--
-- Name: runsheet_template; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.runsheet_template (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    day_of_week smallint NOT NULL,
    state text NOT NULL,
    business_unit_id bigint NOT NULL,
    colour character(7),
    is_deleted boolean DEFAULT false NOT NULL,
    is_sub_contractor boolean DEFAULT false NOT NULL,
    is_night_shift boolean DEFAULT false NOT NULL,
    crm_service_type_id uuid,
    CONSTRAINT runsheet_template_state_check CHECK ((state = ANY (ARRAY['NSW'::text, 'VIC'::text, 'QLD'::text, 'ACT'::text, 'TAS'::text, 'SA'::text, 'WA'::text, 'NT'::text])))
);


ALTER TABLE public.runsheet_template OWNER TO skeep;

--
-- Name: runsheet_template_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.runsheet_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.runsheet_template_id_seq OWNER TO skeep;

--
-- Name: runsheet_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.runsheet_template_id_seq OWNED BY public.runsheet_template.id;


--
-- Name: runsheet_template_preferred_tip_sites; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.runsheet_template_preferred_tip_sites (
    runsheet_template_id bigint NOT NULL,
    tip_site_id bigint NOT NULL
);


ALTER TABLE public.runsheet_template_preferred_tip_sites OWNER TO skeep;

--
-- Name: service_agreement_line_ordering; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.service_agreement_line_ordering (
    id bigint NOT NULL,
    ordering double precision NOT NULL,
    crm_service_agreement_line_id character varying(255) NOT NULL,
    runsheet_template_id bigint NOT NULL
);


ALTER TABLE public.service_agreement_line_ordering OWNER TO skeep;

--
-- Name: service_line_item_ordering_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.service_line_item_ordering_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.service_line_item_ordering_id_seq OWNER TO skeep;

--
-- Name: service_line_item_ordering_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.service_line_item_ordering_id_seq OWNED BY public.service_agreement_line_ordering.id;


--
-- Name: shift; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.shift (
    id bigint NOT NULL,
    scheduled_start timestamp(0) with time zone NOT NULL,
    scheduled_end timestamp(0) with time zone NOT NULL,
    started_at timestamp(0) with time zone,
    ended_at timestamp(0) with time zone,
    is_cancelled boolean DEFAULT false NOT NULL,
    driver_id bigint NOT NULL,
    role text DEFAULT 'DRIVER'::text NOT NULL,
    end_overdue_notes text,
    truck_id bigint,
    rules text DEFAULT 'NONE'::text,
    next_truck_to_use_id bigint,
    CONSTRAINT shift_cannot_have_both_ended_at_and_truck_id CHECK ((NOT ((ended_at IS NOT NULL) AND (truck_id IS NOT NULL)))),
    CONSTRAINT shift_role_check CHECK ((role = ANY (ARRAY['NONE'::text, 'DRIVER'::text, 'PASSENGER'::text, 'OTHER'::text, 'MEETING'::text, 'TRAINING'::text, 'BROKEN_DOWN'::text]))),
    CONSTRAINT shift_rules_check CHECK ((rules = ANY (ARRAY['NONE'::text, 'NHVR'::text])))
);


ALTER TABLE public.shift OWNER TO skeep;

--
-- Name: shift_break; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.shift_break (
    id bigint NOT NULL,
    started_at timestamp(0) with time zone,
    ended_at timestamp(0) with time zone,
    shift_id bigint NOT NULL,
    scheduled_start timestamp(0) with time zone,
    scheduled_end timestamp(0) with time zone
);


ALTER TABLE public.shift_break OWNER TO skeep;

--
-- Name: shift_break_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.shift_break_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_break_id_seq OWNER TO skeep;

--
-- Name: shift_break_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.shift_break_id_seq OWNED BY public.shift_break.id;


--
-- Name: shift_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.shift_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_id_seq OWNER TO skeep;

--
-- Name: shift_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.shift_id_seq OWNED BY public.shift.id;


--
-- Name: site_driver_note; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.site_driver_note (
    id bigint NOT NULL,
    crm_site_location_id uuid NOT NULL,
    note character varying(255) NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    created_by_id bigint NOT NULL
);


ALTER TABLE public.site_driver_note OWNER TO skeep;

--
-- Name: site_driver_note_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.site_driver_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_driver_note_id_seq OWNER TO skeep;

--
-- Name: site_driver_note_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.site_driver_note_id_seq OWNED BY public.site_driver_note.id;


--
-- Name: site_location_point_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.site_location_point_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_location_point_id_seq OWNER TO skeep;

--
-- Name: site_location_point_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.site_location_point_id_seq OWNED BY public.site_location_point.id;


--
-- Name: site_preferred_driver; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.site_preferred_driver (
    id bigint NOT NULL,
    crm_site_location_id uuid NOT NULL,
    driver_id bigint NOT NULL
);


ALTER TABLE public.site_preferred_driver OWNER TO skeep;

--
-- Name: site_preferred_driver_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.site_preferred_driver_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.site_preferred_driver_id_seq OWNER TO skeep;

--
-- Name: site_preferred_driver_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.site_preferred_driver_id_seq OWNED BY public.site_preferred_driver.id;


--
-- Name: stored_card; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.stored_card (
    id bigint NOT NULL,
    reference_id character varying(255) NOT NULL,
    merchant_transaction_id uuid NOT NULL,
    crm_account_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    fingerprint character varying(255) NOT NULL,
    last_four_digits character varying(255) NOT NULL,
    month character varying(255) NOT NULL,
    year character varying(255) NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    is_deleted boolean DEFAULT false
);


ALTER TABLE public.stored_card OWNER TO skeep;

--
-- Name: stored_card_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.stored_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stored_card_id_seq OWNER TO skeep;

--
-- Name: stored_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.stored_card_id_seq OWNED BY public.stored_card.id;


--
-- Name: subscription; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.subscription (
    id bigint NOT NULL,
    topic character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    details jsonb NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    updated_at timestamp(0) with time zone,
    type character varying(50) DEFAULT 'WEB_PUSH'::character varying NOT NULL
);


ALTER TABLE public.subscription OWNER TO skeep;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subscription_id_seq OWNER TO skeep;

--
-- Name: subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.subscription_id_seq OWNED BY public.subscription.id;


--
-- Name: system_config; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.system_config (
    id bigint NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.system_config OWNER TO skeep;

--
-- Name: system_config_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.system_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_config_id_seq OWNER TO skeep;

--
-- Name: system_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.system_config_id_seq OWNED BY public.system_config.id;


--
-- Name: time_window; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.time_window (
    id bigint NOT NULL,
    time_window_from time without time zone NOT NULL,
    time_window_to time without time zone NOT NULL
);


ALTER TABLE public.time_window OWNER TO skeep;

--
-- Name: COLUMN time_window.time_window_from; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.time_window.time_window_from IS 'Window starts at this time, local time, inclusive';


--
-- Name: COLUMN time_window.time_window_to; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.time_window.time_window_to IS 'Window finishes at this time, local time, inclusive';


--
-- Name: time_window_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.time_window_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.time_window_id_seq OWNER TO skeep;

--
-- Name: time_window_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.time_window_id_seq OWNED BY public.time_window.id;


--
-- Name: tip_site; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.tip_site (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    street_1 character varying(255),
    street_2 character varying(255),
    city character varying(255),
    state character varying(255),
    postcode character varying(255),
    location public.geography(Point,4326),
    phone character varying(255),
    is_third_party_site boolean NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    opening_hours_weekdays_id bigint,
    opening_hours_saturdays_id bigint,
    opening_hours_sundays_id bigint,
    crm_bingo_site_id character varying(255),
    crm_cash_sales_account_id uuid,
    sync_mode text DEFAULT 'NO_SYNC'::text NOT NULL,
    epl_number character varying(255),
    enable_stored_tare_usage boolean DEFAULT true,
    crm_transfer_account_id uuid,
    CONSTRAINT tip_site_sync_mode_check CHECK ((sync_mode = ANY (ARRAY['TICKET_TO_SUMMARY'::text, 'SUMMARY_TO_TICKET'::text, 'NO_SYNC'::text])))
);


ALTER TABLE public.tip_site OWNER TO skeep;

--
-- Name: COLUMN tip_site.epl_number; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.tip_site.epl_number IS 'Defauld EPL Number for site, might e overriden in tip_site_location_on_site_epl';


--
-- Name: COLUMN tip_site.enable_stored_tare_usage; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.tip_site.enable_stored_tare_usage IS 'Enabling this allows the users of the WB to use the stored tare';


--
-- Name: tip_site_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.tip_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tip_site_id_seq OWNER TO skeep;

--
-- Name: tip_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.tip_site_id_seq OWNED BY public.tip_site.id;


--
-- Name: tip_site_location_on_site_epl; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.tip_site_location_on_site_epl (
    tip_site_id bigint NOT NULL,
    location_on_site text NOT NULL,
    epl_number character varying(255) NOT NULL,
    CONSTRAINT tip_site_location_on_site_epl_location_on_site_check CHECK ((location_on_site = ANY (ARRAY['TIPPING_FLOOR'::text, 'MPC'::text, 'MPC2'::text, 'LANDFILL'::text, 'CRUSHING_YARD'::text, 'TIMBER_YARD'::text, 'ECMPC'::text])))
);


ALTER TABLE public.tip_site_location_on_site_epl OWNER TO skeep;

--
-- Name: COLUMN tip_site_location_on_site_epl.location_on_site; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.tip_site_location_on_site_epl.location_on_site IS 'Location on Site (TIPPING_FLOOR, MPC, MPC2, LANDFILL, CRUSHING_YARD, TIMBER_YARD, ECMPC)';


--
-- Name: COLUMN tip_site_location_on_site_epl.epl_number; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.tip_site_location_on_site_epl.epl_number IS 'EPL number';


--
-- Name: tip_site_location_on_site_epl_tip_site_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.tip_site_location_on_site_epl_tip_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tip_site_location_on_site_epl_tip_site_id_seq OWNER TO skeep;

--
-- Name: tip_site_location_on_site_epl_tip_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.tip_site_location_on_site_epl_tip_site_id_seq OWNED BY public.tip_site_location_on_site_epl.tip_site_id;


--
-- Name: tip_site_waste_stockpile; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.tip_site_waste_stockpile (
    id bigint NOT NULL,
    tip_site_id bigint NOT NULL,
    internal_destination text NOT NULL,
    waste_type_id uuid NOT NULL,
    stockpile_weight integer NOT NULL,
    last_update_reason character varying(255) DEFAULT 'TIP_TICKET_DONE'::character varying NOT NULL,
    last_update_notes text,
    CONSTRAINT tip_site_waste_stockpile_internal_destination_check CHECK ((internal_destination = ANY (ARRAY['TIPPING_FLOOR'::text, 'MPC'::text, 'MPC2'::text, 'LANDFILL'::text, 'CRUSHING_YARD'::text, 'TIMBER_YARD'::text, 'ECMPC'::text])))
);


ALTER TABLE public.tip_site_waste_stockpile OWNER TO skeep;

--
-- Name: tip_site_waste_stockpile_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.tip_site_waste_stockpile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tip_site_waste_stockpile_id_seq OWNER TO skeep;

--
-- Name: tip_site_waste_stockpile_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.tip_site_waste_stockpile_id_seq OWNED BY public.tip_site_waste_stockpile.id;


--
-- Name: tip_summary; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.tip_summary (
    id bigint NOT NULL,
    tip_job_id bigint NOT NULL,
    weight integer,
    docket_number character varying(255),
    docket_photo_id bigint,
    docket_photo_notes character varying(255),
    is_contaminated boolean DEFAULT false,
    contaminated_notes character varying(255),
    contaminated_photo_id bigint,
    arrived_at timestamp(0) with time zone,
    finished_at timestamp(0) with time zone,
    waste_type_id uuid,
    status character varying(255) DEFAULT 'MANUAL_ENTRY'::character varying NOT NULL,
    submitted_by character varying(255),
    sync_mode text DEFAULT 'NO_SYNC'::text NOT NULL,
    CONSTRAINT tip_summary_submitted_by_check CHECK (((submitted_by)::text = ANY (ARRAY[('DRIVER'::character varying)::text, ('WEIGHBRIDGE'::character varying)::text]))),
    CONSTRAINT tip_summary_sync_mode_check CHECK ((sync_mode = ANY (ARRAY['TICKET_TO_SUMMARY'::text, 'SUMMARY_TO_TICKET'::text, 'NO_SYNC'::text])))
);


ALTER TABLE public.tip_summary OWNER TO skeep;

--
-- Name: tip_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.tip_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tip_summary_id_seq OWNER TO skeep;

--
-- Name: tip_summary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.tip_summary_id_seq OWNED BY public.tip_summary.id;


--
-- Name: tip_ticket; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.tip_ticket (
    id bigint NOT NULL,
    trailer_plate_number character varying(255),
    purpose_of_visit character varying(255),
    po_number character varying(255),
    gross_weight numeric(12,4),
    tare_weight numeric(12,4),
    set_weight_gross_manually boolean,
    manual_gross_weight_reason text,
    manual_gross_weight_notes text,
    notes text,
    created_from_job_id bigint,
    driver_signature_id bigint,
    status text DEFAULT 'NEW'::text NOT NULL,
    cancellation_reason text,
    driver_id bigint,
    truck_id bigint,
    tip_date date DEFAULT timezone('Australia/Sydney'::text, now()) NOT NULL,
    waste_type_id uuid,
    waste_sub_type_id uuid,
    tip_site_id character varying(255),
    primary_internal_destination text,
    crm_account_id uuid,
    crm_suburb_id uuid,
    waste_stream text,
    crm_customer_site_id uuid,
    updated_at timestamp(0) with time zone,
    created_at timestamp(0) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    crm_weighbridge_contract_id uuid,
    volume integer,
    entry_weighbridge character varying(225),
    exit_weighbridge character varying(225),
    manual_tare_weight_reason text,
    manual_tare_weight_notes text,
    tare_weight_method text,
    bin_designations uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    is_reviewed boolean DEFAULT false NOT NULL,
    on_site_at timestamp(0) with time zone,
    completed_at timestamp(0) with time zone,
    is_rejected_load boolean DEFAULT false,
    rejected_load_reason text,
    rejected_load_notes text,
    not_on_account boolean DEFAULT false NOT NULL,
    cancellation_notes text,
    secondary_internal_destination text,
    is_not_added_to_stockpile boolean DEFAULT false,
    operator_name text,
    consignment_number character varying(255),
    won_on_site_approval_number character varying(255),
    won_on_site_notes text,
    weigh_time_in timestamp(0) with time zone,
    weigh_time_out timestamp(0) with time zone,
    net_weight integer GENERATED ALWAYS AS (
CASE
    WHEN is_rejected_load THEN GREATEST((gross_weight - tare_weight), (0)::numeric)
    ELSE (gross_weight - tare_weight)
END) STORED,
    parked boolean DEFAULT false NOT NULL,
    municipal_sub_stream text,
    destination_waste_type_id uuid,
    CONSTRAINT manual_gross_weight_reason CHECK ((manual_gross_weight_reason = ANY (ARRAY['PULLING_INCORRECT_WEIGHTS'::text, 'WEIGHBRIDGE_SCALES_DOWN'::text, NULL::text]))),
    CONSTRAINT rejected_load_reason_check CHECK ((rejected_load_reason = ANY (ARRAY['FOOD_IN_LOAD'::text, 'ASBESTOS'::text, 'CHEMICALS'::text, 'OTHER'::text]))),
    CONSTRAINT tip_ticket_cancellation_reason_check CHECK ((cancellation_reason = ANY (ARRAY['ISSUE_WITH_TICKET_OR_SYSTEM'::text, 'INCORRECT_WEIGHTS'::text, 'ON_HOLD'::text, 'TESTING'::text, 'INCORRECT_MATERIAL'::text, 'INCORRECT_CUSTOMER'::text, 'INCORRECT_RATE'::text, 'NOT_AUTHORISED'::text, 'INSUFFICIENT_PRODUCT'::text, 'RATES_TOO_EXPENSIVE'::text, 'JOB_WAS_CANCELLED'::text, 'CUSTOMERS_JOB_WAS_CANCELLED'::text, 'ISSUE_WITH_TRUCK'::text, 'DRIVER_MISSING_REQUIRED_PPE'::text, 'WAITING_TIME_TOO_LONG'::text, 'CHANGED_BY_ALLOCATOR'::text]))),
    CONSTRAINT tip_ticket_internal_destination_check CHECK ((primary_internal_destination = ANY (ARRAY['TIPPING_FLOOR'::text, 'MPC'::text, 'MPC2'::text, 'LANDFILL'::text, 'CRUSHING_YARD'::text, 'TIMBER_YARD'::text, 'ECMPC'::text]))),
    CONSTRAINT tip_ticket_manual_tare_weight_reason_check CHECK ((manual_tare_weight_reason = ANY (ARRAY['PULLING_INCORRECT_WEIGHTS'::text, 'WEIGHBRIDGE_SCALES_DOWN'::text]))),
    CONSTRAINT tip_ticket_municipal_sub_stream_check CHECK ((municipal_sub_stream = ANY (ARRAY['DOMESTIC'::text, 'OTHER'::text, 'COUNCIL'::text, 'GARDEN_ORGANICS'::text]))),
    CONSTRAINT tip_ticket_secondary_internal_destination_check CHECK ((secondary_internal_destination = ANY (ARRAY['TIPPING_FLOOR'::text, 'MPC'::text, 'MPC2'::text, 'LANDFILL'::text, 'CRUSHING_YARD'::text, 'TIMBER_YARD'::text, 'ECMPC'::text]))),
    CONSTRAINT tip_ticket_status_check CHECK ((status = ANY (ARRAY['NEW'::text, 'ON_SITE'::text, 'DONE'::text, 'CANCELLED'::text, 'AWAITING_PAYMENT'::text]))),
    CONSTRAINT tip_ticket_tare_weight_method_check CHECK ((tare_weight_method = ANY (ARRAY['STORED'::text, 'MANUAL'::text, 'SCALE'::text]))),
    CONSTRAINT tip_ticket_waste_stream_check CHECK ((waste_stream = ANY (ARRAY['MUNICIPAL_WASTE'::text, 'CONSTRUCTION_DEMOLITION'::text, 'COMMERCIAL_INDUSTRIAL'::text, 'OTHER'::text, 'NA'::text])))
);


ALTER TABLE public.tip_ticket OWNER TO skeep;

--
-- Name: tip_ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.tip_ticket_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tip_ticket_id_seq OWNER TO skeep;

--
-- Name: tip_ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.tip_ticket_id_seq OWNED BY public.tip_ticket.id;


--
-- Name: transfer_job; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.transfer_job (
    job_id bigint,
    crm_contract_id uuid,
    crm_load_waste_type_id uuid,
    crm_destination_waste_type_id uuid,
    crm_bin_designation_id uuid,
    id bigint NOT NULL,
    configuration text DEFAULT 'BINGO_TIP_TO_BINGO_TIP'::text,
    CONSTRAINT transfer_job_configuration_check CHECK ((configuration = ANY (ARRAY['BINGO_TIP_TO_BINGO_TIP'::text, 'CUSTOMER_TO_BINGO_TIP'::text, 'BINGO_TIP_TO_CUSTOMER'::text, 'EXTERNAL_TIP_TO_BINGO_TIP'::text, 'BINGO_TIP_TO_EXTERNAL_TIP'::text])))
);


ALTER TABLE public.transfer_job OWNER TO skeep;

--
-- Name: transfer_job_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.transfer_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transfer_job_id_seq OWNER TO skeep;

--
-- Name: transfer_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.transfer_job_id_seq OWNED BY public.transfer_job.id;


--
-- Name: truck; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.truck (
    id bigint NOT NULL,
    plate_number character varying(255) NOT NULL,
    transmission text,
    home_depot_id bigint,
    status text,
    asset_number character varying(255),
    make character varying(255),
    model character varying(255),
    vin character varying(255),
    engine_number character varying(255),
    sp_serial_number character varying(255),
    capacity_cap numeric(10,2),
    tare numeric(10,0),
    length numeric(10,2),
    width numeric(10,2),
    height numeric(10,2),
    turning_circle_radius numeric(10,2),
    wheel_base numeric(10,2),
    two_way_radio boolean,
    fuel_tag_number character varying(255),
    scales_last_calibrated_at timestamp(0) with time zone,
    manufacture_date_of_chassis date,
    manufacture_date_of_body date,
    is_in_use boolean DEFAULT false NOT NULL,
    crm_service_type_id uuid,
    owner_type text,
    weight_limit_type text,
    vehicle_type_id bigint,
    gml_exemption_proposed boolean DEFAULT false,
    tare_updated_date timestamp(0) with time zone,
    tare_updated_by_operator character varying(255),
    tare_updated_site_id character varying(255),
    size_id uuid,
    CONSTRAINT truck_owner_type_check CHECK ((owner_type = ANY (ARRAY['BINGO'::text, 'EXTERNAL'::text, 'SUBCONTRACTOR'::text]))),
    CONSTRAINT truck_status_check CHECK ((status = ANY (ARRAY['OK'::text, 'INACTIVE'::text, 'MECHANICAL_ISSUE'::text, 'OTHER_ISSUE'::text]))),
    CONSTRAINT truck_transmission_check CHECK ((transmission = ANY (ARRAY['AUTOMATIC'::text, 'MANUAL'::text]))),
    CONSTRAINT truck_weight_limit_type_check CHECK ((weight_limit_type = ANY (ARRAY['GML'::text, 'CML'::text, 'HML'::text])))
);


ALTER TABLE public.truck OWNER TO skeep;

--
-- Name: COLUMN truck.capacity_cap; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.truck.capacity_cap IS 'Maximum carrying capacity in m³';


--
-- Name: COLUMN truck.tare; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.truck.tare IS 'Weight of unloaded truck in kilograms';


--
-- Name: COLUMN truck.length; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.truck.length IS 'in metres';


--
-- Name: COLUMN truck.width; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.truck.width IS 'in metres';


--
-- Name: COLUMN truck.height; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.truck.height IS 'in metres';


--
-- Name: COLUMN truck.turning_circle_radius; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.truck.turning_circle_radius IS 'in metres';


--
-- Name: COLUMN truck.wheel_base; Type: COMMENT; Schema: public; Owner: skeep
--

COMMENT ON COLUMN public.truck.wheel_base IS 'in metres';


--
-- Name: truck_group; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.truck_group (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.truck_group OWNER TO skeep;

--
-- Name: truck_group_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.truck_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.truck_group_id_seq OWNER TO skeep;

--
-- Name: truck_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.truck_group_id_seq OWNED BY public.truck_group.id;


--
-- Name: truck_group_trucks; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.truck_group_trucks (
    truck_group_id bigint NOT NULL,
    truck_id bigint NOT NULL
);


ALTER TABLE public.truck_group_trucks OWNER TO skeep;

--
-- Name: truck_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.truck_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.truck_id_seq OWNER TO skeep;

--
-- Name: truck_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.truck_id_seq OWNED BY public.truck.id;


--
-- Name: truck_inspection; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.truck_inspection (
    id bigint NOT NULL,
    truck_id bigint NOT NULL,
    created_at timestamp(0) with time zone DEFAULT now() NOT NULL,
    mileage integer,
    fuel_amount_added numeric(12,4),
    type text DEFAULT 'START'::text NOT NULL,
    location public.geography(Point,4326),
    mileage_exception_reason character varying(255),
    depot_id bigint,
    driver_id bigint,
    CONSTRAINT truck_inspection_type_check CHECK ((type = ANY (ARRAY['START'::text, 'SHUTDOWN'::text, 'FUEL_ADDED'::text, 'BROKEN_DOWN'::text])))
);


ALTER TABLE public.truck_inspection OWNER TO skeep;

--
-- Name: truck_inspection_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.truck_inspection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.truck_inspection_id_seq OWNER TO skeep;

--
-- Name: truck_inspection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.truck_inspection_id_seq OWNED BY public.truck_inspection.id;


--
-- Name: truck_issue; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.truck_issue (
    id bigint NOT NULL,
    truck_id bigint NOT NULL,
    status text DEFAULT 'OPEN'::text NOT NULL,
    created_from_truck_inspection_key character varying(255),
    created_at timestamp(0) with time zone DEFAULT now() NOT NULL,
    CONSTRAINT truck_issue_status_check CHECK ((status = ANY (ARRAY['OPEN'::text, 'RESOLVED'::text])))
);


ALTER TABLE public.truck_issue OWNER TO skeep;

--
-- Name: truck_issue_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.truck_issue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.truck_issue_id_seq OWNER TO skeep;

--
-- Name: truck_issue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.truck_issue_id_seq OWNED BY public.truck_issue.id;


--
-- Name: truck_issue_reference; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.truck_issue_reference (
    id bigint NOT NULL,
    inspection_id bigint NOT NULL,
    issue_id bigint NOT NULL,
    reference_type text NOT NULL,
    notes text,
    CONSTRAINT truck_issue_reference_reference_type_check CHECK ((reference_type = ANY (ARRAY['CREATED_BY_INSPECTION'::text, 'MENTIONED_ON_INSPECTION'::text, 'RESOLVED_BY_INSPECTION'::text])))
);


ALTER TABLE public.truck_issue_reference OWNER TO skeep;

--
-- Name: truck_issue_reference_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.truck_issue_reference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.truck_issue_reference_id_seq OWNER TO skeep;

--
-- Name: truck_issue_reference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.truck_issue_reference_id_seq OWNED BY public.truck_issue_reference.id;


--
-- Name: user_preference; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.user_preference (
    id bigint NOT NULL,
    user_email character varying(255) NOT NULL,
    client text NOT NULL,
    preferences jsonb NOT NULL,
    CONSTRAINT user_preference_client_check CHECK ((client = ANY (ARRAY['WEB'::text, 'APP'::text])))
);


ALTER TABLE public.user_preference OWNER TO skeep;

--
-- Name: user_preference_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.user_preference_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_preference_id_seq OWNER TO skeep;

--
-- Name: user_preference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.user_preference_id_seq OWNED BY public.user_preference.id;


--
-- Name: vehicle_type; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.vehicle_type (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    max_length numeric(10,2) NOT NULL,
    gross_vehicle_mass numeric(10,2) NOT NULL,
    general_mass_limit numeric(10,2) NOT NULL,
    concessional_mass_limit numeric(10,2),
    higher_mass_limit numeric(10,2)
);


ALTER TABLE public.vehicle_type OWNER TO skeep;

--
-- Name: vehicle_type_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.vehicle_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vehicle_type_id_seq OWNER TO skeep;

--
-- Name: vehicle_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.vehicle_type_id_seq OWNED BY public.vehicle_type.id;


--
-- Name: weighbridge_weight_log; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.weighbridge_weight_log (
    id bigint NOT NULL,
    created_by character varying(255) NOT NULL,
    created_at timestamp(0) with time zone NOT NULL,
    gross_weight numeric(12,4) NOT NULL,
    tare_weight numeric(12,4) NOT NULL,
    tip_ticket_id bigint,
    log_reason text NOT NULL,
    stored_tare_information jsonb,
    CONSTRAINT log_reason_check CHECK ((log_reason = ANY (ARRAY['CHANGE_VISIT_PURPOSE'::text, 'SET_GROSS_WEIGHT_SCALES'::text, 'SET_TARE_WEIGHT_SCALES'::text, 'SET_GROSS_WEIGHT_MANUAL'::text, 'SET_TARE_WEIGHT_MANUAL'::text, 'SET_TARE_WEIGHT_STORED_FROM_TRUCK'::text, 'SET_TARE_WEIGHT_STORED_FROM_BIN_CHANGE'::text])))
);


ALTER TABLE public.weighbridge_weight_log OWNER TO skeep;

--
-- Name: weighbridge_weight_log_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.weighbridge_weight_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.weighbridge_weight_log_id_seq OWNER TO skeep;

--
-- Name: weighbridge_weight_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.weighbridge_weight_log_id_seq OWNED BY public.weighbridge_weight_log.id;


--
-- Name: work_allocation; Type: TABLE; Schema: public; Owner: skeep
--

CREATE TABLE public.work_allocation (
    id bigint NOT NULL,
    driver_truck_allocation_id bigint NOT NULL,
    job_id bigint,
    runsheet_id bigint,
    ordering double precision NOT NULL,
    CONSTRAINT work_allocation_cannot_refer_to_both_job_and_runsheet CHECK ((NOT ((job_id IS NOT NULL) AND (runsheet_id IS NOT NULL)))),
    CONSTRAINT work_allocation_must_refer_to_job_or_runsheet CHECK ((NOT ((job_id IS NULL) AND (runsheet_id IS NULL))))
);


ALTER TABLE public.work_allocation OWNER TO skeep;

--
-- Name: work_allocation_id_seq; Type: SEQUENCE; Schema: public; Owner: skeep
--

CREATE SEQUENCE public.work_allocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.work_allocation_id_seq OWNER TO skeep;

--
-- Name: work_allocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: skeep
--

ALTER SEQUENCE public.work_allocation_id_seq OWNED BY public.work_allocation.id;


--
-- Name: absence id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.absence ALTER COLUMN id SET DEFAULT nextval('public.absence_id_seq'::regclass);


--
-- Name: allowed_truck id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.allowed_truck ALTER COLUMN id SET DEFAULT nextval('public.allowed_truck_id_seq'::regclass);


--
-- Name: associated_product id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.associated_product ALTER COLUMN id SET DEFAULT nextval('public.associated_product_id_seq'::regclass);


--
-- Name: audit_change id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.audit_change ALTER COLUMN id SET DEFAULT nextval('public.audit_change_id_seq'::regclass);


--
-- Name: audit_related_entity_change id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.audit_related_entity_change ALTER COLUMN id SET DEFAULT nextval('public.audit_related_entity_change_id_seq'::regclass);


--
-- Name: auth_okta_group_role id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.auth_okta_group_role ALTER COLUMN id SET DEFAULT nextval('public.auth_okta_group_role_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: bin_image id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bin_image ALTER COLUMN id SET DEFAULT nextval('public.bin_image_id_seq'::regclass);


--
-- Name: bin_record id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bin_record ALTER COLUMN id SET DEFAULT nextval('public.bin_serial_number_id_seq'::regclass);


--
-- Name: bins_on_site id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bins_on_site ALTER COLUMN id SET DEFAULT nextval('public.bins_on_site_id_seq'::regclass);


--
-- Name: bins_on_site_adjustment id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bins_on_site_adjustment ALTER COLUMN id SET DEFAULT nextval('public.bins_on_site_adjustment_id_seq'::regclass);


--
-- Name: business_unit id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit ALTER COLUMN id SET DEFAULT nextval('public.business_unit_id_seq'::regclass);


--
-- Name: business_unit_tag id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_tag ALTER COLUMN id SET DEFAULT nextval('public.business_unit_tag_id_seq'::regclass);


--
-- Name: compatible_truck_license id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.compatible_truck_license ALTER COLUMN id SET DEFAULT nextval('public.compatible_truck_license_id_seq'::regclass);


--
-- Name: completed_bin_service id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.completed_bin_service ALTER COLUMN id SET DEFAULT nextval('public.completed_bin_service_id_seq'::regclass);


--
-- Name: council_permit id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.council_permit ALTER COLUMN id SET DEFAULT nextval('public.council_permit_id_seq'::regclass);


--
-- Name: crm_event id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.crm_event ALTER COLUMN id SET DEFAULT nextval('public.crm_event_id_seq'::regclass);


--
-- Name: delivery_docket_email_item id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.delivery_docket_email_item ALTER COLUMN id SET DEFAULT nextval('public.delivery_docket_email_item_id_seq'::regclass);


--
-- Name: depot id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.depot ALTER COLUMN id SET DEFAULT nextval('public.depot_id_seq'::regclass);


--
-- Name: driver id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver ALTER COLUMN id SET DEFAULT nextval('public.driver_id_seq'::regclass);


--
-- Name: driver_license id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_license ALTER COLUMN id SET DEFAULT nextval('public.driver_license_id_seq'::regclass);


--
-- Name: driver_trained_service_types id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_trained_service_types ALTER COLUMN id SET DEFAULT nextval('public.driver_trained_service_types_id_seq'::regclass);


--
-- Name: driver_truck_allocation id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_truck_allocation ALTER COLUMN id SET DEFAULT nextval('public.driver_truck_allocation_id_seq'::regclass);


--
-- Name: heartbeat id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.heartbeat ALTER COLUMN id SET DEFAULT nextval('public.heartbeat_id_seq'::regclass);


--
-- Name: internal_metadata id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.internal_metadata ALTER COLUMN id SET DEFAULT nextval('public.internal_metadata_id_seq'::regclass);


--
-- Name: job id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job ALTER COLUMN id SET DEFAULT nextval('public.job_id_seq'::regclass);


--
-- Name: job_attempt id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_attempt ALTER COLUMN id SET DEFAULT nextval('public.job_attempt_id_seq'::regclass);


--
-- Name: job_permit id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_permit ALTER COLUMN id SET DEFAULT nextval('public.job_permit_id_seq'::regclass);


--
-- Name: job_photo_collection id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_photo_collection ALTER COLUMN id SET DEFAULT nextval('public.job_photo_collection_id_seq'::regclass);


--
-- Name: job_sms_log id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_sms_log ALTER COLUMN id SET DEFAULT nextval('public.job_sms_log_id_seq'::regclass);


--
-- Name: license_type id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.license_type ALTER COLUMN id SET DEFAULT nextval('public.license_type_id_seq'::regclass);


--
-- Name: migration id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.migration ALTER COLUMN id SET DEFAULT nextval('public.migration_id_seq'::regclass);


--
-- Name: mybingo_announcement id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_announcement ALTER COLUMN id SET DEFAULT nextval('public.mybingo_announcement_id_seq'::regclass);


--
-- Name: mybingo_document id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_document ALTER COLUMN id SET DEFAULT nextval('public.mybingo_document_id_seq'::regclass);


--
-- Name: mybingo_email_type id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_email_type ALTER COLUMN id SET DEFAULT nextval('public.mybingo_email_type_id_seq'::regclass);


--
-- Name: mybingo_information_type id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_information_type ALTER COLUMN id SET DEFAULT nextval('public.mybingo_information_type_id_seq'::regclass);


--
-- Name: mybingo_invoice_payment id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_invoice_payment ALTER COLUMN id SET DEFAULT nextval('public.invoice_payment_id_seq'::regclass);


--
-- Name: mybingo_notification id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_notification ALTER COLUMN id SET DEFAULT nextval('public.mybingo_notification_id_seq'::regclass);


--
-- Name: mybingo_order_blocked_time_slot id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_blocked_time_slot ALTER COLUMN id SET DEFAULT nextval('public.mybingo_order_blocked_time_slot_id_seq'::regclass);


--
-- Name: mybingo_order_cut_off_time id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_cut_off_time ALTER COLUMN id SET DEFAULT nextval('public.mybingo_order_cut_off_time_id_seq'::regclass);


--
-- Name: mybingo_order_cut_off_time_time_slot id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_cut_off_time_time_slot ALTER COLUMN id SET DEFAULT nextval('public.mybingo_order_cut_off_time_time_slot_id_seq'::regclass);


--
-- Name: mybingo_order_time_slot id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_time_slot ALTER COLUMN id SET DEFAULT nextval('public.mybingo_order_time_slot_id_seq'::regclass);


--
-- Name: mybingo_permission id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_permission ALTER COLUMN id SET DEFAULT nextval('public.mybingo_permission_id_seq'::regclass);


--
-- Name: mybingo_request id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_request ALTER COLUMN id SET DEFAULT nextval('public.mybingo_request_id_seq'::regclass);


--
-- Name: mybingo_request_type id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_request_type ALTER COLUMN id SET DEFAULT nextval('public.mybingo_request_type_id_seq'::regclass);


--
-- Name: mybingo_role_permission id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_role_permission ALTER COLUMN id SET DEFAULT nextval('public.mybingo_role_permission_id_seq'::regclass);


--
-- Name: mybingo_system_document id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_system_document ALTER COLUMN id SET DEFAULT nextval('public.mybingo_system_document_id_seq'::regclass);


--
-- Name: mybingo_user id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user ALTER COLUMN id SET DEFAULT nextval('public.mybingo_user_id_seq'::regclass);


--
-- Name: mybingo_user_account_favourite id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_account_favourite ALTER COLUMN id SET DEFAULT nextval('public.mybingo_user_account_favourite_id_seq'::regclass);


--
-- Name: mybingo_user_business_account_mapping id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_business_account_mapping ALTER COLUMN id SET DEFAULT nextval('public.mybingo_user_business_account_mapping_id_seq'::regclass);


--
-- Name: mybingo_user_notification id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_notification ALTER COLUMN id SET DEFAULT nextval('public.mybingo_user_notification_id_seq'::regclass);


--
-- Name: mybingo_user_site_favourite id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_site_favourite ALTER COLUMN id SET DEFAULT nextval('public.mybingo_user_site_favourite_id_seq'::regclass);


--
-- Name: mybingo_user_site_mapping id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_site_mapping ALTER COLUMN id SET DEFAULT nextval('public.mybingo_user_site_mapping_id_seq'::regclass);


--
-- Name: notification id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.notification ALTER COLUMN id SET DEFAULT nextval('public.notification_id_seq'::regclass);


--
-- Name: order id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public."order" ALTER COLUMN id SET DEFAULT nextval('public.order_id_seq'::regclass);


--
-- Name: order_line id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.order_line ALTER COLUMN id SET DEFAULT nextval('public.order_line_id_seq'::regclass);


--
-- Name: payment id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.payment ALTER COLUMN id SET DEFAULT nextval('public.payment_id_seq'::regclass);


--
-- Name: photo id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.photo ALTER COLUMN id SET DEFAULT nextval('public.photo_id_seq'::regclass);


--
-- Name: public_holiday id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.public_holiday ALTER COLUMN id SET DEFAULT nextval('public.public_holiday_id_seq'::regclass);


--
-- Name: region id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.region ALTER COLUMN id SET DEFAULT nextval('public.region_id_seq'::regclass);


--
-- Name: roster_entry id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.roster_entry ALTER COLUMN id SET DEFAULT nextval('public.roster_entry_id_seq'::regclass);


--
-- Name: runsheet id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet ALTER COLUMN id SET DEFAULT nextval('public.runsheet_id_seq'::regclass);


--
-- Name: runsheet_job_ordering id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_job_ordering ALTER COLUMN id SET DEFAULT nextval('public.runsheet_job_ordering_id_seq'::regclass);


--
-- Name: runsheet_template id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_template ALTER COLUMN id SET DEFAULT nextval('public.runsheet_template_id_seq'::regclass);


--
-- Name: service_agreement_line_ordering id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.service_agreement_line_ordering ALTER COLUMN id SET DEFAULT nextval('public.service_line_item_ordering_id_seq'::regclass);


--
-- Name: shift id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift ALTER COLUMN id SET DEFAULT nextval('public.shift_id_seq'::regclass);


--
-- Name: shift_break id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift_break ALTER COLUMN id SET DEFAULT nextval('public.shift_break_id_seq'::regclass);


--
-- Name: site_driver_note id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_driver_note ALTER COLUMN id SET DEFAULT nextval('public.site_driver_note_id_seq'::regclass);


--
-- Name: site_location_point id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_location_point ALTER COLUMN id SET DEFAULT nextval('public.site_location_point_id_seq'::regclass);


--
-- Name: site_preferred_driver id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_preferred_driver ALTER COLUMN id SET DEFAULT nextval('public.site_preferred_driver_id_seq'::regclass);


--
-- Name: stored_card id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.stored_card ALTER COLUMN id SET DEFAULT nextval('public.stored_card_id_seq'::regclass);


--
-- Name: subscription id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.subscription ALTER COLUMN id SET DEFAULT nextval('public.subscription_id_seq'::regclass);


--
-- Name: system_config id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.system_config ALTER COLUMN id SET DEFAULT nextval('public.system_config_id_seq'::regclass);


--
-- Name: time_window id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.time_window ALTER COLUMN id SET DEFAULT nextval('public.time_window_id_seq'::regclass);


--
-- Name: tip_site id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site ALTER COLUMN id SET DEFAULT nextval('public.tip_site_id_seq'::regclass);


--
-- Name: tip_site_location_on_site_epl tip_site_id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site_location_on_site_epl ALTER COLUMN tip_site_id SET DEFAULT nextval('public.tip_site_location_on_site_epl_tip_site_id_seq'::regclass);


--
-- Name: tip_site_waste_stockpile id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site_waste_stockpile ALTER COLUMN id SET DEFAULT nextval('public.tip_site_waste_stockpile_id_seq'::regclass);


--
-- Name: tip_summary id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary ALTER COLUMN id SET DEFAULT nextval('public.tip_summary_id_seq'::regclass);


--
-- Name: tip_summary_waste_breakdown id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary_waste_breakdown ALTER COLUMN id SET DEFAULT nextval('public.job_waste_breakdown_id_seq'::regclass);


--
-- Name: tip_ticket id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_ticket ALTER COLUMN id SET DEFAULT nextval('public.tip_ticket_id_seq'::regclass);


--
-- Name: transfer_job id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.transfer_job ALTER COLUMN id SET DEFAULT nextval('public.transfer_job_id_seq'::regclass);


--
-- Name: truck id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck ALTER COLUMN id SET DEFAULT nextval('public.truck_id_seq'::regclass);


--
-- Name: truck_group id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_group ALTER COLUMN id SET DEFAULT nextval('public.truck_group_id_seq'::regclass);


--
-- Name: truck_inspection id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_inspection ALTER COLUMN id SET DEFAULT nextval('public.truck_inspection_id_seq'::regclass);


--
-- Name: truck_issue id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_issue ALTER COLUMN id SET DEFAULT nextval('public.truck_issue_id_seq'::regclass);


--
-- Name: truck_issue_reference id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_issue_reference ALTER COLUMN id SET DEFAULT nextval('public.truck_issue_reference_id_seq'::regclass);


--
-- Name: user_preference id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.user_preference ALTER COLUMN id SET DEFAULT nextval('public.user_preference_id_seq'::regclass);


--
-- Name: vehicle_type id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.vehicle_type ALTER COLUMN id SET DEFAULT nextval('public.vehicle_type_id_seq'::regclass);


--
-- Name: weighbridge_weight_log id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.weighbridge_weight_log ALTER COLUMN id SET DEFAULT nextval('public.weighbridge_weight_log_id_seq'::regclass);


--
-- Name: work_allocation id; Type: DEFAULT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.work_allocation ALTER COLUMN id SET DEFAULT nextval('public.work_allocation_id_seq'::regclass);


--
-- Name: absence absence_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.absence
    ADD CONSTRAINT absence_pkey PRIMARY KEY (id);


--
-- Name: allowed_truck allowed_truck_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.allowed_truck
    ADD CONSTRAINT allowed_truck_pkey PRIMARY KEY (id);


--
-- Name: associated_product associated_product_matching_tag_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.associated_product
    ADD CONSTRAINT associated_product_matching_tag_key UNIQUE (matching_tag);


--
-- Name: associated_product associated_product_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.associated_product
    ADD CONSTRAINT associated_product_pkey PRIMARY KEY (id);


--
-- Name: audit_change audit_change_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.audit_change
    ADD CONSTRAINT audit_change_pkey PRIMARY KEY (id);


--
-- Name: audit_related_entity_change audit_related_entity_change_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.audit_related_entity_change
    ADD CONSTRAINT audit_related_entity_change_pkey PRIMARY KEY (id);


--
-- Name: auth_okta_group_role auth_okta_group_role_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.auth_okta_group_role
    ADD CONSTRAINT auth_okta_group_role_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_name_unique; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_name_unique UNIQUE (name);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: bin_image bin_image_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bin_image
    ADD CONSTRAINT bin_image_pkey PRIMARY KEY (id);


--
-- Name: bin_record bin_serial_number_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bin_record
    ADD CONSTRAINT bin_serial_number_pkey PRIMARY KEY (id);


--
-- Name: bins_on_site_adjustment bins_on_site_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bins_on_site_adjustment
    ADD CONSTRAINT bins_on_site_adjustment_pkey PRIMARY KEY (id);


--
-- Name: bins_on_site bins_on_site_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bins_on_site
    ADD CONSTRAINT bins_on_site_pkey PRIMARY KEY (id);


--
-- Name: business_unit_assigned_tip_sites business_unit_assigned_tip_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_assigned_tip_sites
    ADD CONSTRAINT business_unit_assigned_tip_sites_pkey PRIMARY KEY (business_unit_id, tip_site_id);


--
-- Name: business_unit_assigned_trucks business_unit_assigned_trucks_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_assigned_trucks
    ADD CONSTRAINT business_unit_assigned_trucks_pkey PRIMARY KEY (business_unit_id, truck_id);


--
-- Name: business_unit business_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit
    ADD CONSTRAINT business_unit_pkey PRIMARY KEY (id);


--
-- Name: business_unit_tag_business_units business_unit_tag_business_units_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_tag_business_units
    ADD CONSTRAINT business_unit_tag_business_units_pkey PRIMARY KEY (business_unit_tag_id, business_unit_id);


--
-- Name: business_unit_tag business_unit_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_tag
    ADD CONSTRAINT business_unit_tag_pkey PRIMARY KEY (id);


--
-- Name: business_unit_tags business_unit_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_tags
    ADD CONSTRAINT business_unit_tags_pkey PRIMARY KEY (business_unit_id, business_unit_tag_id);


--
-- Name: compatible_truck_license compatible_truck_license_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.compatible_truck_license
    ADD CONSTRAINT compatible_truck_license_pkey PRIMARY KEY (id);


--
-- Name: completed_bin_service completed_bin_service_matching_tag_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.completed_bin_service
    ADD CONSTRAINT completed_bin_service_matching_tag_key UNIQUE (matching_tag);


--
-- Name: completed_bin_service completed_bin_service_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.completed_bin_service
    ADD CONSTRAINT completed_bin_service_pkey PRIMARY KEY (id);


--
-- Name: council_permit council_permit_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.council_permit
    ADD CONSTRAINT council_permit_pkey PRIMARY KEY (id);


--
-- Name: crm_event crm_event_event_id_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.crm_event
    ADD CONSTRAINT crm_event_event_id_key UNIQUE (event_id);


--
-- Name: crm_event crm_event_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.crm_event
    ADD CONSTRAINT crm_event_pkey PRIMARY KEY (id);


--
-- Name: order_line crm_sales_order_detail_id_unique; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT crm_sales_order_detail_id_unique UNIQUE (crm_sales_order_detail_id);


--
-- Name: order crm_sales_order_id_unique; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT crm_sales_order_id_unique UNIQUE (crm_sales_order_id);


--
-- Name: delivery_docket_email_item delivery_docket_email_item_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.delivery_docket_email_item
    ADD CONSTRAINT delivery_docket_email_item_pkey PRIMARY KEY (id);


--
-- Name: depot depot_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.depot
    ADD CONSTRAINT depot_pkey PRIMARY KEY (id);


--
-- Name: driver_assigned_to_regions driver_assigned_to_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_assigned_to_regions
    ADD CONSTRAINT driver_assigned_to_regions_pkey PRIMARY KEY (driver_id, region_id);


--
-- Name: driver_license driver_license_number_unique; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_license
    ADD CONSTRAINT driver_license_number_unique UNIQUE (licence_number);


--
-- Name: driver_license driver_license_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_license
    ADD CONSTRAINT driver_license_pkey PRIMARY KEY (id);


--
-- Name: driver driver_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_pkey PRIMARY KEY (id);


--
-- Name: driver_trained_service_types driver_trained_service_types_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_trained_service_types
    ADD CONSTRAINT driver_trained_service_types_pkey PRIMARY KEY (id);


--
-- Name: driver_truck_allocation driver_truck_allocation_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_truck_allocation
    ADD CONSTRAINT driver_truck_allocation_pkey PRIMARY KEY (id);


--
-- Name: driver driver_unique_email; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_unique_email UNIQUE (email);


--
-- Name: heartbeat heartbeat_first_name_last_name_path_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.heartbeat
    ADD CONSTRAINT heartbeat_first_name_last_name_path_key UNIQUE (first_name, last_name, path);


--
-- Name: heartbeat heartbeat_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.heartbeat
    ADD CONSTRAINT heartbeat_pkey PRIMARY KEY (id);


--
-- Name: internal_metadata internal_metadata_key_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.internal_metadata
    ADD CONSTRAINT internal_metadata_key_key UNIQUE (key);


--
-- Name: internal_metadata internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.internal_metadata
    ADD CONSTRAINT internal_metadata_pkey PRIMARY KEY (id);


--
-- Name: mybingo_invoice_payment invoice_payment_crm_invoice_id_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_invoice_payment
    ADD CONSTRAINT invoice_payment_crm_invoice_id_key UNIQUE (crm_invoice_id);


--
-- Name: mybingo_invoice_payment invoice_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_invoice_payment
    ADD CONSTRAINT invoice_payment_pkey PRIMARY KEY (id);


--
-- Name: job_attempt job_attempt_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_attempt
    ADD CONSTRAINT job_attempt_pkey PRIMARY KEY (id);


--
-- Name: job_permit job_permit_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_permit
    ADD CONSTRAINT job_permit_pkey PRIMARY KEY (id);


--
-- Name: job_photo_collection job_photo_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_photo_collection
    ADD CONSTRAINT job_photo_collection_pkey PRIMARY KEY (id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: job_sms_log job_sms_log_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_sms_log
    ADD CONSTRAINT job_sms_log_pkey PRIMARY KEY (id);


--
-- Name: tip_summary_waste_breakdown job_waste_breakdown_job_id_waste_type_id_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary_waste_breakdown
    ADD CONSTRAINT job_waste_breakdown_job_id_waste_type_id_key UNIQUE (job_id, waste_type_id);


--
-- Name: tip_summary_waste_breakdown job_waste_breakdown_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary_waste_breakdown
    ADD CONSTRAINT job_waste_breakdown_pkey PRIMARY KEY (id);


--
-- Name: license_type license_type_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.license_type
    ADD CONSTRAINT license_type_pkey PRIMARY KEY (id);


--
-- Name: migration migration_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.migration
    ADD CONSTRAINT migration_pkey PRIMARY KEY (id);


--
-- Name: mybingo_announcement mybingo_announcement_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_announcement
    ADD CONSTRAINT mybingo_announcement_pkey PRIMARY KEY (id);


--
-- Name: mybingo_document mybingo_document_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_document
    ADD CONSTRAINT mybingo_document_pkey PRIMARY KEY (id);


--
-- Name: mybingo_email_type mybingo_email_type_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_email_type
    ADD CONSTRAINT mybingo_email_type_pkey PRIMARY KEY (id);


--
-- Name: mybingo_information_type mybingo_information_type_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_information_type
    ADD CONSTRAINT mybingo_information_type_pkey PRIMARY KEY (id);


--
-- Name: mybingo_notification mybingo_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_notification
    ADD CONSTRAINT mybingo_notification_pkey PRIMARY KEY (id);


--
-- Name: mybingo_order_blocked_time_slot mybingo_order_blocked_time_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_blocked_time_slot
    ADD CONSTRAINT mybingo_order_blocked_time_slot_pkey PRIMARY KEY (id);


--
-- Name: mybingo_order_cut_off_time mybingo_order_cut_off_time_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_cut_off_time
    ADD CONSTRAINT mybingo_order_cut_off_time_pkey PRIMARY KEY (id);


--
-- Name: mybingo_order_cut_off_time_time_slot mybingo_order_cut_off_time_time_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_cut_off_time_time_slot
    ADD CONSTRAINT mybingo_order_cut_off_time_time_slot_pkey PRIMARY KEY (id);


--
-- Name: mybingo_order_time_slot mybingo_order_time_slot_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_time_slot
    ADD CONSTRAINT mybingo_order_time_slot_pkey PRIMARY KEY (id);


--
-- Name: mybingo_permission mybingo_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_permission
    ADD CONSTRAINT mybingo_permission_pkey PRIMARY KEY (id);


--
-- Name: mybingo_request mybingo_request_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_request
    ADD CONSTRAINT mybingo_request_pkey PRIMARY KEY (id);


--
-- Name: mybingo_request_type mybingo_request_type_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_request_type
    ADD CONSTRAINT mybingo_request_type_pkey PRIMARY KEY (id);


--
-- Name: mybingo_role_permission mybingo_role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_role_permission
    ADD CONSTRAINT mybingo_role_permission_pkey PRIMARY KEY (id);


--
-- Name: mybingo_system_document mybingo_system_document_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_system_document
    ADD CONSTRAINT mybingo_system_document_pkey PRIMARY KEY (id);


--
-- Name: mybingo_user_account_favourite mybingo_user_account_favourite_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_account_favourite
    ADD CONSTRAINT mybingo_user_account_favourite_pkey PRIMARY KEY (id);


--
-- Name: mybingo_user_business_account_mapping mybingo_user_business_account_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_business_account_mapping
    ADD CONSTRAINT mybingo_user_business_account_mapping_pkey PRIMARY KEY (id);


--
-- Name: mybingo_user_notification mybingo_user_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_notification
    ADD CONSTRAINT mybingo_user_notification_pkey PRIMARY KEY (id);


--
-- Name: mybingo_user mybingo_user_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user
    ADD CONSTRAINT mybingo_user_pkey PRIMARY KEY (id);


--
-- Name: mybingo_user_site_favourite mybingo_user_site_favourite_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_site_favourite
    ADD CONSTRAINT mybingo_user_site_favourite_pkey PRIMARY KEY (id);


--
-- Name: mybingo_user_site_mapping mybingo_user_site_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_site_mapping
    ADD CONSTRAINT mybingo_user_site_mapping_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: order_line order_line_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT order_line_pkey PRIMARY KEY (id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: photo photo_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (id);


--
-- Name: public_holiday public_holiday_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.public_holiday
    ADD CONSTRAINT public_holiday_pkey PRIMARY KEY (id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: roster_entry roster_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.roster_entry
    ADD CONSTRAINT roster_entry_pkey PRIMARY KEY (id);


--
-- Name: runsheet_job_ordering runsheet_job_ordering_job_id_unique; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_job_ordering
    ADD CONSTRAINT runsheet_job_ordering_job_id_unique UNIQUE (job_id);


--
-- Name: runsheet_job_ordering runsheet_job_ordering_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_job_ordering
    ADD CONSTRAINT runsheet_job_ordering_pkey PRIMARY KEY (id);


--
-- Name: runsheet runsheet_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet
    ADD CONSTRAINT runsheet_pkey PRIMARY KEY (id);


--
-- Name: runsheet_template runsheet_template_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_template
    ADD CONSTRAINT runsheet_template_pkey PRIMARY KEY (id);


--
-- Name: runsheet_template_preferred_tip_sites runsheet_template_preferred_tip_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_template_preferred_tip_sites
    ADD CONSTRAINT runsheet_template_preferred_tip_sites_pkey PRIMARY KEY (runsheet_template_id, tip_site_id);


--
-- Name: service_agreement_line_ordering service_line_item_ordering_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.service_agreement_line_ordering
    ADD CONSTRAINT service_line_item_ordering_pkey PRIMARY KEY (id);


--
-- Name: shift_break shift_break_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift_break
    ADD CONSTRAINT shift_break_pkey PRIMARY KEY (id);


--
-- Name: shift shift_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT shift_pkey PRIMARY KEY (id);


--
-- Name: site_driver_note site_driver_note_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_driver_note
    ADD CONSTRAINT site_driver_note_pkey PRIMARY KEY (id);


--
-- Name: site_location_point site_location_point_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_location_point
    ADD CONSTRAINT site_location_point_pkey PRIMARY KEY (id);


--
-- Name: site_preferred_driver site_preferred_driver_crm_site_location_id_driver_id_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_preferred_driver
    ADD CONSTRAINT site_preferred_driver_crm_site_location_id_driver_id_key UNIQUE (crm_site_location_id, driver_id);


--
-- Name: site_preferred_driver site_preferred_driver_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_preferred_driver
    ADD CONSTRAINT site_preferred_driver_pkey PRIMARY KEY (id);


--
-- Name: stored_card stored_card_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.stored_card
    ADD CONSTRAINT stored_card_pkey PRIMARY KEY (id);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (id);


--
-- Name: subscription subscription_topic_email_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_topic_email_key UNIQUE (topic, email);


--
-- Name: system_config system_config_key_key; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.system_config
    ADD CONSTRAINT system_config_key_key UNIQUE (key);


--
-- Name: system_config system_config_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.system_config
    ADD CONSTRAINT system_config_pkey PRIMARY KEY (id);


--
-- Name: time_window time_window_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.time_window
    ADD CONSTRAINT time_window_pkey PRIMARY KEY (id);


--
-- Name: tip_site tip_site_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site
    ADD CONSTRAINT tip_site_pkey PRIMARY KEY (id);


--
-- Name: tip_site_waste_stockpile tip_site_waste_stockpile_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site_waste_stockpile
    ADD CONSTRAINT tip_site_waste_stockpile_pkey PRIMARY KEY (id);


--
-- Name: tip_summary tip_summary_contaminated_photo_id_unique; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary
    ADD CONSTRAINT tip_summary_contaminated_photo_id_unique UNIQUE (contaminated_photo_id);


--
-- Name: tip_summary tip_summary_docket_photo_id_unique; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary
    ADD CONSTRAINT tip_summary_docket_photo_id_unique UNIQUE (docket_photo_id);


--
-- Name: tip_summary tip_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary
    ADD CONSTRAINT tip_summary_pkey PRIMARY KEY (id);


--
-- Name: tip_ticket tip_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_ticket
    ADD CONSTRAINT tip_ticket_pkey PRIMARY KEY (id);


--
-- Name: transfer_job transfer_job_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.transfer_job
    ADD CONSTRAINT transfer_job_pkey PRIMARY KEY (id);


--
-- Name: truck_group truck_group_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_group
    ADD CONSTRAINT truck_group_pkey PRIMARY KEY (id);


--
-- Name: truck_group_trucks truck_group_trucks_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_group_trucks
    ADD CONSTRAINT truck_group_trucks_pkey PRIMARY KEY (truck_group_id, truck_id);


--
-- Name: truck_inspection truck_inspection_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_inspection
    ADD CONSTRAINT truck_inspection_pkey PRIMARY KEY (id);


--
-- Name: truck_issue truck_issue_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_issue
    ADD CONSTRAINT truck_issue_pkey PRIMARY KEY (id);


--
-- Name: truck_issue_reference truck_issue_reference_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_issue_reference
    ADD CONSTRAINT truck_issue_reference_pkey PRIMARY KEY (id);


--
-- Name: truck truck_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck
    ADD CONSTRAINT truck_pkey PRIMARY KEY (id);


--
-- Name: shift unique_scheduled_end; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT unique_scheduled_end UNIQUE (driver_id, scheduled_end);


--
-- Name: shift unique_scheduled_start; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT unique_scheduled_start UNIQUE (driver_id, scheduled_start);


--
-- Name: user_preference user_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.user_preference
    ADD CONSTRAINT user_preference_pkey PRIMARY KEY (id);


--
-- Name: vehicle_type vehicle_type_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.vehicle_type
    ADD CONSTRAINT vehicle_type_pkey PRIMARY KEY (id);


--
-- Name: weighbridge_weight_log weighbridge_weight_log_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.weighbridge_weight_log
    ADD CONSTRAINT weighbridge_weight_log_pkey PRIMARY KEY (id);


--
-- Name: work_allocation work_allocation_pkey; Type: CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.work_allocation
    ADD CONSTRAINT work_allocation_pkey PRIMARY KEY (id);


--
-- Name: audit_change_entity_type_entity_id_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX audit_change_entity_type_entity_id_index ON public.audit_change USING btree (entity_type, entity_id);


--
-- Name: audit_related_entity_change_related_entity_type_related_entity_; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX audit_related_entity_change_related_entity_type_related_entity_ ON public.audit_related_entity_change USING btree (related_entity_type, related_entity_id);


--
-- Name: bins_on_site_delivery_on_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX bins_on_site_delivery_on_index ON public.bins_on_site USING btree (delivery_on);


--
-- Name: bins_on_site_pickup_on_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX bins_on_site_pickup_on_index ON public.bins_on_site USING btree (pickup_on);


--
-- Name: bins_on_site_site_id_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX bins_on_site_site_id_index ON public.bins_on_site USING btree (site_id);


--
-- Name: business_unit_name_key; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX business_unit_name_key ON public.business_unit USING btree (name);


--
-- Name: ci_job_uniqueness_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX ci_job_uniqueness_index ON public.job USING btree (type, initial_allocated_date, crm_service_agreement_line_id) WHERE ((type = 'COLLECT'::text) OR (type = 'DELIVER'::text));


--
-- Name: driver_first_name_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX driver_first_name_index ON public.driver USING btree (first_name);


--
-- Name: driver_last_name_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX driver_last_name_index ON public.driver USING btree (last_name);


--
-- Name: job_waste_breakdown_tip_summary_id_waste_type_id_key; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX job_waste_breakdown_tip_summary_id_waste_type_id_key ON public.tip_summary_waste_breakdown USING btree (tip_summary_id, waste_type_id);


--
-- Name: mybingo_order_blocked_time_slot_date; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX mybingo_order_blocked_time_slot_date ON public.mybingo_order_blocked_time_slot USING btree (date);


--
-- Name: mybingo_order_cut_off_time_cut_off_time_lead_days_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX mybingo_order_cut_off_time_cut_off_time_lead_days_index ON public.mybingo_order_cut_off_time USING btree (cut_off_time, lead_days);


--
-- Name: mybingo_order_cut_off_time_time_slot_cut_off_time_id_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX mybingo_order_cut_off_time_time_slot_cut_off_time_id_index ON public.mybingo_order_cut_off_time_time_slot USING btree (cut_off_time_id);


--
-- Name: order_line_matching_tag_key; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX order_line_matching_tag_key ON public.order_line USING btree (matching_tag) WHERE (mark_for_deletion IS FALSE);


--
-- Name: order_line_order_id_fkey; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX order_line_order_id_fkey ON public.order_line USING btree (order_id);


--
-- Name: public_holiday_date_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX public_holiday_date_index ON public.public_holiday USING btree (date);


--
-- Name: public_holiday_state_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX public_holiday_state_index ON public.public_holiday USING btree (state);


--
-- Name: region_polygon_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX region_polygon_index ON public.region USING gist (polygon);


--
-- Name: runsheet_template_uniqueness_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX runsheet_template_uniqueness_index ON public.runsheet_template USING btree (lower((name)::text), day_of_week, is_sub_contractor, is_night_shift, is_deleted, crm_service_type_id);


--
-- Name: site_location_point_crm_site_location_id_created_at_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX site_location_point_crm_site_location_id_created_at_index ON public.site_location_point USING btree (crm_site_location_id, created_at);


--
-- Name: site_location_point_crm_site_location_id_crm_site_location_vers; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX site_location_point_crm_site_location_id_crm_site_location_vers ON public.site_location_point USING btree (crm_site_location_id, crm_site_location_version_id);


--
-- Name: stored_card_crm_account_id_fingerprint_key; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX stored_card_crm_account_id_fingerprint_key ON public.stored_card USING btree (crm_account_id, fingerprint) WHERE (is_deleted IS FALSE);


--
-- Name: tip_site_location_on_site_epl_tip_site_id_idx; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX tip_site_location_on_site_epl_tip_site_id_idx ON public.tip_site_location_on_site_epl USING btree (tip_site_id, location_on_site);


--
-- Name: truck_issue_created_from_truck_inspection_key_index; Type: INDEX; Schema: public; Owner: skeep
--

CREATE INDEX truck_issue_created_from_truck_inspection_key_index ON public.truck_issue USING btree (created_from_truck_inspection_key);


--
-- Name: unique_job_type_sequence; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX unique_job_type_sequence ON public.bin_record USING btree (job_id, type, sequence);


--
-- Name: unique_product_site_bin_location; Type: INDEX; Schema: public; Owner: skeep
--

CREATE UNIQUE INDEX unique_product_site_bin_location ON public.bins_on_site_adjustment USING btree (crm_product_id, crm_site_location_id, crm_bin_location_id);


--
-- Name: absence absence_driver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.absence
    ADD CONSTRAINT absence_driver_id_foreign FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE;


--
-- Name: allowed_truck allowed_truck_truck_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.allowed_truck
    ADD CONSTRAINT allowed_truck_truck_id_foreign FOREIGN KEY (truck_id) REFERENCES public.truck(id) ON UPDATE CASCADE;


--
-- Name: associated_product associated_product_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.associated_product
    ADD CONSTRAINT associated_product_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: audit_related_entity_change audit_related_entity_change_change_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.audit_related_entity_change
    ADD CONSTRAINT audit_related_entity_change_change_id_foreign FOREIGN KEY (change_id) REFERENCES public.audit_change(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bin_record bin_serial_number_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bin_record
    ADD CONSTRAINT bin_serial_number_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: business_unit_assigned_tip_sites business_unit_assigned_tip_sites_business_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_assigned_tip_sites
    ADD CONSTRAINT business_unit_assigned_tip_sites_business_unit_id_fkey FOREIGN KEY (business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_unit_assigned_tip_sites business_unit_assigned_tip_sites_tip_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_assigned_tip_sites
    ADD CONSTRAINT business_unit_assigned_tip_sites_tip_site_id_fkey FOREIGN KEY (tip_site_id) REFERENCES public.tip_site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_unit_assigned_trucks business_unit_assigned_trucks_business_unit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_assigned_trucks
    ADD CONSTRAINT business_unit_assigned_trucks_business_unit_id_foreign FOREIGN KEY (business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_unit_assigned_trucks business_unit_assigned_trucks_truck_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_assigned_trucks
    ADD CONSTRAINT business_unit_assigned_trucks_truck_id_foreign FOREIGN KEY (truck_id) REFERENCES public.truck(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_unit_tag_business_units business_unit_tag_business_units_business_unit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_tag_business_units
    ADD CONSTRAINT business_unit_tag_business_units_business_unit_id_foreign FOREIGN KEY (business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_unit_tag_business_units business_unit_tag_business_units_business_unit_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_tag_business_units
    ADD CONSTRAINT business_unit_tag_business_units_business_unit_tag_id_foreign FOREIGN KEY (business_unit_tag_id) REFERENCES public.business_unit_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_unit_tags business_unit_tags_business_unit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_tags
    ADD CONSTRAINT business_unit_tags_business_unit_id_foreign FOREIGN KEY (business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: business_unit_tags business_unit_tags_business_unit_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.business_unit_tags
    ADD CONSTRAINT business_unit_tags_business_unit_tag_id_foreign FOREIGN KEY (business_unit_tag_id) REFERENCES public.business_unit_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: compatible_truck_license compatible_truck_license_license_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.compatible_truck_license
    ADD CONSTRAINT compatible_truck_license_license_type_id_foreign FOREIGN KEY (license_type_id) REFERENCES public.license_type(id) ON UPDATE CASCADE;


--
-- Name: completed_bin_service completed_bin_service_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.completed_bin_service
    ADD CONSTRAINT completed_bin_service_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: photo contaminated_photo_tip_summary_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT contaminated_photo_tip_summary_id_foreign FOREIGN KEY (is_tip_summary_contaminated_photo_for_id) REFERENCES public.tip_summary(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: delivery_docket_email_item delivery_docket_email_item_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.delivery_docket_email_item
    ADD CONSTRAINT delivery_docket_email_item_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id);


--
-- Name: driver_assigned_to_regions driver_assigned_to_regions_driver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_assigned_to_regions
    ADD CONSTRAINT driver_assigned_to_regions_driver_id_foreign FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: driver_assigned_to_regions driver_assigned_to_regions_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_assigned_to_regions
    ADD CONSTRAINT driver_assigned_to_regions_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.region(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: driver driver_business_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_business_unit_id_fkey FOREIGN KEY (business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE;


--
-- Name: driver driver_is_owner_of_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_is_owner_of_id_foreign FOREIGN KEY (is_owner_of_id) REFERENCES public.truck(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: driver_license driver_license_driver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_license
    ADD CONSTRAINT driver_license_driver_id_foreign FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE;


--
-- Name: driver_license driver_license_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_license
    ADD CONSTRAINT driver_license_type_id_foreign FOREIGN KEY (type_id) REFERENCES public.license_type(id) ON UPDATE CASCADE;


--
-- Name: driver driver_parks_at_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_parks_at_id_foreign FOREIGN KEY (parks_at_id) REFERENCES public.depot(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: driver driver_shift_licence_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_shift_licence_type_id_foreign FOREIGN KEY (shift_licence_type_id) REFERENCES public.license_type(id) ON DELETE RESTRICT;


--
-- Name: driver driver_supervisor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver
    ADD CONSTRAINT driver_supervisor_id_foreign FOREIGN KEY (supervisor_id) REFERENCES public.driver(id) ON DELETE RESTRICT;


--
-- Name: driver_trained_service_types driver_trained_service_types_driver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_trained_service_types
    ADD CONSTRAINT driver_trained_service_types_driver_id_foreign FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: driver_truck_allocation driver_truck_allocation_driver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_truck_allocation
    ADD CONSTRAINT driver_truck_allocation_driver_id_foreign FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE;


--
-- Name: driver_truck_allocation driver_truck_allocation_truck_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.driver_truck_allocation
    ADD CONSTRAINT driver_truck_allocation_truck_id_foreign FOREIGN KEY (truck_id) REFERENCES public.truck(id) ON UPDATE CASCADE;


--
-- Name: bins_on_site fk_delivery_job; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bins_on_site
    ADD CONSTRAINT fk_delivery_job FOREIGN KEY (delivery_job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: tip_summary_waste_breakdown fk_job; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary_waste_breakdown
    ADD CONSTRAINT fk_job FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: order_line fk_order; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE;


--
-- Name: payment fk_order; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE;


--
-- Name: bins_on_site fk_pickup_job; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.bins_on_site
    ADD CONSTRAINT fk_pickup_job FOREIGN KEY (pickup_job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: payment fk_stored_card; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT fk_stored_card FOREIGN KEY (stored_card_id) REFERENCES public.stored_card(id) ON UPDATE CASCADE;


--
-- Name: tip_site_waste_stockpile fk_tip_site_id; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site_waste_stockpile
    ADD CONSTRAINT fk_tip_site_id FOREIGN KEY (tip_site_id) REFERENCES public.tip_site(id) ON DELETE CASCADE;


--
-- Name: job_attempt fk_trailer_id; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_attempt
    ADD CONSTRAINT fk_trailer_id FOREIGN KEY (trailer_id) REFERENCES public.truck(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: job_attempt job_attempt_driver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_attempt
    ADD CONSTRAINT job_attempt_driver_id_foreign FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE;


--
-- Name: job_attempt job_attempt_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_attempt
    ADD CONSTRAINT job_attempt_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: job_attempt job_attempt_load_tip_summary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_attempt
    ADD CONSTRAINT job_attempt_load_tip_summary_id_fkey FOREIGN KEY (load_tip_summary_id) REFERENCES public.tip_summary(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: job_attempt job_attempt_tip_summary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_attempt
    ADD CONSTRAINT job_attempt_tip_summary_id_fkey FOREIGN KEY (destination_tip_summary_id) REFERENCES public.tip_summary(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: job_attempt job_attempt_truck_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_attempt
    ADD CONSTRAINT job_attempt_truck_id_foreign FOREIGN KEY (truck_id) REFERENCES public.truck(id) ON UPDATE CASCADE;


--
-- Name: job job_business_unit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_business_unit_id_foreign FOREIGN KEY (business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE;


--
-- Name: job job_customer_signature_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_customer_signature_id_foreign FOREIGN KEY (customer_signature_id) REFERENCES public.photo(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: job_permit job_permit_council_permit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_permit
    ADD CONSTRAINT job_permit_council_permit_id_foreign FOREIGN KEY (council_id) REFERENCES public.council_permit(id) ON UPDATE CASCADE;


--
-- Name: job_permit job_permit_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_permit
    ADD CONSTRAINT job_permit_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: job_photo_collection job_photo_collection_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_photo_collection
    ADD CONSTRAINT job_photo_collection_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: job job_preferred_time_window_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_preferred_time_window_id_foreign FOREIGN KEY (preferred_time_window_id) REFERENCES public.time_window(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: job job_region_override_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_region_override_id_foreign FOREIGN KEY (region_override_id) REFERENCES public.region(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: job_sms_log job_sms_log_fk; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job_sms_log
    ADD CONSTRAINT job_sms_log_fk FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: job job_tip_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_tip_site_id_foreign FOREIGN KEY (tip_site_destination_id) REFERENCES public.tip_site(id) ON UPDATE CASCADE;


--
-- Name: job job_transferred_from_business_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_transferred_from_business_unit_id_fkey FOREIGN KEY (transferred_from_business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE;


--
-- Name: tip_summary_waste_breakdown job_waste_breakdown_tip_summary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary_waste_breakdown
    ADD CONSTRAINT job_waste_breakdown_tip_summary_id_fkey FOREIGN KEY (tip_summary_id) REFERENCES public.tip_summary(id);


--
-- Name: mybingo_document mybingo_document_added_by_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_document
    ADD CONSTRAINT mybingo_document_added_by_id_foreign FOREIGN KEY (added_by_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: mybingo_document mybingo_document_updated_by_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_document
    ADD CONSTRAINT mybingo_document_updated_by_id_foreign FOREIGN KEY (updated_by_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: mybingo_order_blocked_time_slot mybingo_order_blocked_time_slot_time_slot_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_blocked_time_slot
    ADD CONSTRAINT mybingo_order_blocked_time_slot_time_slot_id_foreign FOREIGN KEY (time_slot_id) REFERENCES public.mybingo_order_time_slot(id) ON UPDATE CASCADE;


--
-- Name: mybingo_order_blocked_time_slot mybingo_order_blocked_time_slot_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_blocked_time_slot
    ADD CONSTRAINT mybingo_order_blocked_time_slot_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE;


--
-- Name: mybingo_order_cut_off_time_time_slot mybingo_order_cut_off_time_time_slot_cut_off_time_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_cut_off_time_time_slot
    ADD CONSTRAINT mybingo_order_cut_off_time_time_slot_cut_off_time_id_foreign FOREIGN KEY (cut_off_time_id) REFERENCES public.mybingo_order_cut_off_time(id) ON UPDATE CASCADE;


--
-- Name: mybingo_order_cut_off_time mybingo_order_cut_off_time_time_slot_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_cut_off_time
    ADD CONSTRAINT mybingo_order_cut_off_time_time_slot_id_foreign FOREIGN KEY (time_slot_id) REFERENCES public.mybingo_order_time_slot(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: mybingo_order_cut_off_time_time_slot mybingo_order_cut_off_time_time_slot_time_slot_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_order_cut_off_time_time_slot
    ADD CONSTRAINT mybingo_order_cut_off_time_time_slot_time_slot_id_foreign FOREIGN KEY (time_slot_id) REFERENCES public.mybingo_order_time_slot(id) ON UPDATE CASCADE;


--
-- Name: mybingo_request mybingo_request_requested_by_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_request
    ADD CONSTRAINT mybingo_request_requested_by_id_foreign FOREIGN KEY (requested_by_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: mybingo_role_permission mybingo_role_permission_permission_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_role_permission
    ADD CONSTRAINT mybingo_role_permission_permission_id_foreign FOREIGN KEY (permission_id) REFERENCES public.mybingo_permission(id) ON UPDATE CASCADE;


--
-- Name: mybingo_user_account_favourite mybingo_user_account_favourite_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_account_favourite
    ADD CONSTRAINT mybingo_user_account_favourite_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE;


--
-- Name: mybingo_user_business_account_mapping mybingo_user_business_account_mapping_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_business_account_mapping
    ADD CONSTRAINT mybingo_user_business_account_mapping_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE;


--
-- Name: mybingo_user_notification mybingo_user_notification_mybingo_notification_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_notification
    ADD CONSTRAINT mybingo_user_notification_mybingo_notification_id_foreign FOREIGN KEY (mybingo_notification_id) REFERENCES public.mybingo_notification(id) ON UPDATE CASCADE;


--
-- Name: mybingo_user_notification mybingo_user_notification_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_notification
    ADD CONSTRAINT mybingo_user_notification_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE;


--
-- Name: mybingo_user_site_favourite mybingo_user_site_favourite_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_site_favourite
    ADD CONSTRAINT mybingo_user_site_favourite_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE;


--
-- Name: mybingo_user_site_mapping mybingo_user_site_mapping_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.mybingo_user_site_mapping
    ADD CONSTRAINT mybingo_user_site_mapping_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.mybingo_user(id) ON UPDATE CASCADE;


--
-- Name: order_line order_line_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT order_line_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: order_line order_line_tip_ticket_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT order_line_tip_ticket_id_foreign FOREIGN KEY (tip_ticket_id) REFERENCES public.tip_ticket(id) ON UPDATE CASCADE;


--
-- Name: photo photo_completed_bin_service_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_completed_bin_service_id_foreign FOREIGN KEY (completed_bin_service_id) REFERENCES public.completed_bin_service(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: photo photo_job_photo_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_job_photo_collection_id_foreign FOREIGN KEY (job_photo_collection_id) REFERENCES public.job_photo_collection(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: photo photo_tip_summary_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_tip_summary_id_foreign FOREIGN KEY (is_tip_summary_spotter_photo_for_id) REFERENCES public.tip_summary(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: photo photo_truck_inspection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_truck_inspection_id_foreign FOREIGN KEY (truck_inspection_id) REFERENCES public.truck_inspection(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: photo photo_truck_issue_reference_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_truck_issue_reference_id_fkey FOREIGN KEY (truck_issue_reference_id) REFERENCES public.truck_issue_reference(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: job pickup_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT pickup_job_id_foreign FOREIGN KEY (pickup_job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: roster_entry roster_entry_driver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.roster_entry
    ADD CONSTRAINT roster_entry_driver_id_foreign FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE;


--
-- Name: runsheet runsheet_business_unit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet
    ADD CONSTRAINT runsheet_business_unit_id_foreign FOREIGN KEY (business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE;


--
-- Name: runsheet runsheet_from_template_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet
    ADD CONSTRAINT runsheet_from_template_id_foreign FOREIGN KEY (from_template_id) REFERENCES public.runsheet_template(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: runsheet_job_ordering runsheet_job_ordering_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_job_ordering
    ADD CONSTRAINT runsheet_job_ordering_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: runsheet_job_ordering runsheet_job_ordering_runsheet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_job_ordering
    ADD CONSTRAINT runsheet_job_ordering_runsheet_id_foreign FOREIGN KEY (runsheet_id) REFERENCES public.runsheet(id) ON UPDATE CASCADE;


--
-- Name: runsheet_template runsheet_template_business_unit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_template
    ADD CONSTRAINT runsheet_template_business_unit_id_foreign FOREIGN KEY (business_unit_id) REFERENCES public.business_unit(id) ON UPDATE CASCADE;


--
-- Name: runsheet_template_preferred_tip_sites runsheet_template_preferred_tip_sites_runsheet_template_id_fore; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_template_preferred_tip_sites
    ADD CONSTRAINT runsheet_template_preferred_tip_sites_runsheet_template_id_fore FOREIGN KEY (runsheet_template_id) REFERENCES public.runsheet_template(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: runsheet_template_preferred_tip_sites runsheet_template_preferred_tip_sites_tip_site_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.runsheet_template_preferred_tip_sites
    ADD CONSTRAINT runsheet_template_preferred_tip_sites_tip_site_id_foreign FOREIGN KEY (tip_site_id) REFERENCES public.tip_site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: service_agreement_line_ordering service_line_item_ordering_runsheet_template_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.service_agreement_line_ordering
    ADD CONSTRAINT service_line_item_ordering_runsheet_template_id_foreign FOREIGN KEY (runsheet_template_id) REFERENCES public.runsheet_template(id) ON UPDATE CASCADE;


--
-- Name: shift_break shift_break_shift_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift_break
    ADD CONSTRAINT shift_break_shift_id_foreign FOREIGN KEY (shift_id) REFERENCES public.shift(id) ON UPDATE CASCADE;


--
-- Name: shift shift_driver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT shift_driver_id_foreign FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE;


--
-- Name: shift shift_next_truck_to_use_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT shift_next_truck_to_use_id_fkey FOREIGN KEY (next_truck_to_use_id) REFERENCES public.truck(id);


--
-- Name: shift shift_truck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT shift_truck_id_fkey FOREIGN KEY (truck_id) REFERENCES public.truck(id);


--
-- Name: site_driver_note site_driver_note_created_by_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_driver_note
    ADD CONSTRAINT site_driver_note_created_by_id_foreign FOREIGN KEY (created_by_id) REFERENCES public.driver(id) ON UPDATE CASCADE;


--
-- Name: site_preferred_driver site_preferred_driver_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.site_preferred_driver
    ADD CONSTRAINT site_preferred_driver_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON DELETE CASCADE;


--
-- Name: job superseded_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT superseded_job_id_foreign FOREIGN KEY (superseded_job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: tip_site_location_on_site_epl tip_site_location_on_site_epl_fk; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site_location_on_site_epl
    ADD CONSTRAINT tip_site_location_on_site_epl_fk FOREIGN KEY (tip_site_id) REFERENCES public.tip_site(id);


--
-- Name: tip_site tip_site_opening_hours_saturdays_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site
    ADD CONSTRAINT tip_site_opening_hours_saturdays_id_foreign FOREIGN KEY (opening_hours_saturdays_id) REFERENCES public.time_window(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tip_site tip_site_opening_hours_sundays_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site
    ADD CONSTRAINT tip_site_opening_hours_sundays_id_foreign FOREIGN KEY (opening_hours_sundays_id) REFERENCES public.time_window(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tip_site tip_site_opening_hours_weekdays_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_site
    ADD CONSTRAINT tip_site_opening_hours_weekdays_id_foreign FOREIGN KEY (opening_hours_weekdays_id) REFERENCES public.time_window(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tip_summary tip_summary_contaminated_photo_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary
    ADD CONSTRAINT tip_summary_contaminated_photo_id_foreign FOREIGN KEY (contaminated_photo_id) REFERENCES public.photo(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tip_summary tip_summary_docket_photo_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary
    ADD CONSTRAINT tip_summary_docket_photo_id_foreign FOREIGN KEY (docket_photo_id) REFERENCES public.photo(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tip_summary tip_summary_tip_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_summary
    ADD CONSTRAINT tip_summary_tip_job_id_foreign FOREIGN KEY (tip_job_id) REFERENCES public.job(id) ON UPDATE CASCADE;


--
-- Name: tip_ticket tip_ticket_created_from_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_ticket
    ADD CONSTRAINT tip_ticket_created_from_job_id_fkey FOREIGN KEY (created_from_job_id) REFERENCES public.job(id);


--
-- Name: tip_ticket tip_ticket_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_ticket
    ADD CONSTRAINT tip_ticket_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.driver(id);


--
-- Name: tip_ticket tip_ticket_driver_signature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_ticket
    ADD CONSTRAINT tip_ticket_driver_signature_id_fkey FOREIGN KEY (driver_signature_id) REFERENCES public.photo(id);


--
-- Name: tip_ticket tip_ticket_truck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.tip_ticket
    ADD CONSTRAINT tip_ticket_truck_id_fkey FOREIGN KEY (truck_id) REFERENCES public.truck(id);


--
-- Name: truck_group_trucks truck_group_trucks_truck_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_group_trucks
    ADD CONSTRAINT truck_group_trucks_truck_group_id_foreign FOREIGN KEY (truck_group_id) REFERENCES public.truck_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: truck_group_trucks truck_group_trucks_truck_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_group_trucks
    ADD CONSTRAINT truck_group_trucks_truck_id_foreign FOREIGN KEY (truck_id) REFERENCES public.truck(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: truck truck_home_depot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck
    ADD CONSTRAINT truck_home_depot_id_fkey FOREIGN KEY (home_depot_id) REFERENCES public.depot(id) ON UPDATE CASCADE;


--
-- Name: truck_inspection truck_inspection_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_inspection
    ADD CONSTRAINT truck_inspection_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.driver(id) ON UPDATE CASCADE;


--
-- Name: truck_inspection truck_inspection_truck_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_inspection
    ADD CONSTRAINT truck_inspection_truck_id_foreign FOREIGN KEY (truck_id) REFERENCES public.truck(id) ON UPDATE CASCADE;


--
-- Name: truck_issue_reference truck_issue_reference_inspection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_issue_reference
    ADD CONSTRAINT truck_issue_reference_inspection_id_foreign FOREIGN KEY (inspection_id) REFERENCES public.truck_inspection(id) ON UPDATE CASCADE;


--
-- Name: truck_issue_reference truck_issue_reference_issue_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_issue_reference
    ADD CONSTRAINT truck_issue_reference_issue_id_foreign FOREIGN KEY (issue_id) REFERENCES public.truck_issue(id) ON UPDATE CASCADE;


--
-- Name: truck_issue truck_issue_truck_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.truck_issue
    ADD CONSTRAINT truck_issue_truck_id_foreign FOREIGN KEY (truck_id) REFERENCES public.truck(id) ON UPDATE CASCADE;


--
-- Name: work_allocation work_allocation_driver_truck_allocation_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.work_allocation
    ADD CONSTRAINT work_allocation_driver_truck_allocation_id_foreign FOREIGN KEY (driver_truck_allocation_id) REFERENCES public.driver_truck_allocation(id) ON UPDATE CASCADE;


--
-- Name: work_allocation work_allocation_job_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.work_allocation
    ADD CONSTRAINT work_allocation_job_id_foreign FOREIGN KEY (job_id) REFERENCES public.job(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: work_allocation work_allocation_runsheet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: skeep
--

ALTER TABLE ONLY public.work_allocation
    ADD CONSTRAINT work_allocation_runsheet_id_foreign FOREIGN KEY (runsheet_id) REFERENCES public.runsheet(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: TABLE absence; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.absence TO bingobi;


--
-- Name: TABLE allowed_truck; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.allowed_truck TO bingobi;


--
-- Name: TABLE associated_product; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.associated_product TO bingobi;


--
-- Name: TABLE audit_change; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.audit_change TO bingobi;


--
-- Name: TABLE audit_related_entity_change; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.audit_related_entity_change TO bingobi;


--
-- Name: TABLE auth_okta_group_role; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.auth_okta_group_role TO bingobi;


--
-- Name: TABLE auth_permission; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.auth_permission TO bingobi;


--
-- Name: TABLE bin_image; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.bin_image TO bingobi;


--
-- Name: TABLE bin_record; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.bin_record TO bingobi;


--
-- Name: TABLE bins_on_site; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.bins_on_site TO bingobi;


--
-- Name: TABLE bins_on_site_adjustment; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.bins_on_site_adjustment TO bingobi;


--
-- Name: TABLE business_unit; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.business_unit TO bingobi;


--
-- Name: TABLE business_unit_assigned_tip_sites; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.business_unit_assigned_tip_sites TO bingobi;


--
-- Name: TABLE business_unit_assigned_trucks; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.business_unit_assigned_trucks TO bingobi;


--
-- Name: TABLE business_unit_tag; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.business_unit_tag TO bingobi;


--
-- Name: TABLE business_unit_tag_business_units; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.business_unit_tag_business_units TO bingobi;


--
-- Name: TABLE business_unit_tags; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.business_unit_tags TO bingobi;


--
-- Name: TABLE compatible_truck_license; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.compatible_truck_license TO bingobi;


--
-- Name: TABLE completed_bin_service; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.completed_bin_service TO bingobi;


--
-- Name: TABLE council_permit; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.council_permit TO bingobi;


--
-- Name: TABLE crm_event; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.crm_event TO bingobi;


--
-- Name: TABLE delivery_docket_email_item; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.delivery_docket_email_item TO bingobi;


--
-- Name: TABLE depot; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.depot TO bingobi;


--
-- Name: TABLE driver; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.driver TO bingobi;


--
-- Name: TABLE driver_assigned_to_regions; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.driver_assigned_to_regions TO bingobi;


--
-- Name: TABLE driver_license; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.driver_license TO bingobi;


--
-- Name: TABLE driver_trained_service_types; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.driver_trained_service_types TO bingobi;


--
-- Name: TABLE driver_truck_allocation; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.driver_truck_allocation TO bingobi;


--
-- Name: TABLE geography_columns; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.geography_columns TO bingobi;


--
-- Name: TABLE geometry_columns; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.geometry_columns TO bingobi;


--
-- Name: TABLE heartbeat; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.heartbeat TO bingobi;


--
-- Name: TABLE internal_metadata; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.internal_metadata TO bingobi;


--
-- Name: TABLE mybingo_invoice_payment; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_invoice_payment TO bingobi;


--
-- Name: TABLE job; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.job TO bingobi;


--
-- Name: TABLE job_attempt; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.job_attempt TO bingobi;


--
-- Name: TABLE job_permit; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.job_permit TO bingobi;


--
-- Name: TABLE job_photo_collection; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.job_photo_collection TO bingobi;


--
-- Name: TABLE region; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.region TO bingobi;


--
-- Name: TABLE site_location_point; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.site_location_point TO bingobi;


--
-- Name: TABLE job_regions; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.job_regions TO bingobi;


--
-- Name: TABLE tip_summary_waste_breakdown; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.tip_summary_waste_breakdown TO bingobi;


--
-- Name: TABLE license_type; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.license_type TO bingobi;


--
-- Name: TABLE migration; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.migration TO bingobi;


--
-- Name: TABLE mybingo_announcement; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_announcement TO bingobi;


--
-- Name: TABLE mybingo_document; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_document TO bingobi;


--
-- Name: TABLE mybingo_email_type; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_email_type TO bingobi;


--
-- Name: TABLE mybingo_information_type; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_information_type TO bingobi;


--
-- Name: TABLE mybingo_notification; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_notification TO bingobi;


--
-- Name: TABLE mybingo_order_blocked_time_slot; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_order_blocked_time_slot TO bingobi;


--
-- Name: TABLE mybingo_order_cut_off_time; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_order_cut_off_time TO bingobi;


--
-- Name: TABLE mybingo_order_cut_off_time_time_slot; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_order_cut_off_time_time_slot TO bingobi;


--
-- Name: TABLE mybingo_order_time_slot; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_order_time_slot TO bingobi;


--
-- Name: TABLE mybingo_permission; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_permission TO bingobi;


--
-- Name: TABLE mybingo_request; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_request TO bingobi;


--
-- Name: TABLE mybingo_request_type; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_request_type TO bingobi;


--
-- Name: TABLE mybingo_role_permission; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_role_permission TO bingobi;


--
-- Name: TABLE mybingo_system_document; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_system_document TO bingobi;


--
-- Name: TABLE mybingo_user; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_user TO bingobi;


--
-- Name: TABLE mybingo_user_account_favourite; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_user_account_favourite TO bingobi;


--
-- Name: TABLE mybingo_user_business_account_mapping; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_user_business_account_mapping TO bingobi;


--
-- Name: TABLE mybingo_user_notification; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_user_notification TO bingobi;


--
-- Name: TABLE mybingo_user_site_favourite; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_user_site_favourite TO bingobi;


--
-- Name: TABLE mybingo_user_site_mapping; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.mybingo_user_site_mapping TO bingobi;


--
-- Name: TABLE notification; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.notification TO bingobi;


--
-- Name: TABLE "order"; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public."order" TO bingobi;


--
-- Name: TABLE order_line; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.order_line TO bingobi;


--
-- Name: TABLE payment; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.payment TO bingobi;


--
-- Name: TABLE photo; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.photo TO bingobi;


--
-- Name: TABLE public_holiday; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.public_holiday TO bingobi;


--
-- Name: TABLE roster_entry; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.roster_entry TO bingobi;


--
-- Name: TABLE runsheet; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.runsheet TO bingobi;


--
-- Name: TABLE runsheet_job_ordering; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.runsheet_job_ordering TO bingobi;


--
-- Name: TABLE runsheet_template; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.runsheet_template TO bingobi;


--
-- Name: TABLE runsheet_template_preferred_tip_sites; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.runsheet_template_preferred_tip_sites TO bingobi;


--
-- Name: TABLE service_agreement_line_ordering; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.service_agreement_line_ordering TO bingobi;


--
-- Name: TABLE shift; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.shift TO bingobi;


--
-- Name: TABLE shift_break; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.shift_break TO bingobi;


--
-- Name: TABLE site_driver_note; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.site_driver_note TO bingobi;


--
-- Name: TABLE site_preferred_driver; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.site_preferred_driver TO bingobi;


--
-- Name: TABLE spatial_ref_sys; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.spatial_ref_sys TO bingobi;


--
-- Name: TABLE stored_card; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.stored_card TO bingobi;


--
-- Name: TABLE subscription; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.subscription TO bingobi;


--
-- Name: TABLE system_config; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.system_config TO bingobi;


--
-- Name: TABLE time_window; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.time_window TO bingobi;


--
-- Name: TABLE tip_site; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.tip_site TO bingobi;


--
-- Name: TABLE tip_site_location_on_site_epl; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.tip_site_location_on_site_epl TO bingobi;


--
-- Name: TABLE tip_site_waste_stockpile; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.tip_site_waste_stockpile TO bingobi;


--
-- Name: TABLE tip_summary; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.tip_summary TO bingobi;


--
-- Name: TABLE tip_ticket; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.tip_ticket TO bingobi;


--
-- Name: TABLE transfer_job; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.transfer_job TO bingobi;


--
-- Name: TABLE truck; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.truck TO bingobi;


--
-- Name: TABLE truck_group; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.truck_group TO bingobi;


--
-- Name: TABLE truck_group_trucks; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.truck_group_trucks TO bingobi;


--
-- Name: TABLE truck_inspection; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.truck_inspection TO bingobi;


--
-- Name: TABLE truck_issue; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.truck_issue TO bingobi;


--
-- Name: TABLE truck_issue_reference; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.truck_issue_reference TO bingobi;


--
-- Name: TABLE user_preference; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.user_preference TO bingobi;


--
-- Name: TABLE vehicle_type; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.vehicle_type TO bingobi;


--
-- Name: TABLE weighbridge_weight_log; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.weighbridge_weight_log TO bingobi;


--
-- Name: TABLE work_allocation; Type: ACL; Schema: public; Owner: skeep
--

GRANT SELECT ON TABLE public.work_allocation TO bingobi;


--
-- PostgreSQL database dump complete
--

