const express = require('express');
const session = require('express-session');
const {Pool, Client} = require('pg');
const connectionString = 'postgressql://postgres:PASS@localhost:5432/bookstore'; //CHANGE

const client = new Client({
	connectionString : connectionString
});

client.connect();

const app = express();

app.set("view engine", "pug");
app.use(express.static("public"));
app.use(express.json());

//Set app session containing the mongodb
app.use(session({
	secret : 'secret',
	cookie : {maxAge:300000},
	logged : false,
	owner  : false,
}));

app.use(function(req, res, next){
	res.locals.session = req.session;
	next();
})

app.post('/login', function(req, res, next){
	let finished = getCredentials(req);

	finished.then((creds)=>{
		let userRes = creds[1];
		let passRes = creds[3];
		let userFound = checkLogin(userRes, passRes);
		
		userFound.then((data)=>{
			if(data == null || data.length <= 0){
				req.session.logged = false;
				res.redirect('/');
				return;
			}else{
				req.session.logged = true;
				req.session.username = creds[1];
				req.session.name = data[0].name;
				if(data[0].kind_id == '1'){
					console.log('owner');
					req.session.owner = true;
				}
				
				let userOrders = getOrders(req.session);
				userOrders.then((orderData)=>{
					req.session.orders = orderData;
					res.render('pages/user', {user:req.session});
					return;
				});
			}
		});
	});
})

app.get('/register', function(req, res, next){
	res.status(200).render('pages/register', {user:req.session});
	return;
});

app.get('/user', function(req, res, next){
	res.render('pages/user', {user:req.session});
})

app.post('/registered', function(req, res, next){
	let newUser = getCredentials(req);
	let result = {};

	newUser.then((creds)=>{
		let userAdded = addUser(creds[1], creds[3], creds[5], creds[7], creds[9], creds[11], creds[13], creds[15]);
		
		userAdded.then((data)=>{
			req.session.logged = true;
			req.session.username = creds[1];
			req.session.name = creds[3];
			req.session.orders = [];
			res.render('pages/user', {user:req.session});
			return;
		});
	});
})

app.post('/insertBook', function(req, res, next){
	let newBook = getCredentials(req);
	
	newBook.then((data)=>{
		let addressAdded = addAddress(data[9], data[11], data[13], data[15]);
		addressAdded.then((addData)=>{
			let publisherAdded = addPublisher(data[7], data[9], data[11], data[17], data[19]);
			publisherAdded.then((pubData)=>{
				let authorAdded = addAuthor(data[3], data[5]);
				authorAdded.then((auData)=>{
					let bookAdded = addBook(data[1], data[3], data[7], '1', data[21], data[23], data[25], data[27], data[29]);
					bookAdded.then((bkData)=>{
						res.redirect('/');
					});
				});
			});
		});
	});
});

app.get('/book/:bookID', function(req, res, next){
	let result = findBook(req.params.bookID)
	
	result.then((found)=>{
		res.render('pages/book', {user:req.session, book:found[0]});
		return;
	});
})

app.post('/searchBook', function(req, res, next){
	let query = getCredentials(req);
	
	query.then((creds)=>{
		let term = '%';
		let cat = 0;
		for(let i=0; i<creds.length/2; i++){
			if(creds[i*2+1].length > 0){
				combo = creds[i*2+1].split('+');
				cat = i;
				break;
			}
		}
		for(let i=0; i<combo.length; i++){
			term += combo[i];
			if(i < combo.length-1){
				term += ' ';
			}else{
				term += '%';
			}
		}
		
		let bookSearch = searchBooks(term, cat);
		
		bookSearch.then((data)=>{
			res.render('pages/store', {user:req.session, books:data});
			return;
		});
	});
})

