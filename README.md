# Taller SQL Genómica

Repositorio del **Taller Grupal de Bases de Datos Genómicas**.  
Este proyecto consiste en el diseño e implementación de una **base de datos relacional** para almacenar información sobre genes, secuencias, variantes, anotaciones y estudios.

---

## Objetivo

Diseñar y construir una base de datos relacional que permita gestionar información genómica aplicando:
- Modelado **Entidad–Relación (E-R)**
- Conversión a **modelo relacional**
- Implementación en **MySQL**
- Inserción de datos válidos e inválidos para validar restricciones

---

## Estructura del repositorio
taller_sql_genomica/
│
├── README.md ← Este archivo
├── diagrama_ER.mmd ← Código Mermaid del diagrama E-R
├── modelo_relacional.md ← Transformación E-R → relacional
│
├── sql/
│ ├── create_tables.sql ← Tablas con PK, FK, CHECK, DEFAULT
│ ├── insert_data.sql ← Datos de ejemplo y casos de prueba
│ └── test_queries.sql ← (Opcional) Consultas de verificación
│
└── docs/
└── informe_final.docx ← Entrega formal del taller



---

## 🧩 Diagrama Entidad–Relación

```mermaid
erDiagram
    GEN {
        int id_gen PK
        string nombre
        string descripcion
        string cromosoma
        int inicio
        int fin
        string hebra
    }

    SECUENCIA {
        int id_secuencia PK
        string cadenaADN
        string tipo
        int pos_relativa
        int id_gen FK
    }

    VARIANTE {
        int id_variante PK
        int pos_relativa
        string al_ref
        string al_alt
        string tipo
        int id_gen FK
    }

    ANOTACION {
        int id_anotacion PK
        string tipo
        string descripcion
        int id_gen FK
    }

    ESTUDIO {
        int id_estudio PK
        string titulo
        date fecha_publicacion
        string referencia
    }

    GEN ||--o{ SECUENCIA : "contiene"
    GEN ||--o{ VARIANTE : "presenta"
    GEN ||--o{ ANOTACION : "tiene"
    ESTUDIO }o--o{ GEN : "analiza"
    ESTUDIO }o--o{ VARIANTE : "analiza"


