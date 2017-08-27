/***********This contract is currently unused in this project********************/

pragma solidity ^0.4.4;

import "./TenereToken.sol";

contract Patron is ERC20Interface {
  address public owner;
  address public tenereTokenAddr;
  TenereToken public tenereToken;

  modifier onlyOwner() {
      require(owner == msg.sender);
    _;
  }

  //The TenereTree is distinct from the Token allowing the Tree to be upgraded
  //while the token balances stay fixed and can be migrated
  function Patron(address _addr) {
    owner = msg.sender;
    tenereTokenAddr = _addr;
    tenereToken = TenereToken(_addr);
  }

  function totalSupply() constant returns (uint) {
    return tenereToken.totalSupply();
  }
  function balanceOf(address _owner) constant returns (uint balance) {
    return tenereToken.balanceOf(_owner);
  }
  function transfer(address _to, uint _value) onlyOwner returns (bool success) {
    return tenereToken.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint _value) onlyOwner returns (bool success) {
    return tenereToken.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint _value) onlyOwner returns (bool success) {
    return tenereToken.approve(_spender, _value);
  }
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return tenereToken.allowance(_owner, _spender);
  }
}