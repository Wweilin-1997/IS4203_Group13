const Event1 = artifacts.require("Event");
const Event2 = artifacts.require("Event");
const MarketPlace = artifacts.require("MarketPlace");

module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        await deployer.deploy(MarketPlace);
        // event 1 is for test event
        await deployer.deploy(Event1, "event1", 
        "event1", "event1", "company1", 30, 2, 5, MarketPlace.address, {from: accounts[0]});

        // await deployer.deploy(Event2, "event1", 
        // "event1", "event1", "company1", 150, 3, 5, MarketPlace.address, {from: accounts[1]});

        // event 2 is for test market, not sure how to call the two events in test_event and test_marketplace
        //await deployer.deploy(Event2, "event2", 
        //"event2", "event2", "company2", 170, 2, 10, MarketPlace.address);
    });
};

