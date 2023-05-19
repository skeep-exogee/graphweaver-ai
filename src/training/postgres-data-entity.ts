export const conversationId = "postgres-data-entity-0.0.27";

export type Prompt = {
  input: string;
};

const jobSql = `CREATE TABLE truck (
    id BIGSERIAL PRIMARY KEY,
    plate_number character varying(255) NOT NULL,
    transmission text CHECK (transmission = ANY (ARRAY['AUTOMATIC'::text, 'MANUAL'::text])),
    home_depot_id bigint REFERENCES depot(id) ON UPDATE CASCADE,
    status text CHECK (status = ANY (ARRAY['OK'::text, 'INACTIVE'::text, 'MECHANICAL_ISSUE'::text, 'OTHER_ISSUE'::text])),
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
    is_in_use boolean NOT NULL DEFAULT false,
    crm_service_type_id uuid,
    owner_type text CHECK (owner_type = ANY (ARRAY['BINGO'::text, 'EXTERNAL'::text, 'SUBCONTRACTOR'::text])),
    weight_limit_type text CHECK (weight_limit_type = ANY (ARRAY['GML'::text, 'CML'::text, 'HML'::text])),
    vehicle_type_id bigint,
    gml_exemption_proposed boolean DEFAULT false,
    tare_updated_date timestamp(0) with time zone,
    tare_updated_by_operator character varying(255),
    tare_updated_site_id character varying(255),
    size_id uuid
);`;

const jobDataEntity = `import {
	BigIntType,
	Collection,
	Entity,
	Enum,
	ManyToMany,
	ManyToOne,
	OneToMany,
	OneToOne,
	PrimaryKey,
	Property,
	IdentifiedReference,
} from '@mikro-orm/core';
import { BaseEntity } from '@exogee/graphweaver-mikroorm';

import {
	BusinessUnit,
	Depot,
	Driver,
	TruckGroup,
	TruckIssue,
	VehicleType,
	AllowedTruck,
	TipSite,
} from '.';
import { DateType } from '../types';
import { TruckInspection } from './truck-inspection';
import { DriverTruckAllocation } from './driver-truck-allocation';
import { ExternalIdField } from '../decorators';

export enum TransmissionType {
	AUTO = 'AUTOMATIC',
	MANUAL = 'MANUAL',
}

export enum TruckStatus {
	OK = 'OK',
	INACTIVE = 'INACTIVE',
	MECHANICAL_ISSUE = 'MECHANICAL_ISSUE',
	OTHER_ISSUE = 'OTHER_ISSUE',
}

export enum OwnerType {
	BINGO = 'BINGO',
	EXTERNAL = 'EXTERNAL',
	SUBCONTRACTOR = 'SUBCONTRACTOR',
}

export enum WeightLimitType {
	GML = 'GML',
	CML = 'CML',
	HML = 'HML',
}

@Entity()
export class Truck extends BaseEntity {
	@PrimaryKey({ type: BigIntType })
	id!: string;

	@Property({ type: 'string' })
	plateNumber!: string;

	@Enum({ items: () => TransmissionType, type: 'string', nullable: true })
	transmission?: TransmissionType;

	@ManyToOne(() => Depot, { wrappedReference: true, nullable: true })
	homeDepot?: IdentifiedReference<Depot>;

	@ExternalIdField({ from: 'size' })
	@Property({ nullable: true, columnType: 'uuid', type: 'string' })
	sizeId?: string;

	@Enum({ items: () => TruckStatus, type: 'string', nullable: true })
	status?: TruckStatus;

	@ManyToMany(() => TruckGroup, 'trucks', { nullable: true })
	groups = new Collection<TruckGroup>(this);

	@Property({ type: 'string', nullable: true })
	assetNumber?: string;

	@Property({ type: 'string', nullable: true })
	make?: string;

	@Property({ type: 'string', nullable: true })
	model?: string;

	@Property({ type: 'string', nullable: true })
	vin?: string;

	@Property({ type: 'string', nullable: true })
	engineNumber?: string;

	@Property({ type: 'string', nullable: true })
	spSerialNumber?: string;

	@ExternalIdField({ from: 'type' })
	@Property({ type: 'string', columnType: 'uuid', nullable: true })
	crmServiceTypeId?: string; // From CRM

	@Property({
		type: 'string',
		nullable: true,
		columnType: 'numeric(10,2)',
		comment: 'Maximum carrying capacity in m³',
	})
	capacityCap?: string;

	@Property({
		type: 'string',
		nullable: true,
		columnType: 'numeric(10,2)',
		comment: 'Weight of unloaded truck in kilograms',
	})
	tare?: string;

	@Property({ type: 'date', nullable: true })
	tareUpdatedDate?: Date;

	@Property({ type: 'string', nullable: true })
	tareUpdatedByOperator?: string;

	@ManyToOne(() => TipSite, { wrappedReference: true, nullable: true })
	tareUpdatedSite?: IdentifiedReference<TipSite>;

	@ManyToOne(() => VehicleType, { wrappedReference: true, nullable: true })
	vehicleType?: IdentifiedReference<VehicleType>;

	@Property({ type: 'string', nullable: true, columnType: 'numeric(10,2)', comment: 'in metres' })
	length?: string;
	@Property({ type: 'string', nullable: true, columnType: 'numeric(10,2)', comment: 'in metres' })
	width?: string;
	@Property({ type: 'string', nullable: true, columnType: 'numeric(10,2)', comment: 'in metres' })
	height?: string;

	@Property({ type: 'string', nullable: true, columnType: 'numeric(10,2)', comment: 'in metres' })
	turningCircleRadius?: string;

	@Property({ type: 'string', nullable: true, columnType: 'numeric(10,2)', comment: 'in metres' })
	wheelBase?: string;

	@Property({ type: 'boolean', nullable: true })
	twoWayRadio?: boolean;

	@Property({ type: 'string', nullable: true })
	fuelTagNumber?: string;

	@Property({ type: 'date', nullable: true })
	scalesLastCalibratedAt?: Date;

	@Property({ customType: new DateType(), nullable: true })
	manufactureDateOfChassis?: string;

	@Property({ customType: new DateType(), nullable: true })
	manufactureDateOfBody?: string;

	@ManyToMany(() => BusinessUnit, 'assignedTrucks')
	assignedToBusinessUnits = new Collection<BusinessUnit>(this);

	@OneToMany(() => TruckIssue, 'truck', { nullable: true })
	issues = new Collection<TruckIssue>(this);

	@OneToMany(() => TruckInspection, 'truck', { nullable: true })
	inspections = new Collection<TruckInspection>(this);

	@OneToMany(() => DriverTruckAllocation, 'truck', { nullable: true })
	driverTruckAllocations = new Collection<DriverTruckAllocation>(this);

	@OneToMany(() => Driver, 'isOwnerOf', { nullable: true })
	ownedBy = new Collection<Driver>(this);

	@OneToMany(() => AllowedTruck, 'truck', { nullable: true })
	allowedTruck = new Collection<AllowedTruck>(this);

	@Enum({ items: () => OwnerType, type: 'string', nullable: true })
	ownerType?: OwnerType;

	@Enum({
		items: () => WeightLimitType,
		type: 'string',
		default: WeightLimitType.GML,
		nullable: true,
	})
	weightLimitType?: WeightLimitType;

	@Property({ type: 'boolean', default: false, nullable: true })
	gmlExemptionProposed?: boolean;
}

}
`;

