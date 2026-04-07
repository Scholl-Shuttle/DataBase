 -- ==========================================================
-- BANCO DE DADOS: Transporte Escolar
-- DESENVOLVIDO POR: Matheus Cerqueira
-- OBJETIVO: Gerenciar transporte, motoristas, crianças, rotas e pagamentos
-- ==========================================================


-- TABELAS AUXILIARES

-- 2. TABELA DE AUXILIAR TIPO DE PAGAMENTO
-- guardar dados dos tipos de pagamentos
-- (Mensalidade, semestral, Anual).
create table tipo_pagamento(
	tipo_pag_id serial primary key,
	metodo varchar(50)not null unique
);




create table forma_pagamento(
	forma_pag_id serial primary key,
	forma varchar(50) not null
);




-- 3. TABELA DE AUXILIAR DE VALIDAÇÂO DE DOCUMENTO
-- guardar dados dos da validação do veiculo
-- (Documentos validos, invalidos).
create table status_documento(
	status_doc_id serial primary key,
	status varchar(20) not null check (status in ('pendente','aprovado','vencido', 'reprovado'))
);

select * from status_documento
-- 4 TABELA AUXILIAR TIPO ESCOLA
-- guarda dados específicos do Tipo de
-- (Particular, Governo, estadual, creche)
create table tipo_escola(
	tipo_escola_id serial primary key,
	tipo varchar (50)not null unique
);

-- 5 TABELA AUXILIAR TIPO RESPONSAVEL
-- qual a relação com a criança
-- (Pai, Mãe, Tia, Avo ...)
create table tipo_responsavel(
	tipo_responsavel_id serial primary key,
	tipo varchar(50) not null
);

select * from tipo_responsavel

-- 6 TABELA AUXILIAR STATUS DE PAGAMENTO
-- pago, pendente, rejeitado, a vencer
create table status_pagamento(
	status_pag_id serial primary key,
	tipo varchar(20) not null unique
);

-- 7 TABELA AUXILIAR DIAS_SEMANA
-- segunda, terça, quarta ...
create table dias_semana (
    dia_id serial primary key,
    nome varchar(20) unique not null
);

-- 8 TABELA AUXILIAR TIPO_TRAJETO
-- Ida, volta, escola ...
create table tipo_trajeto (
    tipo_trajeto_id serial primary key,
    nome varchar(20) unique not null
);


-- ========= TABELAS PLANOS E FINANÇEIRA ==========

-- TABELA DE PLANOS
create table planos_transporte(
	plano_id serial primary key,

	nome varchar(50) not null,
	descricao text,

	valor_base decimal(10,2) not null,

	tipo_reajuste varchar(20)check (tipo_reajuste in('percentual', 'fixo')),
	valor_reajuste decimal(10,2) default 0,
	ativo boolean default true,

	created_at timestamp default current_timestamp
);

alter table planos_transporte add column 
multa decimal(10,2) default 0;


-- ========= TABELAS =========

-- TABELA DE EMPRESA
-- nesta tabela é onde fica dados da empresa/pj
-- caso uma pessoa tenha mais de um veiculo e pague para motoristas
create table empresas(
	empresa_id serial primary key,

	nome varchar(100) not null,
	cnpj varchar(18) unique,

	email_contato varchar(100),
	telefone_contato varchar(15),

	ativo boolean default true,

	created_at timestamp default current_timestamp,
    updated_at timestamp default current_timestamp
);


-- TABELA DE USUÁRIOS
-- tabela generica onde vai guardar dados de acesso
-- (login, senha, tipo, data de criação e etc).
create table usuarios(
	user_id serial primary key,
	nome varchar(100) not null,
	cpf varchar(14)not null unique,
	email varchar(100) not null unique,
	senha_hash varchar(255) not null,
	tel_user varchar(15) not null,

	ativo boolean default true,
	
	created_at TIMESTAMP default current_TIMESTAMP,
	updated_at TIMESTAMP default current_TIMESTAMP
);

-- TABELA INTERMEDIARIA EMPRESA_USUARIO
create table empresa_usuario(
	empresa_id int not null references empresas(empresa_id) on delete cascade,
	user_id int not null references usuarios(user_id) on delete cascade,

	papel varchar(30) not null check (papel in('dono', 'gerente', 'motorista')),

	ativo boolean default true,
	created_at timestamp default current_timestamp,

	primary key (empresa_id, user_id)
);


