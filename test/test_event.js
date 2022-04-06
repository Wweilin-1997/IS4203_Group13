const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

var Event = artifacts.require("../contracts/Event.sol");
var MarketPlace = artifacts.require("../contracts/MarketPlace.sol");

/*Testing Event Related Use Cases*/

contract('Event', function(accounts){
    before(async () => {
        marketplaceInstance = await MarketPlace.deployed();

    })
    let createEvent1; 

    it('Create Event', async () => {
        createEvent1 = await marketplaceInstance.createEvent(
            "Event 1",
            "EV1",
            "Singapore",
            "Event Organizer Company",
            5,
            5,
            5,
            1,
            {from: accounts[1]}
        )
        assert.notStrictEqual(
            createEvent1,
            undefined,
            "Failed to create Event"
        );
      
        let numEvents = await marketplaceInstance.getTotalEvents();
        assert.equal(
            numEvents,
            1,
            "Failed to create Event"
        );
    })

    it('Create Tickets in Bulk for a particular Type', async () => {
        let event1 = await marketplaceInstance.getEvent(1);
        console.log(event1)
   
    })
    
    it('Transferring tickets from one user to another', async () =>{

    })

    it('Validate ticket', async () => {

    })

    it('Invalidate ticket', async () => {

    })

    it('Check in ticket', async () => {
        
    })

    it('Tickets that are checked in cannot be checked in again', async () =>{

    })

    it('Invalidated tickets cannot be checked in', async () =>{

    })


});

