-- ==========================================
-- Taller SQL Genómica
-- Archivo: create_tables.sql
-- Descripción: Creación de tablas y restricciones
-- ==========================================

-- Crear base de datos (solo si no existe)
CREATE DATABASE IF NOT EXISTS genomica;
USE genomica;

-- ==========================================
-- TABLA: GEN
-- ==========================================
CREATE TABLE GEN (
    id_gen INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    cromosoma VARCHAR(10),
    inicio INT,
    fin INT,
    hebra ENUM('+', '-') DEFAULT '+'
);

-- ==========================================
-- TABLA: SECUENCIA
-- ==========================================
CREATE TABLE SECUENCIA (
    id_secuencia INT AUTO_INCREMENT PRIMARY KEY,
    id_gen INT NOT NULL,
    cadenaADN VARCHAR(1000) NOT NULL,
    tipo ENUM('exon', 'intron', 'promotor', 'CDS', 'UTR') NOT NULL,
    pos_relativa INT NOT NULL,
    CONSTRAINT fk_secuencia_gen FOREIGN KEY (id_gen)
        REFERENCES GEN(id_gen)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_longitud_cadena CHECK (CHAR_LENGTH(cadenaADN) BETWEEN 10 AND 1000),
    CONSTRAINT chk_pos_relativa_seq CHECK (pos_relativa > 0)
);

-- ==========================================
-- TABLA: VARIANTE
-- ==========================================
CREATE TABLE VARIANTE (
    id_variante INT AUTO_INCREMENT PRIMARY KEY,
    id_gen INT NOT NULL,
    pos_relativa INT NOT NULL,
    al_ref VARCHAR(10) DEFAULT '-',
    al_alt VARCHAR(10) DEFAULT '-',
    tipo ENUM('SNP', 'insercion', 'delecion', 'indel') NOT NULL,
    CONSTRAINT fk_variante_gen FOREIGN KEY (id_gen)
        REFERENCES GEN(id_gen)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_pos_relativa_var CHECK (pos_relativa > 0)
);

-- ==========================================
-- TABLA: ANOTACION
-- ==========================================
CREATE TABLE ANOTACION (
    id_anotacion INT AUTO_INCREMENT PRIMARY KEY,
    id_gen INT NOT NULL,
    tipo VARCHAR(50),
    descripcion TEXT NOT NULL,
    CONSTRAINT fk_anotacion_gen FOREIGN KEY (id_gen)
        REFERENCES GEN(id_gen)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ==========================================
-- TABLA: ESTUDIO
-- ==========================================
CREATE TABLE ESTUDIO (
    id_estudio INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    fecha_publicacion DATE,
    referencia VARCHAR(20) NOT NULL,
    CONSTRAINT chk_referencia_formato CHECK (referencia REGEXP '^[A-Za-z]{4}/[0-9]{3}$')
);

-- ==========================================
-- TABLAS INTERMEDIAS (RELACIONES N:M)
-- ==========================================

-- Relación ESTUDIO–GEN
CREATE TABLE ESTUDIO_GEN (
    id_estudio INT NOT NULL,
    id_gen INT NOT NULL,
    PRIMARY KEY (id_estudio, id_gen),
    CONSTRAINT fk_estudio_gen_estudio FOREIGN KEY (id_estudio)
        REFERENCES ESTUDIO(id_estudio)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_estudio_gen_gen FOREIGN KEY (id_gen)
        REFERENCES GEN(id_gen)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Relación ESTUDIO–VARIANTE
CREATE TABLE ESTUDIO_VARIANTE (
    id_estudio INT NOT NULL,
    id_variante INT NOT NULL,
    PRIMARY KEY (id_estudio, id_variante),
    CONSTRAINT fk_estudio_var_est FOREIGN KEY (id_estudio)
        REFERENCES ESTUDIO(id_estudio)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_estudio_var_var FOREIGN KEY (id_variante)
        REFERENCES VARIANTE(id_variante)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