-- TABELA DE ENDEREÇOS
-- guardar dados específicos de endereços
-- (rua, bairro, cep e etc).
CREATE TABLE enderecos(
    endereco_id SERIAL PRIMARY KEY,
	
    rua VARCHAR(120) not null,
    numero VARCHAR(20),
	complemento varchar(200),
    bairro VARCHAR(80)not null,
    cidade VARCHAR(80)not null,
    estado VARCHAR(2)not null,
    cep VARCHAR(10)not null,

	
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),

	referencia varchar(255),
	
    created_at TIMESTAMP default current_TIMESTAMP,
    updated_at TIMESTAMP default current_TIMESTAMP
);

-- TABELA usuario enderecos
-- guarda informações especifica de enderecos de usuarios
create table usuarios_endereco(
	user_id int not null references usuarios(user_id) on delete cascade,
	endereco_id int not null references enderecos(endereco_id) on delete cascade,

	tipo varchar(30),
	principal boolean default false,

	created_at timestamp default current_timestamp,

	primary key(user_id, endereco_id)
);

-- TABELA DE ESCOLA
-- guardar dados específicos da escola
-- (Nome, Endereço, horarios e etc).
CREATE TABLE escolas (
    escola_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
	tipo_escola_id int not null references tipo_escola(tipo_escola_id),

	ativo boolean default true,
	
    created_at TIMESTAMP default current_TIMESTAMP,
    updated_at TIMESTAMP default current_TIMESTAMP
);


create table escola_endereco(
	escola_id int not null references escolas(escola_id) on delete cascade,
	endereco_id int not null references enderecos(endereco_id) on delete cascade,

	principal boolean default true,

	primary key (escola_id, endereco_id)
);


-- TABELA DE VEICULOS
-- guardar dados específicos do veiculo
-- (placa, modelo, ano e etc).
Create table veiculos(
	veiculo_id serial primary key,
	empresa_id int not null references empresas(empresa_id) on delete cascade,
	
	placa_veiculo varchar(10) unique not null,
	marca_veiculo varchar(50) not null,
	modelo_veiculo varchar(50) not null,
	
	capacidade int check (capacidade > 0),
	ano_veiculo int check (ano_veiculo >= 2000),
	status_doc_id int not null references status_documento(status_doc_id),

	ativo boolean default true,
	
	created_at TIMESTAMP default current_TIMESTAMP,
	updated_at TIMESTAMP default current_TIMESTAMP
);


-- TABELA DE MOTORISTAS
-- guardar dados específicos do motorista
-- (CNH, Veiculo, status e etc).
create table motoristas(
	motorista_id serial primary key,
	empresa_id int not null references empresas(empresa_id) on delete cascade,
	
	user_id INT not null references usuarios(user_id) on delete cascade,
	cnh varchar(20) not null unique,
	
	status_cnh boolean not null,
	ativo boolean default true,
	
	created_at TIMESTAMP default current_TIMESTAMP,
	updated_at TIMESTAMP default current_TIMESTAMP
);




-- TABELA INTERMEDIARIA MOTORISTA_VEICULOS
-- guardar dados específicos de motorista e veiculo
-- (id_motorista, id_veiculo, Data de inicio e fim).
create table motorista_veiculo (
	motorista_id INT not null REFERENCES motoristas(motorista_id)ON DELETE CASCADE,
	
	data_inicio TIMESTAMP default current_TIMESTAMP,
    data_fim TIMESTAMP default null,
	
    veiculo_id INT not null REFERENCES veiculos(veiculo_id)ON DELETE CASCADE ,
    PRIMARY KEY (motorista_id, veiculo_id)
);



-- TABELA DE RESPONSÁVEIS
-- guardar dados específicos de responsaveis
-- (usuario, criançaa, tipo de relação e etc).
CREATE TABLE responsaveis (
    responsavel_id SERIAL PRIMARY KEY,
    principal BOOLEAN DEFAULT FALSE,
	user_id INT not null REFERENCES usuarios(user_id) on delete cascade,
	
    created_at TIMESTAMP default current_TIMESTAMP,
    updated_at TIMESTAMP default current_TIMESTAMP
);



-- TABELA DE CRIANÇA
-- guardar dados específicos da criança
-- (nome, idade, escola e etc).
CREATE TABLE criancas (
    crianca_id SERIAL PRIMARY KEY,
	empresa_id int not null references empresas(empresa_id) on delete cascade,
	
    nome VARCHAR(100) NOT NULL,
    dt_nascimento date not null,
	cpf varchar(14) not null unique,
	ativo boolean default true,
    escola_id INT not null REFERENCES escolas(escola_id),

	plano_id int references planos_transporte(plano_id),
	
    created_at TIMESTAMP default current_TIMESTAMP,
    updated_at TIMESTAMP default current_TIMESTAMP
);


