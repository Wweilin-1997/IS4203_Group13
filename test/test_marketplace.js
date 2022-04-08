const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

var Event = artifacts.require("../contracts/Event.sol");
var MarketPlace = artifacts.require("../contracts/MarketPlace.sol");

contract('MarketPlace', function(accounts){

    before(async () => {
        eventInstance = await Event.deployed();
        MarketPlaceInstance = await MarketPlace.deployed();
    });
    
    console.log("Testing Market Place Contract");

    
    it('Purchase tickets during initial sales', async () =>{
        let eventAddress0 = await eventInstance.getEventContractAddress();
        console.log(eventAddress0)

        let eventType = "A"

  
        
        let typeToTicketIdsForEvent0 = await eventInstance.getTicketsListForEventType(eventType);
        console.log(typeToTicketIdsForEvent0)
        // let createEvent = await MarketPlaceInstance.addEvent("event1", {from: accounts[1]});
        //let createTickets = await eventInstance.createTicketInBulk("A", "VIP", 100, 10, {from: accounts[0]});
        //let purcahse = await eventInstance.buyTicketsDuringSales(1, {from: accounts[2], value: 100});

    })
    /*
    it('Purchase tickets cannot exceed max number specified by Event Organiser', async () =>{

    })

    it('Listing Ticket', async () => {    

    })

    it('Listing ticket must be lower then the Max Resale Value + Commission Fee', async () => {

    })

    it('Purchase tickets post event', async () =>{

    })
    */


})