pragma solidity ^0.4.4;

import "./TenereToken.sol";

contract Tree is ERC20Interface {
  address[] public managers;
  mapping(address => bool) public isManager;
  address public tenereTokenAddr;
  TenereToken public tenereToken;

  //represents a sensor attached to the tree
  struct Sensor {
    bytes32 name; //unique name for the sensor
    uint reward; //reward to be provided for providing data to this sensor
    bytes32 recordHash1;
    bytes32 recordHash2;
  }
  Sensor[] public sensors;
  mapping(bytes32 => uint) public sensorPosition;
  mapping(bytes32 => bool) public isStoredSensor;
  event UpdatedRecord(bytes32 sensor, address patron);

  modifier onlyManagers() {
      require(isManager[msg.sender]);
    _;
  }

  //The TenereTree is distinct from the Token allowing the Tree to be upgraded
  //while the token balances stay fixed and can be migrated
  function Tree(address _addr) {
    managers.push(msg.sender);
    isManager[msg.sender] = true;

    tenereTokenAddr = _addr;
    tenereToken = TenereToken(_addr);
  }

  function addManager(address _addr) onlyManagers {
    managers.push(_addr);
    isManager[_addr] = true;
  }

  //remove manager
  //TODO:

  function addSensor(bytes32 _name, address _patron, uint _reward, bytes32 _recordHash1, bytes32 _recordHash2) onlyManagers {
    Sensor memory sensor = Sensor({name: _name, reward: _reward, recordHash1: _recordHash1, recordHash2: _recordHash2});
    uint numSensors = sensors.push(sensor);
    sensorPosition[_name] =  numSensors - 1;
    tenereToken.mintTokens(sensor.reward);
    tenereToken.transfer(_patron, sensor.reward);
    isStoredSensor[_name] = true;
    UpdatedRecord(_name, _patron);
  }
  function getSensorsLength() constant returns (uint) {
    return sensors.length;
  }
  function getSensorInfo(bytes32 _sensor) constant returns(uint, bytes32, bytes32) {
    require(isStoredSensor[_sensor]);
    Sensor storage sensor = sensors[sensorPosition[_sensor]];
    return (sensor.reward, sensor.recordHash1, sensor.recordHash2);
  }
  //when called new sensor data is recorded and the patron is rewarded with the appropriate amount of
  //tokens for their contribution
  function setSensorRecord(bytes32 _sensor, address _patron, bytes32 _recordHash1, bytes32 _recordHash2) onlyManagers {
    require(isStoredSensor[_sensor]);
    Sensor storage sensor = sensors[sensorPosition[_sensor]];
    sensor.recordHash1 = _recordHash1;
    sensor.recordHash2 = _recordHash2;
    tenereToken.mintTokens(sensor.reward);
    tenereToken.transfer(_patron, sensor.reward);
    UpdatedRecord(_sensor, _patron);
  }
  function setSensorReward(bytes32 _sensor, uint _reward) {
    require(isStoredSensor[_sensor]);
    Sensor storage sensor = sensors[sensorPosition[_sensor]];
    sensor.reward = _reward;
  }

  function totalSupply() constant returns (uint) {
    return tenereToken.totalSupply();
  }
  function balanceOf(address _owner) constant returns (uint balance) {
    return tenereToken.balanceOf(_owner);
  }
  function transfer(address _to, uint _value) onlyManagers returns (bool success) {
    return tenereToken.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint _value) onlyManagers returns (bool success) {
    return tenereToken.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint _value) onlyManagers returns (bool success) {
    return tenereToken.approve(_spender, _value);
  }
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return tenereToken.allowance(_owner, _spender);
  }
  function getManagersLength() constant returns (uint) {
    return managers.length;
  }
}