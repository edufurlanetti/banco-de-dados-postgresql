# Lista de exercícios — Gestão Acadêmica (PostgreSQL)

Execute antes os scripts `01` a `03` da pasta `scripts/`.

1. Liste os alunos do curso de ADS com o semestre de ingresso no formato `2026-1` (use `EXTRACT`).
2. Para cada disciplina, mostre quantos pré-requisitos diretos ela possui (inclusive zero).
3. Mostre os alunos que estão cursando alguma disciplina **sem** ter sido aprovados em todos os pré-requisitos dela.
4. Adicione o telefone `19 98888-0003` ao campo `extras` do aluno `260003` sem apagar as demais chaves (use `jsonb_set` ou o operador `||`).
5. Crie a função `cr(p_ra)` que retorne o coeficiente de rendimento do aluno: média das médias finais ponderada pela carga horária, considerando apenas disciplinas concluídas.
6. Usando `LAG`, mostre para cada aluno a variação entre a média do semestre atual e a do semestre anterior.
7. Explique a diferença entre `VIEW` e `MATERIALIZED VIEW` e quando usar cada uma.

As soluções estão em [`solucoes.sql`](solucoes.sql).
