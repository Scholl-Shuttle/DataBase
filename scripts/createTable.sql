 -- ==========================================================
-- BANCO DE DADOS: Transporte Escolar
-- DESENVOLVIDO POR: Matheus Cerqueira
-- OBJETIVO: Gerenciar transporte, motoristas, crianças, rotas e pagamentos
-- ==========================================================

-- 🧩 1. TABELA DE USUÁRIOS
-- tabela generica onde vai guardar dados de acesso
-- (login, senha, tipo, data de criação e etc).
create table usuarios(
	user_id serial primary key,
	nome varchar(100) not null,
	email varchar(100) not null,
	senha_hash varchar(255) not null,
	tel_user varchar(15) not null,
	tipo_user varchar(20) check (tipo_user in ('responsavel', 'motorista', 'admim')),
	create_date date default current_date,
	update_date date default current_date
);



-- 🧩 2. TABELA DE ENDEREÇOS
-- guardar dados específicos de endereços
-- (rua, bairro, cep e etc).
CREATE TABLE enderecos (
    endereco_id SERIAL PRIMARY KEY,
    rua VARCHAR(100),
    numero VARCHAR(10),
    bairro VARCHAR(50),
    cidade VARCHAR(50),
    estado VARCHAR(2),
    cep VARCHAR(10),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    create_date DATE DEFAULT CURRENT_DATE,
    update_date DATE DEFAULT CURRENT_DATE
);



-- 🧩 3. TABELA DE ESCOLA
-- guardar dados específicos da escola
-- (Nome, Endereço, horarios e etc).
CREATE TABLE escolas (
    escola_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco_id int references enderecos (endereco_id), 
    create_date DATE DEFAULT CURRENT_DATE,
    update_date DATE DEFAULT CURRENT_DATE
);



-- 🧩 4. TABELA DE AUXILIAR TIPO DE PAGAMENTO
-- guardar dados dos tipos de pagamentos
-- (PIX, débito, Credito).
create table tipo_pagamento(
	tipo_id serial primary key,
	metodo varchar unique
);



-- 🧩 5. TABELA DE AUXILIAR DE VALIDAÇÂO DE DOCUMENTO
-- guardar dados dos da validação do veiculo
-- (Documentos validos, invalidos).
create table documentacao(
	doc_id serial primary key,
	validacao boolean
);



-- 🧩 6. TABELA DE MOTORISTAS
-- guardar dados específicos do motorista
-- (CNH, Veiculo, status e etc).
create table motoristas(
	motorista_id serial primary key,
	user_id INT not null references usuarios(user_id) on delete cascade,
	cnh varchar(20) not null,
	status varchar(20) check(status in('ativo', 'inativo')),
	endereco_id int references enderecos(endereco_id),
	create_date date default current_date,
	update_date date default current_date
);



-- 🧩 7. TABELA DE VEICULOS
-- guardar dados específicos do veiculo
-- (placa, modelo, ano e etc).
Create table veiculos(
	veiculo_id serial primary key,
	placa_veiculo varchar(10) unique not null,
	modelo_veiculo varchar(50) not null,
	capacidade int,
	valid_doc int not null references documentacao(doc_id),
	ano_veiculo varchar(4),
	create_date date default current_date,
	update_date date default current_date
);



-- 🧩 8. TABELA INTERMEDIARIA MOTORISTA_VEICULOS
-- guardar dados específicos de motorista e veiculo
-- (id_motorista, id_veiculo, Data de inicio e fim).
create table motorista_veiculo (
    motorista_id INT REFERENCES motoristas(motorista_id) ON DELETE CASCADE,
    veiculo_id INT REFERENCES veiculos(veiculo_id) ON DELETE CASCADE,
    data_inicio DATE DEFAULT CURRENT_DATE,
    data_fim DATE,
    PRIMARY KEY (motorista_id, veiculo_id)
);



-- 🧩 9. TABELA DE RESPONSÁVEIS
-- guardar dados específicos de responsaveis
-- (usuario, criançaa, tipo de relação e etc).
CREATE TABLE responsaveis (
    responsavel_id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuarios(user_id) on delete cascade,
    tipo_relacao VARCHAR(50) CHECK (tipo_relacao IN ('pai', 'mae', 'outro')), -- criar tabela auxiliar
    principal BOOLEAN DEFAULT FALSE,
	endereco_id int references enderecos (endereco_id),
    create_date DATE DEFAULT CURRENT_DATE,
    update_date DATE DEFAULT CURRENT_DATE
);



