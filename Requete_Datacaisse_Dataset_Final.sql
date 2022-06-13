-- Requête SQL pour connaître les indicateurs des 4 grands axes (Sales / Logistics / Human Ressources / Finances)
USE toys_and_models;

### Tableau centrale

CREATE VIEW Data_Set_Temporel AS ( SELECT
orderdetails.quantityOrdered * orderdetails.priceEach AS Chiffre_Affaire,
orderdetails.quantityOrdered AS Quantite_Commandee,
offices.city AS Ville_vente, offices.country AS Pays_Bureau, 
customers.city AS Ville_Client, customers.country AS Pays_Client,
orders.orderDate AS Date_de_commande,
concat(employees.lastName, ' ', employees.firstName) AS Vendeurs,
products.productName AS Produits, 
productlines.productLine

FROM productlines
		LEFT JOIN products ON productlines.productLine = products.productLine
		LEFT JOIN orderdetails ON products.productCode = orderdetails.productCode
		LEFT JOIN orders ON orderdetails.orderNumber = orders.orderNumber
		LEFT JOIN customers ON orders.customerNumber = customers.customerNumber
		LEFT JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
		LEFT JOIN offices ON employees.officeCode = offices.officeCode
);

SELECT * from Data_Set_Temporel;
DROP VIEW Data_Set_Temporel;

#### Tableau pour calculer le reste à charge

CREATE VIEW Stats_paiements AS( SELECT ###Vue intermédiaire servant à regrouper les paiement par client###
CustomerNumber, SUM(amount) AS montant_paye
FROM payments
GROUP BY customerNumber
);
SELECT * FROM Stats_paiements;
DROP VIEW Stats_paiements;

CREATE VIEW Reste_a_charge AS(
SELECT Stats_paiements.CustomerNumber,
Stats_paiements.montant_paye,
Concat(contactLastName, ' ', contactFirstName) AS Contact_client,
customerName,
customers.city AS Ville_Client,
offices.city AS Ville_Magasins,
SUM(orderdetails.Quantityordered * orderdetails.priceEach) AS montant_a_payer,
SUM(orderdetails.Quantityordered * orderdetails.priceEach) - Stats_paiements.montant_paye AS Reste_a_charge,
customers.creditLimit
FROM Stats_paiements
LEFT JOIN customers ON Stats_paiements.customerNumber = customers.customerNumber
LEFT JOIN orders ON customers.customerNumber = orders.customerNumber
LEFT JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
LEFT JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
LEFT JOIN offices ON employees.officeCode = offices.officeCode
GROUP BY customerNumber 
ORDER BY montant_a_payer
);
SELECT * FROM Reste_a_charge;
DROP VIEW Reste_a_charge;

CREATE VIEW Stocks AS (SELECT 
productName AS Produit,
productline AS Ligne_Produit,
quantityInStock AS Stocks,
SUM(quantityOrdered),
quantityinstock / (SUM(quantityOrdered) / 12) AS Previsions_stock_mois
FROM products
LEFT JOIN orderdetails ON products.productCode = orderdetails.productCode
LEFT JOIN orders ON orderdetails.orderNumber = orders.orderNumber
where orderDate between date_format(now(),"%Y-%m-%d") - interval 12 month and date_format(now(),"%Y-%m-%d")
GROUP BY productName
);
DROP VIEW Stocks;
SELECT * FROM Stocks;




#### Tableau non agregé pour le rapport ressources humaines



#### Tableau non agregé pour le rapport logistique