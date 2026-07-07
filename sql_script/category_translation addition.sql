SELECT * FROM staging_products p
LEFT JOIN staging_category_translation n
ON p.product_category_name = n.product_category_name
WHERE n.product_category_name IS NULL and p.product_category_name IS NOT NULL;

INSERT INTO staging_category_translation
VALUES ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_food_gadget'),
		('pc_gamer', 'pc_gamer');
