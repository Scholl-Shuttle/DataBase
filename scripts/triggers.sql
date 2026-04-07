-- triggers

-- TR01 impede remoção de criança com pendencia
create or replace function fn_bloquear_remocao_crianca_pendente()
returns trigger
language plpgsql as $$
begin
	if exists (
		select 1 
		from pagamentos
		where crianca_id = old.crianca_id
		and status_pag_id = 1
	) then
		raise exception 'Criança ainda tem pagamentos pendentes, não foi possivel deletar';
	end if;
	return old;
end;
$$;

create trigger trg_bloquear_deletar_crianca_pendencia
before delete on criancas
for each row
execute function fn_bloquear_remocao_crianca_pendente();

-- TR02 atualizar data de pagamento
create or replace function fn_atualizar_data_pagamento()
returns trigger
language plpgsql as $$
begin
	if new.status_pag_id <> old.status_pag_id then
		new.data_pagamento := current_timestamp;
	end if;

	return new;
end;
$$;

create trigger trg_atualizar_data_pagamento
before update on pagamentos
for each row
execute function fn_atualizar_data_pagamento();

-- TR03 impidir alterar pagamento
create or replace function fn_bloquer_alteracao_pagamento()
returns trigger
language plpgsql as $$
begin

	if old.status_pag_id = (
		select status_pag_id
		from status_pagamento
		where tipo = 'pago'
	)then
		raise exception 'Pagamento já foi realizado e não pode ser alterado';
	end if;

	return new;
end;
$$;

create trigger trg_bloquear_edicao_pagamento
before update on pagamentos
for each row
execute function fn_bloquer_alteracao_pagamento();

-- TR04 impedir apagar pagamento
create or replace function fn_bloquear_delete_pagamento()
returns trigger
language plpgsql as $$
begin
	raise exception 'Não é permitido deletar pagamentos';
end;
$$;

create trigger trg_bloquear_delete_pagamento
before delete on pagamentos
for each row
execute function fn_bloquear_delete_pagamento();
