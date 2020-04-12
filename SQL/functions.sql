--checks if the given username and password is in the database
--if they are, the users information is returned
function checkLogin(usrn, pswd){
	return new Promise(function(resolve){
		client.query('select * from person where username = $1 and password = $2', [usrn, pswd], (err, results)=>{
			if(err) resolve(null);			
			resolve((!results.rows)? null: results.rows);
		});
	});
}

--gets the orders of the given user
function getOrders(sesh){
	if(sesh.owner){
		return new Promise(function(resolve){
			client.query('select * from book_order', (err, results)=>{
				if(err) resolve(null);
				resolve((!results)? []: results.rows);
			});
		});
	}else{
		return new Promise(function(resolve){
			client.query('select b.name, b.purchase_date, b.quantity, t.status from book_order as b, tracking as t where b.purchase_date=t.purchase_date and b.username=$1', [sesh.username], (err, results)=>{
				if(err) resolve(null);
				resolve((!results)? []: results.rows);
			});
		});
	}
}

--adds the given publisher to the database
function addPublisher(nam, stnum, stn, email, phnum){
	return new Promise(function(resolve){
		client.query('insert into publisher (publisher_name, street_num, street_name, email, phone_num) values ($1, $2, $3, $4, $5)', [nam, stnum, stn, email, phnum], (err, results)=>{
			if(err) resolve(null);			
			resolve(results);
		});
	});
}

--adds the given author to the database
function addAuthor(nam, age){
	return new Promise(function(resolve){
		client.query('insert into author (author_name, age) values ($1, $2)', [nam, age], (err, results)=>{
			if(err) resolve(null);			
			resolve(results);
		});
	});
}

--adds the given book to the database
function addBook(nam, anam, pnam, wid, yr, isbn, page, price, gen){
	return new Promise(function(resolve){
		client.query('insert into book (name, author_name, publisher_name, warehouse_id, year, ISBN, pages, price, genre) values ($1, $2, $3, $4, $5, $6, $7, $8, $9)', [nam, anam, pnam, wid, yr, isbn, page, price, gen], (err, results)=>{
			if(err) resolve(null);			
			resolve(results);
		});
	});
}

--adds the given address to the database
function addAddress(stno, stn, city, pc){
	return new Promise(function(resolve){
		client.query('insert into address (street_num, street_name, city, postal_code) values ($1, $2, $3, $4)', [stno, stn, city, pc], (err, results)=>{
			if(err) resolve(null);			
			resolve(results);
		});
	});
}

--adds the given user to the database after the user submits registration info
function addUser(un, nam, age, pswd, stno, stn, city, pc){
	return new Promise(function(resolve){
		let addressAdded = addAddress(stno, stn, city, pc);
		addressAdded.then((data)=>{
			client.query('insert into person (username, name, age, password, street_num, street_name) values ($1, $2, $3, $4, $5, $6)', [un, nam, age, pswd, stno, stn], (err, results)=>{
				if(err) resolve(null);			
				resolve(results);
			});
		});
	});
}

--finds the book matching the given name
function findBook(name){
	return new Promise(function(resolve){
		client.query('select * from book where name = $1', [name], (err, results)=>{
			if(err) resolve(null);			
			resolve((!results)? null: results.rows);
		});
	});
}

--searched the books that match the given category's term
function searchBooks(term, cat){
	if(cat == 0){
		return new Promise(function(resolve){
			client.query('select * from book where name like $1', [term], (err, results)=>{
				if(err) resolve(null);			
				resolve((!results)? null: results.rows);
			});
		});
	}else if(cat == 1){
		return new Promise(function(resolve){
			client.query('select * from book where author_name like $1', [term], (err, results)=>{
				if(err) resolve(null);			
				resolve((!results)? null: results.rows);
			});
		});
	}else if(cat == 2){
		return new Promise(function(resolve){
			client.query('select * from book where genre like $1', [term], (err, results)=>{
				if(err) resolve(null);			
				resolve((!results)? null: results.rows);
			});
		});
	}else{
		return new Promise(function(resolve){
			client.query('select * from book where year like $1', [term], (err, results)=>{
				if(err) resolve(null);			
				resolve((!results)? null: results.rows);
			});
		});
	}
	
}

--removed book from database that matches the given name
function removeBook(nam){
	return new Promise(function(resolve){
		client.query('delete from book where name = $1', [nam], (err, results)=>{
			if(err) resolve(null);
			resolve(results);
		});
	});
}

--adds the given order details to the database as an order
function addOrder(nam, bankNum, bankName){
	return new Promise(function(resolve){
		client.query('insert into purchase (username, bank_num, bank_name) values ($1, $2, $3)', [nam, bankNum, bankName], (err, results)=>{
			if(err) resolve(null);
			resolve(results);
		});
	});
}

--adds the given tracking to the database
function addTracking(nam, stNo, stNa){
	return new Promise(function(resolve){
		client.query('insert into tracking (username, street_num, street_name) values ($1, $2, $3)', [nam, stNo, stNa], (err, results)=>{
			if(err) resolve(null);
			resolve(results);
		});
	});
}

--adds the given book orders to the database (bks is an array of book orders)
function addBookOrders(bks){
	let inserts = bks.map(item=>"('" + item.name + "', '" + item.username + "', '" + item.quantity + "')" );
	return new Promise(function(resolve){
		client.query('insert into book_order (name, username, quantity) values ' + inserts, (err, results)=>{
			if(err) resolve(null);
			resolve(results);
		});
	});
}

--returns all the inventory currently in the book store
function getInventory(){
	return new Promise(function(resolve){
		client.query('select * from book', (err, results)=>{
			if(err) resolve(null);			
			resolve((!results)? null: results.rows);
		});
	});
}