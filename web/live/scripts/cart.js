cart = JSON.parse(getCookie("cart"));

function printCart() {
	console.log("Here's your current cart: " + JSON.stringify(cart) + ".");
}

function getCookie(cookieName) {
	const cookies = document.cookie.split("; ");
		for (const cookie of cookies) {
			const [name, value] = cookie.split("=");
			if (name === cookieName) {
				return decodeURIComponent(value);
			}
		}
	return null;
}

function saveCookie(cookieName) {
	document.cookie = "cart=" + JSON.stringify(cart) + ";path=/";
}

function populateProduct() {
	table = document.getElementById("product-table");

	if (!table) { 
		console.log("Page is in 'products' folder, but doesn't contain a table, so I won't do anything with cookies.");
		return;
	}
	
	if (!cart) {
		cart = {}
		saveCookie(cart);
	}
	
	c = 0;
	for (const row of table.children) {
		if (c > 0) {
			code = row.id.replace("row--", "");
			rowEle = document.getElementById("row--" + code);
			qtyEle = document.getElementById("product-qty--" + code);
			if (rowEle != null) { rowEle.style.removeProperty("background"); }
			if (code in cart) {
				if (qtyEle != null) {
					qtyEle.value = cart[code].qty;
				}
				if (cart[code].qty > 0 && rowEle != null) {
					rowEle.style.backgroundColor = "#ffe8bf";
				}
			}
			else {
				if (qtyEle != null) {
					qtyEle.value = 0;
				}
			}
		}
		c += 1
	}
}

// code: individual product SKU
// id: code used by the overall product
// name: human-readable title
// qty: quantity

function addToCart(code, id, name, qty) {
	newQty = document.getElementById("product-qty--" + code).value;
	if (newQty <= 0) {
		newQty = 0;
		delete cart[code];
	}
	else {
		cart[code] = {
			"name": name,
			"qty": qty,
			"id": id
		}
	}
	saveCookie(cart);
	populateProduct();
	printCart();
}

function addToCartNoPopulate(code, id, name, qty) {
	newQty = document.getElementById("product-qty--" + code).value;
	if (newQty <= 0) {
		newQty = 0;
		delete cart[code];
	}
	else {
		cart[code] = {
			"name": name,
			"qty": qty,
			"id": id
		}
	}
	saveCookie(cart);
	printCart();
}

function clearCart() {
	console.log("I'm clearing the cart!");
	cart = {};
	saveCookie(cart);
	location.reload();
}

printCart();

