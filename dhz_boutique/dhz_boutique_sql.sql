ALTER TABLE `users`
  	Add	`pointboutique` int(11) NOT NULL DEFAULT 0
;

CREATE TABLE `boutique_historique` (
    `id` INT NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(40) NOT NULL,
	`achat` LONGTEXT NULL DEFAULT NULL,
	`prix` VARCHAR(50) NULL DEFAULT NULL,

	PRIMARY KEY (`id`)
);