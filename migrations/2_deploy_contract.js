const NFTContract = artifacts.require("NFTContract");

module.exports = function (deployer) {
    deployer.deploy(NFTContract, "Test", "TST");
};
