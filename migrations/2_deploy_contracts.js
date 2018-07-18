var EtherGoodsToken = artifacts.require("./EtherGoodsToken.sol");

module.exports = function(deployer) {
  deployer.deploy(EtherGoodsToken);
};
