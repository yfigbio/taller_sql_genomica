-- ==========================================
-- Taller SQL Genómica
-- Archivo: insert_data.sql
-- Descripción: Inserción de datos (válidos + pruebas de fallo)
-- Requiere: create_tables.sql ya ejecutado
-- ==========================================
USE genomica;


-- Para que un fallo no detenga todo el script:
SET autocommit = 0;
SET sql_warnings = 1;
SET SESSION sql_mode = 'STRICT_TRANS_TABLES';




-- ==========================================
-- GEN (válidos)
-- ==========================================
START TRANSACTION;


INSERT INTO GEN (nombre, descripcion, cromosoma, inicio, fin, hebra) VALUES
('BRCA1', 'Gen asociado a reparación del ADN', '17', 43044295, 43125482, '-'),
('CFTR',  'Canal de cloro; fibrosis quística',  '7', 116907253, 117095955, '+'),
('TP53',  'Supresor tumoral p53',               '17', 7668402,   7687550,  '+');


COMMIT;


-- Índices útiles (opcional pero recomendable)
START TRANSACTION;
CREATE INDEX idx_variante_gen_pos ON VARIANTE(id_gen, pos_relativa);
CREATE INDEX idx_secuencia_gen_pos ON SECUENCIA(id_gen, pos_relativa);
COMMIT;


-- ==========================================
-- SECUENCIA (válidos)
-- ==========================================
START TRANSACTION;


INSERT INTO SECUENCIA (id_gen, cadenaADN, tipo, pos_relativa) VALUES
-- Secuencias para BRCA1 (id_gen = 1)
(1, 'ATGCGTACGTATGCGTACGT', 'exon',     1),
(1, 'GCTAGCTAGCTAGCTAGCTA', 'intron',   2),
(1, 'TTGACATGACATGACATGAC', 'promotor', 3),


-- Secuencias para CFTR (id_gen = 2)
(2, 'ATGATGATGATGATGATGAT', 'CDS',      1),
(2, 'CGTAGCTAGCTAGCTAGCTA', 'UTR',      2);


COMMIT;


-- ==========================================
-- SECUENCIA (casos que deben FALLAR)
-- ==========================================
START TRANSACTION;
SAVEPOINT sp_seq_len;


-- Longitud < 10 → debe fallar por CHECK (10–1000)
INSERT INTO SECUENCIA (id_gen, cadenaADN, tipo, pos_relativa)
VALUES (1, 'ATGCGTACG', 'exon', 4);
-- EXPECTED: FAIL (chk_longitud_cadena)


ROLLBACK TO SAVEPOINT sp_seq_len;
RELEASE SAVEPOINT sp_seq_len;


SAVEPOINT sp_seq_pos;


-- pos_relativa <= 0 → debe fallar por CHECK (>0)
INSERT INTO SECUENCIA (id_gen, cadenaADN, tipo, pos_relativa)
VALUES (1, 'ATGCGTACGTATGCGTACGT', 'exon', 0);
-- EXPECTED: FAIL (chk_pos_relativa_seq)


ROLLBACK TO SAVEPOINT sp_seq_pos;
RELEASE SAVEPOINT sp_seq_pos;


SAVEPOINT sp_seq_enum;


-- tipo no permitido → debe fallar por ENUM
INSERT INTO SECUENCIA (id_gen, cadenaADN, tipo, pos_relativa)
VALUES (1, 'ATGCGTACGTATGCGTACGT', 'enhancer', 5);
-- EXPECTED: FAIL (ENUM tipos permitidos: exon,intron,promotor,CDS,UTR,otro)


ROLLBACK TO SAVEPOINT sp_seq_enum;
RELEASE SAVEPOINT sp_seq_enum;


COMMIT;


-- ==========================================
-- VARIANTE (válidos)
-- ==========================================
START TRANSACTION;


INSERT INTO VARIANTE (id_gen, pos_relativa, al_ref, al_alt, tipo) VALUES
-- Variantes en BRCA1 (id_gen = 1)
(1, 100, 'A',  'G',  'SNP'),
(1, 250, 'C',  '-',  'delecion'),
(1, 400, '-',  'T',  'insercion'),


-- Variantes en CFTR (id_gen = 2)
(2, 50,  'G',  'A',  'SNP'),
(2, 120, 'CT', '-',  'delecion');


