function checkLogin(usrn, pswd){
	return new Promise(function(resolve){
		client.query('select * from person where username = $1 and password = $2', [usrn, pswd], (err, results)=>{
			if(err) resolve(null);			
			resolve((!results.rows)? null: results.rows);
		});
	});
}

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

function addPublisher(nam, stnum, stn, email, phnum){
	return new Promise(function(resolve){
		client.query('insert into publisher (publisher_name, street_num, street_name, email, phone_num) values ($1, $2, $3, $4, $5)', [nam, stnum, stn, email, phnum], (err, results)=>{
			if(err) resolve(null);			
			resolve(results);
		});
	});
}

function addAuthor(nam, age){
	return new Promise(function(resolve){
		client.query('insert into author (author_name, age) values ($1, $2)', [nam, age], (err, results)=>{
			if(err) resolve(null);			
			resolve(results);
		});
	});
}

function addBook(nam, anam, pnam, wid, yr, isbn, page, price, gen){
	return new Promise(function(resolve){
		client.query('insert into book (name, author_name, publisher_name, warehouse_id, year, ISBN, pages, price, genre) values ($1, $2, $3, $4, $5, $6, $7, $8, $9)', [nam, anam, pnam, wid, yr, isbn, page, price, gen], (err, results)=>{
			if(err) resolve(null);			
			resolve(results);
		});
	});
}

function addAddress(stno, stn, city, pc){
	return new Promise(function(resolve){
		client.query('insert into address (street_num, street_name, city, postal_code) values ($1, $2, $3, $4)', [stno, stn, city, pc], (err, results)=>{
			if(err) resolve(null);			
			resolve(results);
		});
	});
}

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

function findBook(name){
	return new Promise(function(resolve){
		client.query('select * from book where name = $1', [name], (err, results)=>{
			if(err) resolve(null);			
			resolve((!results)? null: results.rows);
		});
	});
}

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

function removeBook(nam){
	return new Promise(function(resolve){
		client.query('delete from book where name = $1', [nam], (err, results)=>{
			if(err) resolve(null);
			resolve(results);
		});
	});
}

function addOrder(nam, bankNum, bankName){
	return new Promise(function(resolve){
		client.query('insert into purchase (username, bank_num, bank_name) values ($1, $2, $3)', [nam, bankNum, bankName], (err, results)=>{
			if(err) resolve(null);
			resolve(results);
		});
	});
}

function addTracking(nam, stNo, stNa){
	return new Promise(function(resolve){
		client.query('insert into tracking (username, street_num, street_name) values ($1, $2, $3)', [nam, stNo, stNa], (err, results)=>{
			if(err) resolve(null);
			resolve(results);
		});
	});
}

function addBookOrders(bks){
	let inserts = bks.map(item=>"('" + item.name + "', '" + item.username + "', '" + item.quantity + "')" );
	return new Promise(function(resolve){
		client.query('insert into book_order (name, username, quantity) values ' + inserts, (err, results)=>{
			if(err) resolve(null);
			resolve(results);
		});
	});
}

function getInventory(){
	return new Promise(function(resolve){
		client.query('select * from book', (err, results)=>{
			if(err) resolve(null);			
			resolve((!results)? null: results.rows);
		});
	});
}