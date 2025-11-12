/*
  - terminar procedure e funções de cadastrar usuarios
  - criar triggers 
 */

CREATE OR REPLACE PROCEDURE cadastrar_usuario(
    p_usuario_id INT,           -- quem executa id de quem executa
    p_tipo_usuario_executor VARCHAR, -- tipo de quem executa se é admin ou motorista
    p_nome VARCHAR,
    p_email VARCHAR,
    p_senha TEXT,
    p_tel_user VARCHAR,
    p_tipo_user INT             -- referência à tabela tipo_user
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validação da senha
    BEGIN
        PERFORM validar_senha(p_senha);

    EXCEPTION
        WHEN OTHERS THEN
            PERFORM registrar_log(
                'cadastrar_usuario',
                'ERRO',
                'Erro na validação de senha',
                SQLERRM,
                p_usuario_id,
                p_tipo_usuario_executor
            );
            RAISE EXCEPTION 'Erro na validação da senha: %', SQLERRM;
    END;

    -- Valida nome
    IF p_nome IS NULL OR p_nome = '' THEN
        RAISE EXCEPTION 'O nome não pode ser vazio.';
    END IF;

    -- Valida email
    IF p_email IS NULL OR LENGTH(p_email) <= 10 THEN
        RAISE EXCEPTION 'O email não pode ser vazio ou conter menos que 10 caracteres.';
    END IF;

    -- Verifica duplicidade de e-mail
    IF EXISTS (SELECT 1 FROM usuarios WHERE email = p_email) THEN
        PERFORM registrar_log(
            'cadastrar_usuario',
            'ERRO',
            'Tentativa de cadastrar e-mail existente',
            p_email,
            p_usuario_id,
            p_tipo_usuario_executor
        );
        RAISE EXCEPTION 'Já existe um usuário com este e-mail: %', p_email;
    END IF;

    -- Inserção do usuário
    INSERT INTO usuarios (nome, email, senha_hash, tel_user, tipo_user)
    VALUES (p_nome, p_email, p_senha, p_tel_user, p_tipo_user);

    -- Registro no log (sucesso)
    PERFORM registrar_log(
        'cadastrar_usuario',
        'INSERT',
        'Usuário cadastrado com sucesso',
        p_email,
        p_usuario_id,
        p_tipo_usuario_executor
    );
END;
$$;



create or replace procedure cadastrar_crianca(
	p_nome varchar,
	p_idade int,
	p_responsavel_main int,
	p_responsavel_secon int,
	p_responsavel_terceiro int,
	p_escola_id int,
	p_motorista_id int
)

language plpgsql

as $$

begin

-- valida nome da criança
	if p_nome is null or p_nome = '' then
		raise exception 'O nome da criança não pode ser vazio';
	end if;
-- valida idade da criança
	if p_idade <= 0 then
		raise exception 'Idade inválida. Deve ser maior que zero';
	end if;
-- valida se os responsaveis existe
	if not exists (select 1 from responsaveis where responsavel_id = p_responsavel_main) then
		raise exception 'Responsavel principal não encontrado.';
	end if;

	if p_responsavel_secon is not null then
		if not exists(
			select 1 from responsaveis where responsavel_id = p_responsavel_secon
		) then
			raise exception 'Responsável secundário informado não existe.';
		end if;

	if p_responsavel_terceiro is not null then
		if not exists(
			select 1 from responsaveis where responsavel_id = p_responsavel_terceiro
		) then
			raise exception 'Responsável terceiro informado não existe.';
		end if;
		
-- valida se a escola existe
	if not exists (select 1 from escolas where escola_id = p_escola_id) then
		raise exception 'Escola informada não encontrada';
	end if;
	
-- se tudo ok, insere
	insert into criancas(
		nome, 
		idade, 
		responsavel_main, 
		responsavel_secon, 
		responsavel_terceiro,
		escola_id,
		motorista_id
	)
	values(
		p_nome, 
		p_idade, 
		p_responsavel_main, 
		p_responsavel_secon, 
		p_responsavel_terceiro,
		p_escola_id,
		p_motorista_id
	);
end;
$$;

--========================================================================

create or replace procedure registrar_pagamento(
	p_remetente int,
	p_destinatario int,
	p_valor decimal(10,2),
	p_metodo int,
	p_mes varchar(7)
)

language plpgsql
as $$

begin
	if p_valor <= 0 then
		raise exception 'O valor do pagamento deve ser maior que zero.';
	end if;

	if not exists (select 1 from usuarios where user_id = p_remetente) then
		raise exception 'Usúario remetente não encontrado.'
	end if;

	if not exists (select 1 from motorista where motorista_id = p_destinatario) then
		raise exception 'Motorista destinatario não encontrado.'
	end if;


	insert into pagamentos(
		remetente_id,
		destinatario_id, 
		valor,
		metodo_pag,
		mes_mensalidade
	)
	values (
		p_remetente int,
		p_destinatario int,
		p_valor decimal,
		p_metodo int,
		p_mes varchar
	)
end;
$$

-- ===========================================================
create or replace procedure cadastrar_motorista(
    p_user_id int,
    p_cnh varchar,
    p_status varchar,
    p_endereco_id int,
    p_executor_id int,
    p_executor_tipo varchar
)
language plpgsql
as $$
begin
    -- validação
    if not exists (select 1 from usuarios where user_id = p_user_id and tipo_user_id = 
        (select tipo_user_id from tipo_user where tipo = 'motorista')) then
        perform registrar_log(
            'cadastrar_motorista',
            'ERRO',
            'Usuário informado não é do tipo motorista',
            null,
            p_executor_id,
            p_executor_tipo
        );
        raise exception 'Usuário informado não é um motorista válido.';
    end if;

    if p_cnh is null or length(p_cnh) < 10 then
        raise exception 'CNH inválida.';
    end if;

    if p_status not in ('ativo', 'inativo') then
        raise exception 'Status inválido. Deve ser "ativo" ou "inativo".';
    end if;

    -- se tudo der certo.
    insert into motoristas(user_id, cnh, status, endereco_id)
    values (p_user_id, p_cnh, p_status, p_endereco_id);

    -- log de sucesso
    perform registrar_log(
        'cadastrar_motorista',
        'SUCESSO',
        'Motorista cadastrado com sucesso.',
        format('user_id=%s, cnh=%s', p_user_id, p_cnh),
        p_executor_id,
        p_executor_tipo
    );

end;
$$;
