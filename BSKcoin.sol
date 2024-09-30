// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // Define a versão do compilador Solidity

// === REMIX IDE COMPILER USED: 0.8.15 ===

// =============== CODE ===============

// Interface padrão para um token ERC20
interface IERC20 {
    // Função para obter o total de tokens em circulação
    function totalSupply() external view returns (uint256);

    // Função para obter o saldo de um endereço específico
    function balanceOf(address account) external view returns (uint256);

    // Função para obter a quantidade de tokens que um endereço pode gastar em nome de outro
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    // Função para transferir tokens para outro endereço
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    // Função para aprovar um endereço a gastar uma quantidade específica de tokens
    function approve(address spender, uint256 amount) external returns (bool);

    // Função para transferir tokens de um endereço para outro, usando a aprovação
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // Evento emitido quando tokens são transferidos
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Evento emitido quando a aprovação é concedida para gastar tokens
    event Approval(address indexed owner, address indexed spender, uint256);
}

// Contrato principal que implementa a interface IERC20
contract BSKToken is IERC20 {
    string public constant name = "BSK Token"; // Nome do token
    string public constant symbol = "BSK"; // Símbolo do token
    uint8 public constant decimals = 18; // Número de casas decimais do token

    mapping(address => uint256) balances; // Mapeamento para armazenar saldos de cada endereço

    mapping(address => mapping(address => uint256)) allowed; // Mapeamento para armazenar as aprovações de gasto de tokens

    uint256 totalSupply_ = 10 ether; // Total de tokens em circulação

    // Construtor que é chamado apenas uma vez quando o contrato é implantado
    constructor() {
        balances[msg.sender] = totalSupply_; // Atribui todos os tokens ao endereço que implantou o contrato
    }

    // Retorna o total de tokens em circulação
    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    // Retorna o saldo de um endereço específico
    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner];
    }

    // Transfere tokens de um endereço para outro
    function transfer(address receiver, uint256 numTokens)
        public
        override
        returns (bool)
    {
        require(numTokens <= balances[msg.sender], "Insufficient balance"); // Verifica se o saldo é suficiente
        balances[msg.sender] -= numTokens; // Deduz os tokens do remetente
        balances[receiver] += numTokens; // Adiciona os tokens ao destinatário
        emit Transfer(msg.sender, receiver, numTokens); // Emite o evento de transferência
        return true; // Retorna verdadeiro se a transferência for bem-sucedida
    }

    // Aprova um endereço para gastar uma quantidade específica de tokens
    function approve(address delegate, uint256 numTokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens; // Define a quantidade permitida
        emit Approval(msg.sender, delegate, numTokens); // Emite o evento de aprovação
        return true; // Retorna verdadeiro se a aprovação for bem-sucedida
    }

    // Retorna a quantidade de tokens que um endereço pode gastar em nome de outro
    function allowance(address owner, address delegate)
        public
        view
        override
        returns (uint256)
    {
        return allowed[owner][delegate]; // Retorna a quantidade aprovada
    }

    // Transfere tokens de um endereço para outro, utilizando a aprovação
    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override returns (bool) {
        require(numTokens <= balances[owner], "Insufficient balance"); // Verifica se o saldo do proprietário é suficiente
        require(numTokens <= allowed[owner][msg.sender], "Allowance exceeded"); // Verifica se a aprovação é suficiente

        balances[owner] -= numTokens; // Deduz os tokens do proprietário
        allowed[owner][msg.sender] -= numTokens; // Deduz a quantidade aprovada
        balances[buyer] += numTokens; // Adiciona os tokens ao comprador
        emit Transfer(owner, buyer, numTokens); // Emite o evento de transferência
        return true; // Retorna verdadeiro se a transferência for bem-sucedida
    }
}
