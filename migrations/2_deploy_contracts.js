const Event = artifacts.require("Event");
const MarketPlace = artifacts.require("MarketPlace");

module.exports = (deployer, network, accounts) => {
    deployer.deploy(MarketPlace);
};