-- Comprobación del DEFAULT '-' en al_ref y al_alt
INSERT INTO VARIANTE (id_gen, pos_relativa, tipo)
VALUES (2, 300, 'SNP');  -- al_ref y al_alt tomarán '-'


COMMIT;


-- ==========================================
-- VARIANTE (casos que deben FALLAR)
-- ==========================================
START TRANSACTION;
SAVEPOINT sp_var_pos;


-- pos_relativa <= 0 → debe fallar por CHECK (>0)
INSERT INTO VARIANTE (id_gen, pos_relativa, al_ref, al_alt, tipo)
VALUES (1, 0, 'A', 'T', 'SNP');
-- EXPECTED: FAIL (chk_pos_relativa_var)


ROLLBACK TO SAVEPOINT sp_var_pos;
RELEASE SAVEPOINT sp_var_pos;


SAVEPOINT sp_var_enum;


-- tipo no permitido → debe fallar por ENUM
INSERT INTO VARIANTE (id_gen, pos_relativa, al_ref, al_alt, tipo)
VALUES (1, 10, 'A', 'T', 'SNV');
-- EXPECTED: FAIL (ENUM tipos permitidos: SNP,insercion,delecion,indel)


ROLLBACK TO SAVEPOINT sp_var_enum;
RELEASE SAVEPOINT sp_var_enum;


COMMIT;


-- ==========================================
-- ANOTACION (válidos)
-- ==========================================
START TRANSACTION;


-- Anotaciones asociadas a genes
INSERT INTO ANOTACION (id_gen, id_variante, tipo, descripcion) VALUES
(1, NULL, 'funcional', 'Participa en reparación del ADN por recombinación homóloga'),
(2, NULL, 'clínica',   'Mutaciones asociadas a fibrosis quística'),
(3, NULL, 'funcional', 'Regulación del ciclo celular y apoptosis');


-- Anotación asociada a una variante concreta
-- (asumiendo que existe la variante con id_variante = 1)
INSERT INTO ANOTACION (id_gen, id_variante, tipo, descripcion) VALUES
(1, 1, 'clínica', 'Variante asociada a aumento de riesgo tumoral');


COMMIT;


-- ==========================================
-- ANOTACION (casos que deben FALLAR)
-- ==========================================
START TRANSACTION;
SAVEPOINT sp_anot_null;


-- descripcion NOT NULL → debe fallar
INSERT INTO ANOTACION (id_gen, id_variante, tipo, descripcion)
VALUES (1, NULL, 'funcional', NULL);
-- EXPECTED: FAIL (descripcion NOT NULL)


ROLLBACK TO SAVEPOINT sp_anot_null;
RELEASE SAVEPOINT sp_anot_null;


COMMIT;


-- ==========================================
-- ESTUDIO (válidos)
-- Formato referencia: ^[A-Za-z]{4}/[0-9]{3}$
-- ==========================================
START TRANSACTION;


INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia) VALUES
('Estudio de reparación BRCA1', DATE '2021-05-12', 'abcd/123'),
('Genómica clínica CFTR',       DATE '2022-11-03', 'EFGH/007'),
('Papel de TP53 en cáncer',     DATE '2020-01-20', 'Wxyz/999');


COMMIT;


-- ==========================================
-- ESTUDIO (casos que deben FALLAR)
-- ==========================================
START TRANSACTION;
SAVEPOINT sp_ref_fmt1;


-- Falta barra o dígitos → debe fallar por CHECK del regexp
INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia)
VALUES ('Ref mal formateada 1', DATE '2024-02-02', 'abc123');
-- EXPECTED: FAIL (chk_referencia_formato)


ROLLBACK TO SAVEPOINT sp_ref_fmt1;
RELEASE SAVEPOINT sp_ref_fmt1;


SAVEPOINT sp_ref_fmt2;


-- Letras < 4 y/o dígitos < 3 → debe fallar por el formato definido
INSERT INTO ESTUDIO (titulo, fecha_publicacion, referencia)
VALUES ('Ref mal formateada 2', DATE '2024-05-10', 'ab/12');
-- EXPECTED: FAIL (no cumple el patrón de 4 letras + '/' + 3 dígitos)


ROLLBACK TO SAVEPOINT sp_ref_fmt2;
RELEASE SAVEPOINT sp_ref_fmt2;
COMMIT;




SELECT * FROM GEN;
SELECT * FROM SECUENCIA;
SELECT * FROM VARIANTE;
SELECT * FROM ANOTACION;
SELECT * FROM ESTUDIO;


