delete from book_order;
delete from stock;
delete from book;
delete from warehouse;
delete from publisher;
delete from author;
delete from tracking;
delete from purchase;
delete from person;
delete from address;
delete from kind;

insert into kind values ('0', 'user');
insert into kind values ('1', 'owner');

insert into address values ('1', 'First', 'Ottawa', 'K1F5H6');
insert into address values ('56', 'Main', 'Ottawa', 'K1R3D5');
insert into address values ('7', 'Bronson', 'Ottawa', 'K4G7D3');
insert into address values ('1001', 'Sommerset', 'Ottawa', 'K3D8S1');
insert into address values ('1010', 'Bank', 'Ottawa', 'K9G5F2');
insert into address values ('99', 'Second', 'Ottawa', 'K7G4F6');

insert into person values ('testuser', 'Bob', '21', 'pass', '1', 'First', '0');
insert into person values ('owner', 'Mike', '45', 'owner', '1010', 'Bank', '1');

insert into purchase values ('testuser', '1234567812345678', 'test j user', '2020-04-09');
insert into purchase values ('testuser', '1234567812345678', 'test j user', '2020-01-01');

insert into tracking values ('testuser', '1', 'First', 'shipped', '2020-04-09');
insert into tracking values ('testuser', '1', 'First', 'delivered', '2020-01-01');

insert into author values ('JK Rowling', '54');
insert into author values ('Shakesphere', '99');
insert into author values ('Webster', '67');
insert into author values ('Dr Seuss', '99');

insert into publisher values ('we publish', '56', 'Main', 'sendmoney@money.ca', '6476479111');
insert into publisher values ('publish mcPublisher', '1001', 'Sommerset', 'moremoney@money.ca', '4161341232');

insert into warehouse values ('1', '7', 'Bronson', '4165221234');

insert into book values ('Harry Potter and the Goblet of Fire', 'JK Rowling', 'we publish', '1', '2000', '1234567654321', '636', '10.99', 'fantasy');
insert into book values ('Harry Potter and the Prisoner of Ascaban', 'JK Rowling', 'we publish', '1', '2002', '1234567891234', '520', '14.99', 'fantasy');
insert into book values ('Harry Potter and the Chamber of Secrets', 'JK Rowling', 'we publish', '1', '2004', '7834566824321', '740', '9.99', 'fantasy');
insert into book values ('Macbeth', 'Shakesphere', 'publish mcPublisher', '1', '1910', '9043562654451', '401', '1.99', 'drama');
insert into book values ('Dictionary', 'Webster', 'publish mcPublisher', '1', '1967', '6528562654445', '985', '19.99', 'education');
insert into book values ('Green Eggs and Ham', 'Dr Seuss', 'publish mcPublisher', '1', '2012', '6528562561342', '25', '4.99', 'childrens');

insert into stock values ('Harry Potter and the Goblet of Fire', '30');
insert into stock values ('Harry Potter and the Prisoner of Ascaban', '20');
insert into stock values ('Harry Potter and the Chamber of Secrets', '50');
insert into stock values ('Macbeth', '15');
insert into stock values ('Dictionary', '45');
insert into stock values ('Green Eggs and Ham', '67');

insert into book_order values ('Harry Potter and the Goblet of Fire', 'testuser', '3', '2020-04-09');
insert into book_order values ('Macbeth', 'testuser', '1', '2020-01-01');