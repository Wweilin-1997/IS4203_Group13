const Event = artifacts.require("Event");
const MarketPlace = artifacts.require("MarketPlace");
const Ticket = artifacts.require("Ticket");

const comissionFee = 5
module.exports = (deployer, network, accounts) => {
    deployer.deploy(MarketPlace, comissionFee).then(function() {
        return deployer.deploy(Event, MarketPlace.address).then(function(){
            return deployer.deploy(Ticket, "1", "1", MarketPlace.address, Event.address);
        });
    });
};

