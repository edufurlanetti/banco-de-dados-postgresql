-- =============================================================
-- Gestão Acadêmica — Funções e triggers em PL/pgSQL
-- Cada função fixa o search_path: assim ela funciona mesmo quando
-- chamada de uma sessão que não está posicionada no schema.
-- =============================================================
SET search_path TO academico;

-- Média final: média aritmética das duas notas.
-- Retorna NULL enquanto alguma nota não foi lançada.
CREATE OR REPLACE FUNCTION media_final(n1 NUMERIC, n2 NUMERIC)
RETURNS NUMERIC
LANGUAGE sql IMMUTABLE
SET search_path = academico
AS $$
    SELECT ROUND((n1 + n2) / 2, 1);
$$;

-- Trigger: define a situação quando as duas notas e a frequência
-- estão lançadas (média >= 6 e frequência >= 75%)
CREATE OR REPLACE FUNCTION fn_atualiza_situacao()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = academico
AS $$
BEGIN
    IF NEW.situacao <> 'TRANCADO'
       AND NEW.nota1 IS NOT NULL AND NEW.nota2 IS NOT NULL
       AND NEW.frequencia IS NOT NULL THEN
        IF media_final(NEW.nota1, NEW.nota2) >= 6 AND NEW.frequencia >= 75 THEN
            NEW.situacao := 'APROVADO';
        ELSE
            NEW.situacao := 'REPROVADO';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_situacao
BEFORE INSERT OR UPDATE OF nota1, nota2, frequencia ON matricula
FOR EACH ROW EXECUTE FUNCTION fn_atualiza_situacao();

-- Trigger: impede matrícula acima do número de vagas
CREATE OR REPLACE FUNCTION fn_controla_vagas()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = academico
AS $$
DECLARE
    v_ocupadas INT;
    v_vagas    INT;
BEGIN
    SELECT vagas INTO v_vagas FROM turma WHERE id_turma = NEW.id_turma FOR UPDATE;
    SELECT COUNT(*) INTO v_ocupadas FROM matricula WHERE id_turma = NEW.id_turma;

    IF v_ocupadas >= v_vagas THEN
        RAISE EXCEPTION 'Turma % sem vagas (% de %)', NEW.id_turma, v_ocupadas, v_vagas;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_vagas
BEFORE INSERT ON matricula
FOR EACH ROW EXECUTE FUNCTION fn_controla_vagas();

-- Função que retorna tabela: histórico escolar de um aluno
CREATE OR REPLACE FUNCTION historico(p_ra CHAR(6))
RETURNS TABLE (semestre CHAR(6), disciplina VARCHAR, media NUMERIC, frequencia NUMERIC, situacao situacao_matricula)
LANGUAGE sql STABLE
SET search_path = academico
AS $$
    SELECT t.semestre, d.nome, media_final(m.nota1, m.nota2), m.frequencia, m.situacao
    FROM matricula m
    JOIN turma t      ON t.id_turma = m.id_turma
    JOIN disciplina d ON d.codigo   = t.codigo
    WHERE m.ra = p_ra
    ORDER BY t.semestre, d.nome;
$$;