-- tabela intermediaria CRIANÇA_RESPONSAVEL
create table criancas_responsaveis(
	crianca_id int not null references criancas(crianca_id) on delete cascade,
	responsavel_id int not null references responsaveis(responsavel_id)on delete cascade,

	tipo_responsavel_id int references tipo_responsavel(tipo_responsavel_id),
	principal boolean default false,

	created_at timestamp default current_timestamp,

	primary key (crianca_id, responsavel_id)
);


alter table pagamentos
add constraint uq_pagamento_mes_crianca
unique (crianca_id, mes_mensalidade);

-- TABELA DE PAGAMENTOS
-- guardar dados específicos de pagamentos
-- (dados responsaveis, valor, mes e etc).
CREATE TABLE pagamentos (
    pagamento_id SERIAL PRIMARY KEY,

	crianca_id int not null unique references criancas(crianca_id),
	
	pagador_id INT not null unique REFERENCES responsaveis(responsavel_id),
    empresa_id int not null unique references empresas(empresa_id) on delete cascade,
	
	valor_total DECIMAL(10,2) NOT NULL,
	
	tipo_pag_id int not null references tipo_pagamento(tipo_pag_id),
	forma_pag_id int references forma_pagamento(forma_pag_id),
	
    mes_mensalidade DATE not null unique,
    status_pag_id int not null references status_pagamento(status_pag_id),
	
    data_pagamento TIMESTAMP default current_TIMESTAMP
);


-- TABELA INTERMEDIARIA PAGAMENTO_CRIANÇA
create table pagamento_crianca(
	pagamento_id int not null references pagamentos(pagamento_id)on delete cascade,
	crianca_id int not null references criancas(crianca_id) on delete cascade,

	valor_base decimal(10,2) not null,
	desconto decimal(10,2) default 0,
	multa decimal(10,2) default 0,
	reajuste decimal(10,2) default 0,

	valor_final decimal(10,2) not null,
	primary key (pagamento_id, crianca_id)
);


-- TABELA DE LOCALIZAÇÃO EM TEMPO REAL
-- guardar dados específicos da localização
-- (motorista, data_hora, localização e etc).
CREATE TABLE localizacao_real_tempo (
    localizacao_id SERIAL PRIMARY KEY,
	empresa_id int not null references empresas(empresa_id) on delete cascade,
    motorista_id INT not null REFERENCES motoristas(motorista_id),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- TABELA DE ROTINA DE TRANSPORTE
-- guardar dados específicos da rotina de rotas do motorista
-- (criança, onde buscar, onde deixar e etc).
CREATE TABLE rotina_transporte (
    rotina_id SERIAL PRIMARY KEY,
	empresa_id int not null references empresas(empresa_id) on delete cascade,
	
    crianca_id INT not null REFERENCES criancas(crianca_id),
    motorista_id INT not null REFERENCES motoristas(motorista_id),
	
    dia_id int not null references dias_semana(dia_id),
    tipo_trajeto_id int not null references tipo_trajeto(tipo_trajeto_id),

	endereco_origem_id int not null references enderecos(endereco_id),
	endereco_destino_id int not null references enderecos(endereco_id),

	horario_previsto time not null,
	
    ativo BOOLEAN DEFAULT TRUE,
    observacao TEXT,

	ordem int,
	
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp
);



-- TABELA DE CHAT
-- guardar dados específicos do chat
-- (dados do usuario/motorista, data_hora e etc).
CREATE TABLE chat (
    mensagem_id SERIAL PRIMARY KEY,
    remetente_id INT not null REFERENCES usuarios(user_id),
    destinatario_id INT not null REFERENCES usuarios(user_id),
    conteudo TEXT,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN DEFAULT FALSE
);


-- TABELA DE LOGS_USUARIOS
-- guarda dados específicos de logs
-- (precedimento, data, erro e etc)
create table logs_usuarios(
	log_id serial primary key,
	procedimento varchar(100) not null, -- o que foi feito. EX(edição de perfil)
	mensagem text not null, -- resumo do que ocorreu. EX(usuario trocou o endereço)
	detalhe text,
	user_id int not null references usuarios(user_id),
	data_evento TIMESTAMP default current_timestamp
);


-- TABELA DE LOGS_PAGAMENTOS
-- somente logs referente a pagamentos
create table logs_pagamentos(
	log_id serial primary key,
	
	ocorrencia varchar(100) not null, -- ex(pagamento rejeitado)
	mensagem text not null, -- não foi possivel efetuar o pagamento 
	
	user_id int not null references usuarios(user_id),
	pagamento_id int references pagamentos(pagamento_id),
	
	data_tentativa TIMESTAMP default current_TIMESTAMP
);

