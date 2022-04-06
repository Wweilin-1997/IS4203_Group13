const Event = artifacts.require("Event");
const MarketPlace = artifacts.require("MarketPlace");

const comissionFee = 5
module.exports = (deployer, network, accounts) => {
    deployer.deploy(MarketPlace, comissionFee);
};

