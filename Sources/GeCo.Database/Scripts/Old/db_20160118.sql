ALTER TABLE correzione_diaria ADD corr_segno varchar(1) DEFAULT ('+');

update correzione_diaria set corr_segno = '+';