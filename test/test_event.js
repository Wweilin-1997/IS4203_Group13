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
        // let transferTicket = await eventInstance.tra
    })

    it('Invalidate ticket', async () => {
        await eventInstance.invalidateTicket(0, {from: accounts[0]});

        let ticketAfterUpdate = await eventInstance.getTicket(0);
        let newValidity = ticketAfterUpdate.isValid;

        assert.strictEqual(
            newValidity,
            false,
            "Failed Invalidate ticket"
        );

    })

    it('Validate ticket', async () => {
        await eventInstance.validateTicket(0, {from: accounts[0]});
        let ticketAfterUpdate = await eventInstance.getTicket(0);
        let newValidity = ticketAfterUpdate.isValid;
        assert.strictEqual(
            newValidity,
            true,
            "Failed Invalidate ticket"
        );
    })

    it('Check in ticket', async () => {
        
    })

    it('Tickets that are checked in cannot be checked in again', async () =>{

    })

    it('Invalidated tickets cannot be checked in', async () =>{

    })


});

