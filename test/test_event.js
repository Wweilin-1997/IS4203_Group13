const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

var Event = artifacts.require("../contracts/Event.sol");
var MarketPlace = artifacts.require("../contracts/MarketPlace.sol");

/*Testing Event Related Use Cases*/

contract('Event', function(accounts){
    before(async () => {
        eventInstance = await Event.deployed();
    })

    console.log("Testing Event Contract")

    it('Create Event', async () => {
        let eventOrganizer = await eventInstance.getEventOrganizer();
        assert.strictEqual(
            eventOrganizer,
            accounts[0],
            "Event was not created by the right address"
         );       
    })
    
    it('Create Tickets in Bulk for a particular Type', async () => {
        let numberOfTicketsTobeCreated = 5
        let eventType = "A"

        let ticketsForEvent1 = await eventInstance.createTicketInBulk(
            "A", eventType, 5, numberOfTicketsTobeCreated, {from: accounts[0]}
        )
        
        let typeToTicketIdsForEvent0 = await eventInstance.getTicketsListForEventType(eventType);

        assert.strictEqual(
            numberOfTicketsTobeCreated,
            typeToTicketIdsForEvent0.length,
            "Failed to create correct number of tickets"
         );       
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

