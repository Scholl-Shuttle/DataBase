-- teste

-- preenchendo tabelas necessarias
insert into status_pagamento (tipo)
values
('a vencer'),
('processando'),
('aguardando'),
('pago'),
('pendente');

insert into tipo_pagamento (metodo)
values
('mensalidade');


insert into forma_pagamento (forma)
values
('pix'),
('credito'),
('debito'),
('boleto');

insert into empresas (
    nome,
    cnpj,
    email_contato
)
values (
    'TESTE Transporte Escolar TESTE',
    '12.345.678/0001-99',
    'TESTEcontato@abc.com'
);
select * from planos_transporte
insert into planos_transporte (
    nome,
    descricao,
    valor_base,
    desconto,
    multa,
    valor_reajuste
)
values (
    'Plano Manhã',
    'Transporte ida e volta',
    400,
    0,
    0,
    0
);


insert into usuarios (
    nome,
    cpf,
    email,
    senha_hash,
    tel_user
)
values (
    'maicon Silva',
    '124.456.789-00',
    'maicon@email.com',
    'hash123',
    '11999999999'
);

insert into tipo_escola(tipo)
values
	('particular'),
	('municipal'),
	('estadual'),
	('creche');

insert into escolas (
    nome,
    tipo_escola_id
)
values (
    'Escola Futuro',
    1
);


insert into criancas (
    empresa_id,
    nome,
    dt_nascimento,
    cpf,
    escola_id,
    plano_id
)
values (
    1,
    'pedrin silva',
    '2019-05-10',
    '111.123.333-44',
    2,
    1
);

select * from criancas


insert into responsaveis (
    user_id,
    principal
)
values (
    2,
    true
);


insert into criancas_responsaveis; (
    crianca_id,
    responsavel_id,
    principal
)
values (
    7,
    2,
    true
);



-- gerar mensalidade
call p_gerar_mensalidades_mes('2026-07-01'); 
select * from pagamentos where mes_mensalidade = '2026-07-01';



-- teste de atualização da data
update pagamentos
set status_pag_id = (
    select status_pag_id
    from status_pagamento
    where tipo = 'pendente'
)
where pagamento_id = 18;


select pagamento_id, data_pagamento
from pagamentos
where pagamento_id = 18;

-- teste de segurança
update pagamentos
set valor_total = 1
where pagamento_id = 18;

-- teste bloquear delete
delete from pagamentos
where pagamento_id = 18;


delete from criancas
where crianca_id = 18;

