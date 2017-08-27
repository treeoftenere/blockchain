var Tree = artifacts.require("./Tree.sol");
var TenereToken = artifacts.require("./TenereToken.sol");

module.exports = function(deployer) {
  deployer.deploy(TenereToken).then(() => {
    return TenereToken.deployed();
  })
  .then(tenereToken => {
    deployer.deploy(Tree, tenereToken.address).then(() =>{
      return Tree.deployed()
    }).then(tree => {
      tenereToken.setOwner(tree.address);
    })
  })
};