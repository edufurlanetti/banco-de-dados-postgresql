-- =============================================================
-- Gestão Acadêmica — Dados de exemplo
-- =============================================================
SET search_path TO academico;

INSERT INTO curso (sigla, nome, duracao_semestres) VALUES
('ADS', 'Análise e Desenvolvimento de Sistemas', 5),
('ENG', 'Engenharia de Computação', 10);

INSERT INTO professor (nome, email, titulacao) VALUES
('Marina Alves',   'marina.alves@faculdade.edu',   'Doutor'),
('Ricardo Nunes',  'ricardo.nunes@faculdade.edu',  'Mestre'),
('Paula Ferreira', 'paula.ferreira@faculdade.edu', 'Doutor');

INSERT INTO disciplina (codigo, nome, carga_horaria, id_curso) VALUES
('ADS101', 'Algoritmos e Lógica de Programação', 80, 1),
('ADS102', 'Banco de Dados I',                   80, 1),
('ADS201', 'Banco de Dados II',                  80, 1),
('ADS202', 'Programação Orientada a Objetos',    80, 1),
('ADS301', 'Desenvolvimento Web',                80, 1),
('ENG101', 'Cálculo I',                          80, 2);

INSERT INTO pre_requisito VALUES
('ADS201', 'ADS102'),
('ADS202', 'ADS101'),
('ADS301', 'ADS202'),
('ADS301', 'ADS102');

INSERT INTO aluno (ra, nome, email, id_curso, ingresso, extras) VALUES
('260001', 'Lucas Pereira',   'lucas@aluno.edu',   1, '2026-02-01', '{"bolsa": "ProUni", "telefones": ["19 99999-0001"]}'),
('260002', 'Mariana Costa',   'mariana@aluno.edu', 1, '2026-02-01', '{"telefones": ["19 99999-0002", "19 3444-0002"]}'),
('260003', 'Pedro Henrique',  'pedro@aluno.edu',   1, '2026-02-01', '{"bolsa": "FIES"}'),
('260004', 'Juliana Ramos',   'juliana@aluno.edu', 1, '2025-08-01', '{"necessidades": {"tipo": "visual", "recurso": "leitor de tela"}}'),
('260005', 'Rafael Santos',   'rafael@aluno.edu',  2, '2026-02-01', '{}'),
('260006', 'Beatriz Oliveira','beatriz@aluno.edu', 1, '2025-08-01', '{"bolsa": "ProUni"}');

INSERT INTO turma (codigo, id_professor, semestre, vagas) VALUES
('ADS101', 2, '2025-2', 40),   -- 1
('ADS102', 1, '2025-2', 40),   -- 2
('ADS101', 2, '2026-1', 40),   -- 3
('ADS102', 1, '2026-1', 3),    -- 4 (turma pequena: teste de vagas)
('ADS202', 3, '2026-1', 40),   -- 5
('ENG101', 3, '2026-1', 50);   -- 6

-- Matrículas do semestre anterior (já encerradas)
INSERT INTO matricula (ra, id_turma, nota1, nota2, frequencia) VALUES
('260004', 1, 8.0, 7.5, 92),
('260004', 2, 5.0, 6.0, 88),
('260006', 1, 9.0, 9.5, 100),
('260006', 2, 7.0, 8.0, 80);

-- Matrículas do semestre atual (notas parciais)
INSERT INTO matricula (ra, id_turma, nota1, frequencia) VALUES
('260001', 3, 7.5, 95),
('260002', 3, 4.0, 70),
('260003', 3, 6.5, 85),
('260001', 4, 8.0, 100),
('260002', 4, 6.0, 90),
('260004', 4, 7.0, 85),
('260004', 5, 6.5, 90),
('260006', 5, 9.0, 98),
('260002', 5, 5.0, 75),   -- cursa POO sem ter concluído Algoritmos
('260005', 6, 5.5, 80);
