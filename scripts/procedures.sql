-- p01 cadastrar usuario
create or replace procedure p_cadastrar_usuario(
	p_nome varchar,
	p_cpf varchar,
	p_email varchar,
	p_senha_hash varchar,
	p_tel varchar
)
language plpgsql
as $$
begin
	if exists(select 1 from usuarios where email = p_email)then
		raise exception 'Email já cadastrado';
	end if;

	if exists(select 1 from usuarios where cpf = p_cpf) then
		raise exception 'CPF já cadastrado';
	end if;
	
	insert into usuarios(
		nome,
		cpf,
		email,
		senha_hash,
		tel_user
	)
	values( 
		p_nome,
		p_cpf,
		P_email,
		p_senha_hash,
		p_tel
	);
end;
$$;


-- p02 cadastrar criança
create or replace procedure p_cadastrar_crianca(
	p_empresa_id int,
	p_nome varchar,
	p_dt_nascimento date,
	p_cpf varchar,
	p_escola_id int,
	p_plano_id int
)
language plpgsql as $$
begin
	if not exists(select 1 from escolas where escola_id = p_escola_id) then
		raise exception 'Escola não encontrada';
	end if;

	if exists(select 1 from criancas where cpf = p_cpf) then
		raise exception 'CPF já registrado';
	end if;

	insert into criancas(
		empresa_id,
		nome,
		dt_nascimento,
		cpf,
		escola_id,
		plano_id
	)
	values(
		p_empresa_id,
		p_nome,
		P_dt_nascimento,
		p_cpf,
		p_escola_id,
		p_plano_id
	);
end;
$$;

--p03 gerar mensalidade
create or replace procedure p_gerar_mensalidades_mes(
    p_mes date
)
language plpgsql
as $$
declare
    v_status_a_vencer int;
    v_tipo_pagamento int;
begin

    -- buscar status 'a vencer'
    select status_pag_id
    into v_status_a_vencer
    from status_pagamento
    where tipo = 'a vencer';

    if v_status_a_vencer is null then
        raise exception 'Status "a vencer" não encontrado';
    end if;

    -- buscar tipo de pagamento
    select tipo_pag_id
    into v_tipo_pagamento
    from tipo_pagamento
    where metodo = 'mensalidade';

    if v_tipo_pagamento is null then
        raise exception 'Tipo de pagamento "mensalidade" não encontrado';
    end if;

    -- cria pagamentos
    insert into pagamentos (
		crianca_id,
        pagador_id,
        empresa_id,
		valor_total,
        tipo_pag_id,
		forma_pag_id,
        mes_mensalidade,
        status_pag_id
    )
    select
		cr.crianca_id,
		cr.responsavel_id,
        c.empresa_id,
        fn_calcular_valor_final(
            p.valor_base,
            p.desconto,
            p.multa,
            p.valor_reajuste
        ),
        v_tipo_pagamento,
		null,
        p_mes,
        v_status_a_vencer
    from criancas c
    join planos_transporte p
        on p.plano_id = c.plano_id
    join criancas_responsaveis cr
        on cr.crianca_id = c.crianca_id
        and cr.principal = true
    where not exists (
        select 1
        from pagamentos pg
        join pagamento_crianca pc
            on pc.pagamento_id = pg.pagamento_id
        where pc.crianca_id = c.crianca_id
        and pg.mes_mensalidade = p_mes
    );

    -- cria itens do pagamento
    insert into pagamento_crianca (
        pagamento_id,
        crianca_id,
        valor_base,
        desconto,
        multa,
        reajuste,
        valor_final
    )
    select
        pg.pagamento_id,
        pg.crianca_id,
        p.valor_base,
        p.desconto,
        p.multa,
        p.valor_reajuste,
        fn_calcular_valor_final(
            p.valor_base,
            p.desconto,
            p.multa,
            p.valor_reajuste
        )
    from pagamentos pg
    join criancas c
        on c.crianca_id = pg.crianca_id
    join planos_transporte p
        on p.plano_id = c.plano_id
    join criancas_responsaveis cr
        on cr.crianca_id = c.crianca_id
        and cr.principal = true
    where pg.mes_mensalidade = p_mes
    and not exists (
        select 1
        from pagamento_crianca pc
        where pc.pagamento_id = pg.pagamento_id
        and pc.crianca_id = pg.crianca_id
    );

end;
$$;

--p04 confirmar pagamento

--p05 vincular motorista com veiculo
create or replace procedure p_vincular_motorista_veiculo(
	p_motorista_id int,
	p_veiculo_id int
)
language plpgsql as $$
begin

	if not exists(select 1 from motoristas where motorista_id = p_motorista_id and ativo = true)then
		raise exception 'Motorista inválido';
	end if;

	if not exists(select 1 from veiculos where veiculo_id = p_veiculo_id and ativo = true)then
		raise exception 'Veiculo inválido';
	end if;
	
	insert into motorista_veiculo(
		motorista_id,
		veiculo_id
	)
	values(
		p_motorista_id,
		p_veiculo_id
	);
end;
$$;

--p05 gerar pagamentos automaticos
-- 1- pegar todas as crianças da empresa, 2- verificar plano, 
-- -3 gerar pagamentos automaticos
