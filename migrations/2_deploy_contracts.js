const SimpleStorage = artifacts.require("SimpleStorage");

module.exports = function(deployer, network, accounts) {
  deployer.then(async () => {
    await deployer.deploy(SimpleStorage);
  });
};
