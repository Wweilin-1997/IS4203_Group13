const Event1 = artifacts.require("Event");
const Event2 = artifacts.require("Event");
const MarketPlace = artifacts.require("MarketPlace");

module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        await deployer.deploy(MarketPlace);
        await deployer.deploy(Event1, "event1", 
        "event1", "event1", "company1", 30, 2, 5, MarketPlace.address, {from: accounts[0]});
    });
};

