const Event = artifacts.require("Event");
const MarketPlace = artifacts.require("MarketPlace");

module.exports = (deployer, network, accounts) => {
    deployer.deploy(Event, "testEvent", "A1", "Jakarta", "SGCompany", 1,2,1,1).then(function () {
        return deployer.deploy(MarketPlace, 1, Event)
    });
};