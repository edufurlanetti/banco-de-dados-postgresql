-- =============================================================
-- Gestão Acadêmica — Modelo físico (PostgreSQL 16)
-- Autor: Prof. Eduardo Furlanetti
-- Destaques: schemas, IDENTITY, domínios, tipos ENUM, JSONB,
-- restrições de exclusão, funções PL/pgSQL e views materializadas.
-- =============================================================

DROP SCHEMA IF EXISTS academico CASCADE;
CREATE SCHEMA academico;
SET search_path TO academico;

-- Domínio reutilizável para notas (0 a 10, uma casa decimal)
CREATE DOMAIN nota AS NUMERIC(3,1) CHECK (VALUE BETWEEN 0 AND 10);

CREATE TYPE situacao_matricula AS ENUM ('CURSANDO', 'APROVADO', 'REPROVADO', 'TRANCADO');

CREATE TABLE curso (
    id_curso   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sigla      VARCHAR(10)  NOT NULL UNIQUE,
    nome       VARCHAR(100) NOT NULL,
    duracao_semestres SMALLINT NOT NULL CHECK (duracao_semestres BETWEEN 4 AND 12)
);

CREATE TABLE professor (
    id_professor INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL,
    email        VARCHAR(120) NOT NULL UNIQUE,
    titulacao    VARCHAR(20)  NOT NULL CHECK (titulacao IN ('Especialista','Mestre','Doutor'))
);

CREATE TABLE aluno (
    ra         CHAR(6)      PRIMARY KEY,
    nome       VARCHAR(100) NOT NULL,
    email      VARCHAR(120) NOT NULL UNIQUE,
    id_curso   INT          NOT NULL REFERENCES curso (id_curso),
    ingresso   DATE         NOT NULL,
    -- Dados flexíveis (contatos, necessidades especiais, bolsas...)
    extras     JSONB        NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE disciplina (
    codigo        VARCHAR(8)   PRIMARY KEY,
    nome          VARCHAR(100) NOT NULL,
    carga_horaria SMALLINT     NOT NULL CHECK (carga_horaria > 0),
    id_curso      INT          NOT NULL REFERENCES curso (id_curso)
);

-- Pré-requisitos: relacionamento N:N da disciplina com ela mesma
CREATE TABLE pre_requisito (
    codigo       VARCHAR(8) REFERENCES disciplina (codigo),
    codigo_prereq VARCHAR(8) REFERENCES disciplina (codigo),
    PRIMARY KEY (codigo, codigo_prereq),
    CHECK (codigo <> codigo_prereq)
);

CREATE TABLE turma (
    id_turma     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo       VARCHAR(8) NOT NULL REFERENCES disciplina (codigo),
    id_professor INT        NOT NULL REFERENCES professor (id_professor),
    semestre     CHAR(6)    NOT NULL CHECK (semestre ~ '^\d{4}-[12]$'),  -- ex.: 2026-1
    vagas        SMALLINT   NOT NULL DEFAULT 40,
    UNIQUE (codigo, semestre, id_professor)
);

CREATE TABLE matricula (
    ra        CHAR(6) REFERENCES aluno (ra),
    id_turma  INT     REFERENCES turma (id_turma),
    nota1     nota,
    nota2     nota,
    frequencia NUMERIC(5,2) CHECK (frequencia BETWEEN 0 AND 100),
    situacao  situacao_matricula NOT NULL DEFAULT 'CURSANDO',
    PRIMARY KEY (ra, id_turma)
);

CREATE INDEX ix_aluno_extras ON aluno USING GIN (extras);