const ac1 = `AC1: All properties are camel case.`;
const ac2 = `AC2: The class should never include a constructor method.`;
const ac3 = `AC3: Always extend BaseEntity and make sure you import it.`;
const ac4 = `AC4: Enums should be defined and exported above the class file using typescripts enum type.`;
const ac5 = `AC5: If a custom type is used then it must be imported.`;
const acceptanceCriteria = `\nHere are the requirements for when you create a data entity class: \n${ac1} \n${ac2} \n${ac3} \n${ac4} \n${ac5}`;

export const askPrompt = (sql: string) =>
  `Your task is to create a GraphWeaver PostgreSQL data entity class using the acceptance criteria I told you about previously. For the following """${sql}""" I want you to respond to me in only JSON format with two keys a fileName and the fileBody. Note that the file name is kebab case and ends with the extension ".ts". Make sure that the JSON parses correctly not use of template literals. ${acceptanceCriteria}`;

export const prompts: Prompt[] = [
  {
    input: `I want you to act as a software developer. The first thing you need to learn is about GraphWeaver which is a Node Typescript module found at (https://github.com/exogee-technology/graphweaver). It allows developers to build GraphQL APIs easily. In order to build an API the developer has to create data entities that connect to the data source. In this example the data source is a postgresql database. Im including the SQL that generated the table here for you between the three double quotes """${jobSql}""". I have one more thing to teach you but first, Do you have any questions?`,
  },
  {
    input: `The next thing you need to learn is about GraphWeaver is what a data entity looks like. Based off the previous SQL statement this is the data entity that was created between the three double quotes """${jobDataEntity}""". Use this format in all future classes that you create. Do you have any questions?`,
  },
  {
    input: askPrompt(jobSql),
  },
];
