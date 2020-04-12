Version: program was tested using node.js version 6.12.3 on a 64-bit Windows 10 OS

Files: server.js,
       SQL/
           DDL.sql,
           store-initializer.sql,
           functions.sql,
       store.pug,
       user.pug,
       book.pug,
       cart.pug,
       register.pug,
       header.pug,
       footer.pug

Purpose: This program simulates a book store 'Look Inna Book' where users can login and purchase books.
         Additionally the store owner can add and remove books

Setup: First change the connection string on line 4 of server.js to:
               'postgressql://postgres:PASS@localhost:5432/bookstore' replacing PASS with your psql password
       The store first needs to be created and initialized.
       To create the store, open a psql shell and connect to port 5432. From there create the database 'bookstore' then,
       run the command \i 'PATH/SQL/DDL.sql' replacing the path with the location of the folder.
       Next, to initialize the database run the command \i 'PATH/SQL/store-initializer.sql' again,
       replacing the path with the location of the folder

       Once created and initialized, in another terminal in the project code directory,
       initialize the node package using the command npm init followed by the command npm install --save.
       Then start the server using the command node .\server.js

Testing: To access the store, open localhost:3000
         There are 2 profiles already created, 1 is a user with username:testuser and password:pass
         and the other is the owner with username and password as 'owner'

Author: Kieran Nagasuye
	101040415

Date: Apr 14, 2020

Bugs: none
