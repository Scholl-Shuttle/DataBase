--Funções
/*
		verificar se motorista pode transportar
		verificar se veiculo é apto

		quantas crianças um motorista transporta
		total recebido por motorista mes
		crianças inadimplentes

*/ 


-- FN01 calcular total faturado da empresa
create or replace function fn_total_faturado_empresa(p_empresa_id int)
	returns numeric as $$
	declare
		total numeric;
		v_status_pago int;
	begin 
		select status_pag_id
		into v_status_pago
		from status_pagamento
		where tipo = 'pago';

		select sum(valor_total)
		into total
		from pagamentos
		where empresa_id = p_empresa_id
		and status_pag_id = v_status_pago;

		return coalesce(total, 0);
	end;
	$$ language plpgsql;

-- FN02 Calcular total de crianças ativas na empresa
create or replace function fn_total_criancas_ativas(p_empresa_id int)
	returns int as $$
	declare
		total int;
	begin
		select count(*)
		into total
		from criancas
		where empresa_id = p_empresa_id
		and ativo = true;

		return total;
	end;
	$$ language plpgsql;

-- FN03 Calcular valor final do pagamento dos pais
create or replace function fn_calcular_valor_final(
	p_valor_base numeric,
	p_desconto numeric,
	p_multa numeric,
	p_reajuste numeric
)
	returns numeric as $$
	begin
		return(
		coalesce(p_valor_base, 0)
		- coalesce(p_desconto, 0)
		+ coalesce(p_multa, 0 )
		+ coalesce(p_reajuste, 0)
		);
	end;
	$$ language plpgsql;


--FN04 Verificar se motorista está ativo
create or replace function fn_motorista_ativo(p_motorista_id int)
	returns boolean as $$
	declare
		status boolean;
	begin
		select ativo into status
		from motoristas
		where motorista_id = p_motorista_id;

		return coalesce(status,false);
	end;
	$$ language plpgsql;

	
--FN05 Registra log usuario
create or replace function fn_registrar_log_usuario(
	p_procedimento varchar,
	p_mensagem text,
	p_detalhe text,
	p_user_id int
)
returns void as $$
begin
	insert into logs_usuarios(
		procedimento, mensagem, detalhe, user_id
	)
	values(
		p_procedimento, p_mensagem, p_detalhe, p_user_id
	);
end;
$$ language plpgsql;


--FN06 registrar log pagamento
create or replace function fn_registrar_log_pagamento(
	p_ocorrencia varchar,
	p_mensagem text,
	p_user_id int,
	p_pagamento_id int
)
returns void as $$
begin
	insert into logs_pagamentos(
		ocorrencia, mensagem, user_id, pagamento_id
	)
	values(
		p_ocorrencia, p_mensagem, p_user_id, p_pagamento_id
	);
end;
$$ language plpgsql;


		