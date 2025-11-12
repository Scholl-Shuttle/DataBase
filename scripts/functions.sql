create or replace funcion validar_senha(p_senha text)
	return boolean
	
language plpgsql
as $$

begin
--verifica se tem 8 caracteres
	if length(p_senha) < 8 then
		raise exception 'A senha deve ter no mínimo 8 caracteres.';
	end if;

-- verifica letras maiusculas e minusculas
	if p_senha !~ '[A-Z]' then
		raise exception 'A senha de conter pelo menos uma letra maiúscula.';
	end if;

	if p_senha !~ '[a-z]' then
		raise exception 'A senha deve conter pelo menos uma letra minuscula';
	end if;

-- verifica se tem numeros e caracter especial
	if p_senha !~ '[0-9]' then
		raise exception 'A senha deve conter pelo menos um número';
	end if;

	if p_senha !~ '[!@#$%^&*(),.?":{}|<>]' then
		raise exception 'A senha deve conter pelo menos um caractere especial.'
	end if;

	return true;
end;
$$;



CREATE OR REPLACE FUNCTION registrar_log(
    p_procedimento VARCHAR,
    p_mensagem TEXT,
    p_detalhe TEXT,
    p_usuario_id INT,
    p_tipo_usuario VARCHAR
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO logs_sistema(
        procedimento, mensagem, detalhe, usuario_id, tipo_usuario
    )
    VALUES (
        p_procedimento, p_mensagem, p_detalhe, p_usuario_id, p_tipo_usuario
    );
END;
$$ LANGUAGE plpgsql;
