-- 1. Nom des lieux qui finissent par 'um'.
SELECT nom_lieu
FROM lieu
WHERE nom_lieu LIKE "%um%" 


-- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).
SELECT COUNT(id_personnage)AS nbPerso,nom_lieu
FROM personnage
INNER JOIN lieu 
ON personnage.id_lieu = lieu.id_lieu
GROUP BY nom_lieu
HAVING COUNT(id_personnage)>1
ORDER BY nbPerso DESC  


-- 3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.
SELECT nom_personnage, nom_specialite, adresse_personnage, nom_lieu
FROM ((personnage
INNER JOIN specialite ON personnage.id_specialite = specialite.id_specialite)
INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu)
ORDER BY nom_lieu, nom_personnage


-- 4. Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).
SELECT nom_specialite, COUNT(id_personnage) 
AS nbPerso
FROM personnage 
INNER JOIN specialite 
ON personnage.id_specialite = specialite.id_specialite
GROUP BY nom_specialite
ORDER BY nbPerso DESC 


-- 5. Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).
SELECT nom_bataille,DATE_FORMAT(date_bataille, "%d/%m/%Y") AS date ,nom_lieu
FROM bataille
INNER JOIN lieu 
ON bataille.id_lieu = lieu.id_lieu
ORDER BY YEAR(date_bataille) DESC   


-- 6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).
SELECT nom_potion, SUM(cout_ingredient)AS prix
FROM ((composer  
INNER JOIN potion ON potion.id_potion = composer.id_potion)
INNER JOIN ingredient ON ingredient.id_ingredient = composer.id_ingredient)
GROUP BY nom_potion


-- 7. Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.
SELECT nom_potion,nom_ingredient, cout_ingredient,qte
FROM ((composer 
INNER JOIN ingredient
ON ingredient.id_ingredient = composer.id_ingredient)
INNER JOIN potion
ON potion.id_potion = composer.id_potion)
WHERE nom_potion = "Santé"


-- 8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.
SELECT nom_personnage, SUM(qte) AS nbCasque
FROM ((prendre_casque 
INNER JOIN personnage
ON prendre_casque.id_personnage = personnage.id_personnage)
INNER JOIN bataille
ON prendre_casque.id_bataille = bataille.id_bataille)
WHERE nom_bataille = "Bataille du village gaulois"
GROUP BY nom_personnage  
ORDER BY nbCasque DESC
LIMIT 1


-- 9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).
SELECT nom_personnage, dose_boire
FROM boire
INNER JOIN personnage
ON boire.id_personnage = personnage.id_personnage
ORDER BY dose_boire DESC 


-- 10. Nom de la bataille où le nombre de casques pris a été le plus important.
SELECT nom_bataille, SUM(qte) AS nbCasque
FROM prendre_casque
INNER JOIN bataille
ON prendre_casque.id_bataille = bataille.id_bataille
GROUP BY nom_bataille
ORDER BY nbCasque DESC
LIMIT 1;


-- 11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)
SELECT nom_type_casque, COUNT(nom_casque) AS nbCasque,
SUM(cout_casque) AS pTotal
FROM casque
INNER JOIN type_casque
ON casque.id_type_casque = type_casque.id_type_casque
GROUP BY nom_type_casque
ORDER BY pTotal DESC 


-- 12. Nom des potions dont un des ingrédients est le poisson frais.
SELECT nom_potion, nom_ingredient
FROM composer
INNER JOIN potion
ON composer.id_potion = potion.id_potion
INNER JOIN ingredient
ON composer.id_ingredient = ingredient.id_ingredient
WHERE nom_ingredient = "Poisson frais"


-- 13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois
SELECT COUNT(nom_personnage) AS nbPerso, nom_lieu
FROM personnage
INNER JOIN lieu
ON personnage.id_lieu = lieu.id_lieu
WHERE nom_lieu NOT LIKE 'Village gaulois'
GROUP BY nom_lieu
ORDER BY nbPerso DESC 
LIMIT 2


-- 14. Nom des personnages qui n'ont jamais bu aucune potion.
SELECT nom_personnage, dose_boire
FROM personnage
LEFT JOIN boire 
ON personnage.id_personnage = boire.id_personnage
WHERE boire.id_personnage IS NULL 


-- 15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.
SELECT nom_personnage
FROM personnage
WHERE id_personnage NOT IN (
	SELECT id_personnage
	FROM autoriser_boire
	INNER JOIN potion
	ON potion.id_potion = autoriser_boire.id_potion
	WHERE nom_potion = 'Magique'
)



-- A. Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.
INSERT INTO personnage (nom_personnage, adresse_personnage,id_lieu,id_specialite)
VALUES ("Champdeblix", "ferme Hantassion", 6, 12)


-- B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...
INSERT INTO autoriser_boire (id_potion, id_personnage)
VALUES (1, 12)


-- C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille
DELETE FROM casque
WHERE id_type_casque = 2
AND id_casque NOT IN (
  SELECT id_casque FROM prendre_casque
)


-- D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.
UPDATE personnage       
SET id_lieu = 9         
WHERE id_personnage = 23


-- E. La potion 'Soupe' ne doit plus contenir de persil.
DELETE FROM composer
WHERE id_potion = 9 AND gauloisid_ingredient = 19


-- F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la
-- bataille 'Attaque de la banque postale'. Corrigez son erreur !
UPDATE prendre_casque
SET id_casque = 10 
WHERE qte = 42
