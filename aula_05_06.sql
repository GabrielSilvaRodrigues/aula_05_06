DROP DATABASE loja;
CREATE DATABASE loja;
USE loja;

CREATE TABLE cliente (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(200) NOT NULL,
  email VARCHAR(200)
);

CREATE TABLE produto (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  estoque INT NOT NULL
);

CREATE TABLE pedido (
  id INT AUTO_INCREMENT PRIMARY KEY,
  data_pedido DATE NOT NULL,
  valor_total DECIMAL(10,2) NOT NULL,
  id_cli INT NOT NULL,
  CONSTRAINT fk_ped_cli FOREIGN KEY (id_cli) REFERENCES cliente(id)
);

CREATE TABLE item (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_ped INT NOT NULL,
  id_prod INT NOT NULL,
  qtd INT NOT NULL,
  CONSTRAINT fk_it_ped FOREIGN KEY (id_ped) REFERENCES pedido(id),
  CONSTRAINT fk_it_prod FOREIGN KEY (id_prod) REFERENCES produto(id)
);

INSERT INTO cliente (nome, email) VALUES
('Ana Silva', 'ana.silva@example.com'),
('Carlos Souza', 'carlos.souza@example.com');

INSERT INTO produto (nome, valor, estoque) VALUES
('mesa', 200.00, 5),
('cadeira', 50.00, 20);

INSERT INTO pedido (data_pedido, valor_total, id_cli) VALUES 
('2024-03-15', 400.00, (SELECT id FROM cliente WHERE nome = 'Ana Silva' LIMIT 1));

INSERT INTO item (id_ped, id_prod, qtd) VALUES 
((SELECT MAX(id) FROM pedido), (SELECT id FROM produto WHERE nome = 'mesa' LIMIT 1), 1),
((SELECT MAX(id) FROM pedido), (SELECT id FROM produto WHERE nome = 'cadeira' LIMIT 1), 4);

INSERT INTO pedido (data_pedido, valor_total, id_cli) VALUES 
('2024-04-20', 100.00, (SELECT id FROM cliente WHERE nome = 'Carlos Souza' LIMIT 1));

INSERT INTO item (id_ped, id_prod, qtd) VALUES 
((SELECT MAX(id) FROM pedido), (SELECT id FROM produto WHERE nome = 'cadeira' LIMIT 1), 2);

CREATE VIEW pedidos_dec_data AS
SELECT 
  i.id_ped, pr.nome AS produto_nome, pr.valor, i.qtd AS quantidade, 
  p.data_pedido, p.valor_total, c.nome AS cliente_nome 
FROM item i
JOIN pedido p ON i.id_ped = p.id
JOIN produto pr ON i.id_prod = pr.id
JOIN cliente c ON p.id_cli = c.id
ORDER BY p.data_pedido DESC;

DELIMITER //

CREATE PROCEDURE registrar_item(
    IN p_id_pedido INT,
    IN p_nome_produto VARCHAR(100),
    IN p_quantidade INT
)
BEGIN
    DECLARE v_id_prod INT;
    DECLARE v_estoque_atual INT;

    SELECT id, estoque INTO v_id_prod, v_estoque_atual
    FROM produto
    WHERE nome = p_nome_produto
    LIMIT 1;
    
    IF v_id_prod IS NOT NULL THEN
        IF v_estoque_atual >= p_quantidade THEN
            -- Insere item no pedido
            INSERT INTO item (id_ped, id_prod, qtd)
            VALUES (p_id_pedido, v_id_prod, p_quantidade);

            -- Atualiza o estoque
            UPDATE produto
            SET estoque = estoque - p_quantidade
            WHERE id = v_id_prod;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente';
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto não encontrado';
    END IF;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE registrar_cliente(
    IN r_nome VARCHAR(200),
    IN r_email VARCHAR(200)
)
BEGIN
    INSERT INTO cliente(nome, email) VALUES (r_nome, r_email);
    COMMIT;
END;
//

DELIMITER ;

START TRANSACTION;

-- Novo pedido
INSERT INTO pedido (data_pedido, valor_total, id_cli)
VALUES (CURDATE(), 350.00, 1);

SET @id_pedido = LAST_INSERT_ID();

-- Adiciona os itens usando a nova procedure
CALL registrar_item(@id_pedido, 'mesa', 1);
CALL registrar_item(@id_pedido, 'cadeira', 3);

COMMIT;

CALL registrar_cliente('gabriel', 'g@g');
