pragma solidity ^0.4.4;

//After ERCbecomes more mature consider moving to it instead
//https://github.com/ethereum/EIPs/issues///but for now use ERC20 https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
  function totalSupply() constant returns (uint);
  function balanceOf(address _owner) constant returns (uint balance);
  function transfer(address _to, uint _value) returns (bool success);
  function transferFrom(address _from, address _to, uint _value) returns (bool success);
  function approve(address _spender, uint _value) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint remaining);
  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract TenereToken is ERC20Interface {
  string public constant tokenName = "Tenere Token";
  string public constant tokenSymbol = "TRE";
  uint8 public constant decimals = 18;
  uint public _totalSupply = 0;

  // Owner of this contract
  address public owner;

  // Balances for each account
  mapping(address => uint256) balances;

  // Owner of account approves the transfer of an amount to another account
  mapping(address => mapping (address => uint256)) allowed;

  // Functions with this modifier can only be executed by the owner
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Constructor
  function TenereToken() {
    owner = msg.sender;
    //TODO: put back in
    /*balances[owner] = _totalSupply;*/
  }

  //set a new owner of the contract
  function setOwner(address _owner) onlyOwner {
    owner = _owner;
    balances[_owner] = balances[owner];
  }

  function mintTokens(uint _numTokens) onlyOwner {
    if (_numTokens > 0 && balances[owner] + _numTokens > balances[owner]) {
    balances[owner] = balances[owner] + _numTokens;
    _totalSupply += _numTokens;
  } else {
    revert();
  }
  }

  function destroyTokens(uint _numTokens) onlyOwner {
    if (_numTokens > 0 && balances[owner] - _numTokens < balances[owner]) {
      balances[owner] = balances[owner] - _numTokens;
      _totalSupply -= _numTokens;
    } else {
      revert();
    }
  }

  // What is the balance of a particular account?
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  // Transfer the balance from owner's account to another account
  function transfer(address _to, uint _amount) returns (bool success) {
    if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
      balances[msg.sender] -= _amount;
      balances[_to] += _amount;
      Transfer(msg.sender, _to, _amount);
      return true;
    }
    else {
      return false;
    }
  }

  // Send _value amount of tokens from address _from to address _to
  // The transferFrom method is used for a withdraw workflow, allowing contracts to send
  // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
  // fees in sub-currencies; the command should fail unless the _from account has
  // deliberately authorized the sender of the message via some mechanism; we propose
  // these standardized APIs for approval:
  function transferFrom( address _from, address _to, uint _amount) returns (bool success) {
    if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
      balances[_from] -= _amount;
      allowed[_from][msg.sender] -= _amount;
      balances[_to] += _amount;
      Transfer(_from, _to, _amount);
      return true;
    }
    else {
      return false;
    }
  }

  // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
  // If this function is called again it overwrites the current allowance with _value.
  function approve(address _spender, uint _amount) returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  function totalSupply() constant returns (uint) {
    return _totalSupply;
  }
}