app.post('/complete', function(req, res, next){
	let info = getCredentials(req);
	
	info.then((creds)=>{
		let oName = creds[1];
		let oBank = parseInt(creds[3]);
		let stNo = parseInt(creds[5]);
		let stNa = creds[7];
		let oCity = creds[9];
		let oPC = creds[11];
		
		let orderAdded = addOrder(req.session.username, oBank, oName);
		
		orderAdded.then((data)=>{
			let addressAdded = addAddress(stNo, stNa, oCity, oPC);
			
			addressAdded.then((response)=>{
				
				let books = [];
				for(let i=0; i<req.session.cart.length; i++){
					if(req.session.cart[i].quant > 0){
						let bookOrder = {};
						bookOrder.name = req.session.cart[i].bookId;
						bookOrder.username = req.session.username;
						bookOrder.quantity = req.session.cart[i].quant;
						books.push(bookOrder);
					}
				}
				
				let booksAdded = addBookOrders(books);
				
				booksAdded.then((booksData)=>{
					let trackingAdded = addTracking(req.session.username, stNo, stNa);
					
					trackingAdded.then((last)=>{
						let newOrders = getOrders(req.session);
						newOrders.then((finalData)=>{
							req.session.orders = finalData;
							res.render('pages/user', {user:req.session});
							return;
						});
					});
				});
			});
		});
	});
})

app.post('/checkout', function(req, res, next){
	let item = getCredentials(req);
	let cart = [];
	
	item.then((creds)=>{
		cart.total = 0;
		if(req.session.owner){
			for(let i=0; i<creds.length/2; i++){
				if(creds[i*2 + 1] > 0){
					let combo = creds[i*2].replace(/[+]/g, ' ');
					let bTitle = combo.split('%')[0];
					let bookRemoved = removeBook(bTitle);
					bookRemoved.then((remData)=>{
						res.redirect('/');
					});
				}
			}
		}else{
			for(let i=0; i<creds.length/2; i++){
				let combo = creds[i*2].replace(/[+]/g, ' ');
				let namePrice = combo.split('%');
				let bPrice = parseFloat(namePrice[1].slice(2, namePrice[1].length));
				let bTotal = bPrice*creds[i*2 + 1];
				
				cart.total += bTotal;
				cart.push({bookId:namePrice[0], quant:creds[i*2 + 1], bookTotal:bTotal});
			}
			
			req.session.cart = cart;
			
			res.render('pages/cart', {user:req.session, cart:cart});
			return;
		}
	});
})

app.get('/logout', function(req, res, next){
	req.session.destroy(function(err){
		if(err){
			res.status(500).send("Error logging out");
		}
		res.redirect('/');
		return;
	});
})

app.get('/', function(req, res, next) {
	let curBooks = getInventory();
	
	curBooks.then((data)=>{
		res.render("pages/store", {books: data, user:req.session});
		return;
	});
});

//Returns a resolved promise with the username and password entered
function getCredentials(req){
	let creds = [];

	return new Promise(function(resolve){
		req.on('data', (chunk)=>{
			let combo = chunk.toString();
			combo = combo.split("=");
			
			creds[0] = combo[0];
			for(let i=1; i<combo.length-1; i++){
				let duo = combo[i].split("&");
				creds.push(duo[0]);
				creds.push(duo[1]);
			}
			creds[creds.length] = combo[combo.length-1];
			resolve(creds);
		})
	});
}

//Returns a resolved promise with the user if there is a matching username/password
function checkLogin(usrn, pswd){
	return new Promise(function(resolve){
		client.query('select * from person where username = $1 and password = $2', [usrn, pswd], (err, results)=>{
			if(err) resolve(null);			
			resolve((!results.rows)? null: results.rows);
		});
	});
}

//Returns a resolved promise with the users orders
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


//Returns a resolved promise with the matching the specified name
function findBook(name){
	return new Promise(function(resolve){
		client.query('select * from book where name = $1', [name], (err, results)=>{
			if(err) resolve(null);			
			resolve((!results)? null: results.rows);
		});
	});
}

//Returns a resolved promise with all matching books depeing on the category searched
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


app.listen(3000);
console.log("Server listening on port 3000");