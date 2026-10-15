-- Soluções — Gestão Acadêmica (PostgreSQL)
SET search_path TO academico;

-- 1
SELECT a.ra, a.nome,
       EXTRACT(YEAR FROM a.ingresso) || '-' ||
       CASE WHEN EXTRACT(MONTH FROM a.ingresso) <= 6 THEN '1' ELSE '2' END AS semestre_ingresso
FROM aluno a
JOIN curso c ON c.id_curso = a.id_curso
WHERE c.sigla = 'ADS'
ORDER BY a.nome;

-- 2
SELECT d.codigo, d.nome, COUNT(p.codigo_prereq) AS qtd_prerequisitos
FROM disciplina d
LEFT JOIN pre_requisito p ON p.codigo = d.codigo
GROUP BY d.codigo, d.nome
ORDER BY d.codigo;

-- 3
SELECT DISTINCT a.nome, t.codigo AS cursando, p.codigo_prereq AS prerequisito_pendente
FROM matricula m
JOIN aluno a          ON a.ra = m.ra
JOIN turma t          ON t.id_turma = m.id_turma
JOIN pre_requisito p  ON p.codigo = t.codigo
WHERE m.situacao = 'CURSANDO'
  AND NOT EXISTS (
        SELECT 1
        FROM matricula m2
        JOIN turma t2 ON t2.id_turma = m2.id_turma
        WHERE m2.ra = m.ra
          AND t2.codigo = p.codigo_prereq
          AND m2.situacao = 'APROVADO');

-- 4
UPDATE aluno
   SET extras = jsonb_set(extras, '{telefones}',
                          COALESCE(extras -> 'telefones', '[]'::jsonb) || '"19 98888-0003"'::jsonb)
 WHERE ra = '260003';
SELECT ra, extras FROM aluno WHERE ra = '260003';

-- 5
CREATE OR REPLACE FUNCTION cr(p_ra CHAR(6))
RETURNS NUMERIC
LANGUAGE sql STABLE
SET search_path = academico
AS $$
    SELECT ROUND(SUM(media_final(m.nota1, m.nota2) * d.carga_horaria) / SUM(d.carga_horaria), 2)
    FROM matricula m
    JOIN turma t      ON t.id_turma = m.id_turma
    JOIN disciplina d ON d.codigo   = t.codigo
    WHERE m.ra = p_ra AND m.situacao IN ('APROVADO', 'REPROVADO');
$$;

SELECT ra, nome, cr(ra) AS coeficiente FROM aluno ORDER BY coeficiente DESC NULLS LAST;

-- 6
WITH medias AS (
    SELECT m.ra, t.semestre, AVG(media_final(m.nota1, m.nota2)) AS media
    FROM matricula m
    JOIN turma t ON t.id_turma = m.id_turma
    GROUP BY m.ra, t.semestre
)
SELECT ra, semestre, ROUND(media, 2) AS media,
       ROUND(media - LAG(media) OVER (PARTITION BY ra ORDER BY semestre), 2) AS variacao
FROM medias
ORDER BY ra, semestre;

-- 7
-- VIEW: é apenas uma consulta salva; os dados são lidos das tabelas a cada uso,
--       portanto estão sempre atualizados.
-- MATERIALIZED VIEW: guarda fisicamente o resultado; a leitura é rápida, mas
--       os dados só mudam após REFRESH MATERIALIZED VIEW. Indicada para
--       relatórios pesados que toleram alguma defasagem (ex.: indicadores).
