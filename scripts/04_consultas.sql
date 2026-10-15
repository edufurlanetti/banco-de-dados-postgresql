-- =============================================================
-- Gestão Acadêmica — Consultas comentadas
-- =============================================================
SET search_path TO academico;

-- 1. Situação dos alunos no semestre 2025-2 (calculada pela trigger)
SELECT a.nome, d.nome AS disciplina,
       media_final(m.nota1, m.nota2) AS media, m.frequencia, m.situacao
FROM matricula m
JOIN aluno a      ON a.ra = m.ra
JOIN turma t      ON t.id_turma = m.id_turma
JOIN disciplina d ON d.codigo = t.codigo
WHERE t.semestre = '2025-2'
ORDER BY a.nome;

-- 2. Função que retorna tabela: histórico escolar
SELECT * FROM historico('260004');

-- 3. Agregação com FILTER: resumo por turma
SELECT t.id_turma, d.nome, t.semestre,
       COUNT(*)                                        AS matriculados,
       COUNT(*) FILTER (WHERE m.situacao = 'APROVADO')  AS aprovados,
       COUNT(*) FILTER (WHERE m.situacao = 'REPROVADO') AS reprovados,
       t.vagas - COUNT(*)                              AS vagas_livres
FROM turma t
JOIN disciplina d     ON d.codigo   = t.codigo
LEFT JOIN matricula m ON m.id_turma = t.id_turma
GROUP BY t.id_turma, d.nome, t.semestre, t.vagas
ORDER BY t.semestre, d.nome;

-- 4. Funções de janela: ranking da nota 1 dentro de cada turma
SELECT t.id_turma, a.nome, m.nota1,
       DENSE_RANK() OVER (PARTITION BY t.id_turma ORDER BY m.nota1 DESC) AS posicao,
       ROUND(AVG(m.nota1) OVER (PARTITION BY t.id_turma), 2)            AS media_turma
FROM matricula m
JOIN aluno a ON a.ra = m.ra
JOIN turma t ON t.id_turma = m.id_turma
WHERE t.semestre = '2026-1'
ORDER BY t.id_turma, posicao;

-- 5. JSONB: alunos com bolsa e o tipo de bolsa
SELECT nome, extras ->> 'bolsa' AS bolsa
FROM aluno
WHERE extras ? 'bolsa';

-- 6. JSONB: expandir o vetor de telefones em linhas
SELECT a.nome, tel.numero
FROM aluno a
CROSS JOIN LATERAL jsonb_array_elements_text(a.extras -> 'telefones') AS tel(numero);

-- 7. JSONB com operador de contenção (usa o índice GIN)
SELECT nome FROM aluno WHERE extras @> '{"bolsa": "ProUni"}';

-- 8. CTE recursiva: todos os pré-requisitos (diretos e indiretos) de ADS301
WITH RECURSIVE cadeia AS (
    SELECT codigo_prereq, 1 AS nivel
    FROM pre_requisito WHERE codigo = 'ADS301'
    UNION
    SELECT p.codigo_prereq, c.nivel + 1
    FROM pre_requisito p
    JOIN cadeia c ON p.codigo = c.codigo_prereq
)
SELECT c.nivel, d.codigo, d.nome
FROM cadeia c
JOIN disciplina d ON d.codigo = c.codigo_prereq
ORDER BY c.nivel, d.codigo;

-- 9. STRING_AGG: disciplinas de cada professor
SELECT p.nome, p.titulacao,
       STRING_AGG(DISTINCT d.nome, ', ' ORDER BY d.nome) AS disciplinas
FROM professor p
JOIN turma t      ON t.id_professor = p.id_professor
JOIN disciplina d ON d.codigo = t.codigo
GROUP BY p.nome, p.titulacao;

-- 10. View materializada: indicadores do curso (atualizada sob demanda)
DROP MATERIALIZED VIEW IF EXISTS mv_indicadores;
CREATE MATERIALIZED VIEW mv_indicadores AS
SELECT c.sigla,
       COUNT(DISTINCT a.ra)                                         AS alunos,
       ROUND(AVG(media_final(m.nota1, m.nota2))
             FILTER (WHERE m.situacao IN ('APROVADO','REPROVADO')), 2) AS media_geral,
       ROUND(100.0 * COUNT(*) FILTER (WHERE m.situacao = 'APROVADO')
             / NULLIF(COUNT(*) FILTER (WHERE m.situacao IN ('APROVADO','REPROVADO')), 0), 1)
                                                                    AS taxa_aprovacao
FROM curso c
JOIN aluno a          ON a.id_curso = c.id_curso
LEFT JOIN matricula m ON m.ra = a.ra
GROUP BY c.sigla;

SELECT * FROM mv_indicadores;
-- Após novos lançamentos: REFRESH MATERIALIZED VIEW mv_indicadores;

-- 11. Lançamento da nota 2 dispara a trigger de situação
UPDATE matricula SET nota2 = 8.0 WHERE ra = '260001' AND id_turma = 3;
SELECT ra, nota1, nota2, frequencia, situacao FROM matricula WHERE ra = '260001' AND id_turma = 3;

-- 12. Controle de vagas: a turma 4 tem 3 vagas e já está cheia.
--     Este comando deve falhar com "Turma 4 sem vagas (3 de 3)".
-- INSERT INTO matricula (ra, id_turma) VALUES ('260003', 4);