-- 🧩 10. TABELA DE CRIANÇA
-- guardar dados específicos da criança
-- (nome, idade, escola e etc).
CREATE TABLE criancas (
    crianca_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    idade INT,
	responsavel_main int not null references responsaveis(responsavel_id), -- responsavel principal
	responsavel_Secon int references responsaveis(responsavel_id), -- responsavel segundario (opcional)
	responsavel_terceiro INT REFERENCES responsaveis(responsavel_id),
	motorista_id INT REFERENCES motoristas(motorista_id),
    escola_id INT REFERENCES escolas(escola_id),
    create_date DATE DEFAULT CURRENT_DATE,
    update_date DATE DEFAULT CURRENT_DATE
);



-- 🧩 11. TABELA DE PAGAMENTOS
-- guardar dados específicos de pagamentos
-- (dados responsaveis, valor, mes e etc).
CREATE TABLE pagamentos (
    pagamento_id SERIAL PRIMARY KEY,
    remetente_id INT REFERENCES usuarios(user_id),
	valor DECIMAL(10,2) NOT NULL,
    destinatario_id INT REFERENCES motoristas(motorista_id),
	metodo_pag int not null references tipo_pagamento(tipo_id),
    mes_mensalidade VARCHAR(7), -- formato YYYY-MM
    status VARCHAR(20) CHECK (status IN ('pendente', 'pago')) DEFAULT 'pendente',
    data_pagamento DATE DEFAULT CURRENT_DATE
);



-- 🧩 12. TABELA DE LOCALIZAÇÃO EM TEMPO REAL
-- guardar dados específicos da localização
-- (motorista, data_hora, localização e etc).
CREATE TABLE localizacao_real_tempo (
    localizacao_id SERIAL PRIMARY KEY,
    motorista_id INT REFERENCES motoristas(motorista_id),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- 🧩 13. TABELA DE ROTINA DE TRANSPORTE
-- guardar dados específicos da rotina de rotas do motorista
-- (criança, onde buscar, onde deixar e etc).
CREATE TABLE rotina_transporte (
    rotina_id SERIAL PRIMARY KEY,
    crianca_id INT REFERENCES criancas(crianca_id),
    motorista_id INT REFERENCES motoristas(motorista_id),
    dias_semana VARCHAR(20) CHECK (dias_semana IN ('segunda', 'terca', 'quarta', 'quinta', 'sexta')), -- lapidar
    tipo_trajeto VARCHAR(20) CHECK (tipo_trajeto IN ('origem', 'escola', 'volta')), -- lapidar
    endereco_origem_id INT REFERENCES enderecos(endereco_id), -- origem = Onde buscar a criança
    endereco_escola_id INT REFERENCES enderecos(endereco_id), -- escola = Qual escola deixar
	endereco_volta_id INT REFERENCES enderecos(endereco_id),   -- volta = Onde devolver a criança
    horario_previsto TIME,
    ativo BOOLEAN DEFAULT TRUE,
    observacao TEXT
);



-- 🧩 14. TABELA DE CHAT
-- guardar dados específicos do chat
-- (dados do usuario/motorista, data_hora e etc).
CREATE TABLE chat (
    mensagem_id SERIAL PRIMARY KEY,
    remetente_id INT REFERENCES usuarios(user_id),
    destinatario_id INT REFERENCES usuarios(user_id),
    conteudo TEXT NOT NULL,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN DEFAULT FALSE
);

INSERT INTO tipo_pagamento (metodo) VALUES ('PIX'), ('Crédito'), ('Débito');
INSERT INTO documentacao (validacao) VALUES (TRUE), (FALSE);

select * from documentacao
select * from tipo_pagamento

-- 15. TABELA DE AUXILIAR TIPO USUARIO
-- guarda dados específicos do Tipo de usuario
-- (Motorista, responsavel, admin)
create table tipo_user(
	tipo_user_id serial primary key,
	tipo varchar(50) unique
);

insert into tipo_user (tipo)
values ('responsavel'),('motorista'),('admin');

-- 16. TABELA DE LOGS
-- guarda dados específicos de logs
-- (precedimento, data, erro e etc)
create table logs_sistema(
	log_id serial primary key,
	procedimento varchar(100) not null, -- oq foi feito
	mensagem text not null, -- resumo do que ocorreu
	detalhe text,
	usuario_id int references usuarios(user_id),
	tipo_usuario int references tipo_user(tipo_user_id), 
	data_evento TIMESTAMP default current_timestamp
)


-- alterando tabela usuarios
alter table usuarios
add column tipo_user_id int;

alter table usuarios
add constraint fk_tipo_usuario
foreign key (tipo_user_id) references tipo_user(tipo_user_id);

alter table usuarios
drop column tipo_user;

/*
 1 - arrumar tabelas que tem "tipo_usuario" e colocar a fk (feito)
 2 - terminar procedure e funções de cadastrar usuarios
 3 - criar triggers 
 */