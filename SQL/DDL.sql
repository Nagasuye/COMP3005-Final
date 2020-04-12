drop table if exists book_order;
drop table if exists stock;
drop table if exists book;
drop table if exists warehouse;
drop table if exists publisher;
drop table if exists author;
drop table if exists tracking;
drop table if exists purchase;
drop table if exists person;
drop table if exists address;
drop table if exists kind;

create table kind(
	kind_id           numeric(1, 0),
	title             varchar(5),
	primary key (kind_id)
);

create table address(
	street_num        numeric(12, 0) not null,
	street_name       varchar(15) not null,
	city              varchar(15) not null,
	postal_code       varchar(6) not null,
	primary key (street_num, street_name)
);

create table person(
	username          varchar(30) unique,
	name              varchar(30) not null,
	age               numeric(3, 0),
	password          varchar(20) not null,
	street_num        numeric(12, 0),
	street_name       varchar(15),
	kind_id           numeric(1, 0),
	primary key (username),
	foreign key (street_num, street_name) references address
		on delete cascade,
	foreign key (kind_id) references kind
		on delete cascade
);

create table purchase(
	username          varchar(30),
	bank_num          numeric(16, 0) not null,
	bank_name         varchar(30) not null,
	purchase_date     date default CURRENT_DATE,
	primary key (username, purchase_date),
	foreign key (username) references person
		on delete cascade
);

create table tracking(
	username          varchar(30),
	street_num        numeric(12, 0),
	street_name       varchar(15),
	status            varchar(15) default 'order placed',
	purchase_date     date default CURRENT_DATE,
	primary key (username, purchase_date),
	foreign key (username, purchase_date) references purchase
		on delete cascade,
	foreign key (street_num, street_name) references address
		on delete cascade
);

create table author(
	author_name       varchar(30) not null,
	age               numeric(3, 0),
	primary key (author_name)
);

create table publisher(
	publisher_name    varchar(30) not null,
	street_num        numeric(12, 0),
	street_name       varchar(15),
	email             varchar(50) not null,
	phone_num         numeric(10, 0),
	primary key (publisher_name),
	foreign key (street_num, street_name) references address
		on delete cascade
);

create table warehouse(
	warehouse_id      numeric(1, 0),
	street_num        numeric(12, 0),
	street_name       varchar(15),
	phone_num         numeric(10, 0),
	primary key (warehouse_id),
	foreign key (street_num, street_name) references address
		on delete cascade
);

create table book(
	name              varchar(80) not null,
	author_name       varchar(30),
	publisher_name    varchar(30),
	warehouse_id      numeric(1, 0),
	year              numeric(4, 0) not null check(year > 1500 and year < 2021),
	ISBN              numeric(13, 0) not null,
	pages             numeric(5, 0) not null,
	price             numeric(6, 2) not null,
	genre             varchar(20) default 'unspecified',
	primary key (name),
	foreign key (author_name) references author
		on delete cascade,
	foreign key (publisher_name) references publisher
		on delete cascade,
	foreign key (warehouse_id) references warehouse
		on delete set null
);

create table stock(
	name              varchar(80),
	quantity          numeric(3, 0) default 10,
	primary key (name),
	foreign key (name) references book
		on delete cascade
);

create table book_order(
	name              varchar(80),
	username          varchar(30),
	quantity          numeric(3, 0) not null,
	purchase_date     date default CURRENT_DATE,
	primary key (name, username, purchase_date),
	foreign key (name) references book
		on delete cascade,
	foreign key (username, purchase_date) references purchase
		on delete cascade
);











