CREATE DATABASE locadora_carros;

USE locadora_carros;

-- Tabela: sedes
CREATE TABLE sedes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    telefone VARCHAR(15) NOT NULL,  -- Alterado para VARCHAR para armazenar números com DDD, traços, etc.
    nome_gerente VARCHAR(200) NOT NULL,
    multa DECIMAL(10,2) NOT NULL
);

-- Tabela: classes_carro
CREATE TABLE classes_carro (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,  -- Nome do tipo de carro (ex: luxo)
    valor_diario DECIMAL(10,2) NOT NULL
);

-- Tabela: carros
CREATE TABLE carros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    modelo VARCHAR(40) NOT NULL,
    ano YEAR NOT NULL,
    cor VARCHAR(20) NOT NULL,
    quilometragem DECIMAL(10,2) NOT NULL,  -- Corrigido de NUMERIC para DECIMAL (mais comum)
    descricao VARCHAR(100) NOT NULL,
    situacao VARCHAR(30) NOT NULL,  -- Ex: alugado, disponível, etc.
    origem_carro INT NOT NULL,
    localizacao_carro INT NOT NULL,
    classe_carro INT NOT NULL,

    CONSTRAINT fk_carros_sede_origem FOREIGN KEY (origem_carro)
        REFERENCES sedes(id),
    CONSTRAINT fk_carros_sede_localizacao FOREIGN KEY (localizacao_carro)
        REFERENCES sedes(id),
    CONSTRAINT fk_carros_classe FOREIGN KEY (classe_carro)
        REFERENCES classes_carro(id)
);

-- Tabela: clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    cnh VARCHAR(20) NOT NULL,
    validade_cnh DATE NOT NULL,
    categoria_cnh VARCHAR(3) NOT NULL
);

-- Tabela: locacao
CREATE TABLE locacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    diarias INT NOT NULL,
    data_locacao DATE NOT NULL,
    data_retorno DATE,
    quilometros_rodados DECIMAL(10,2),
    multa DECIMAL(10,2),
    situacao VARCHAR(15) NOT NULL,  -- Ex: finalizada; em aberto
    total DECIMAL(10,2),

    carro INT NOT NULL,
    cliente INT NOT NULL,
    sede_locacao INT NOT NULL,
    sede_devolucao INT,

    CONSTRAINT fk_locacao_sede_locacao FOREIGN KEY (sede_locacao)
        REFERENCES sedes(id),
    CONSTRAINT fk_locacao_sede_devolucao FOREIGN KEY (sede_devolucao)
        REFERENCES sedes(id),
    CONSTRAINT fk_locacao_carro FOREIGN KEY (carro)
        REFERENCES carros(id),
    CONSTRAINT fk_locacao_cliente FOREIGN KEY (cliente)
        REFERENCES clientes(id)
);
