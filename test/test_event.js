const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

var Event = artifacts.require("../contracts/Event.sol");
var Ticket = artifacts.require("../contracts/Ticket.sol");

var MarketPlace = artifacts.require("../contracts/MarketPlace.sol");

/*Testing Event Related Use Cases*/

contract('Event', function(accounts){
    before(async () => {
        marketplaceInstance = await MarketPlace.deployed();
        eventInstance = await Event.deployed();
        ticketInstance = await Ticket.deployed();
    })

    it('Create First Event', async () => {
        let createEvent1 = await eventInstance.createEvent(
            "Event 0",
            "EV1",
            "Singapore",
            "Event Organizer Company",
            5,
            5,
            5,
            1,
            {from: accounts[1]}
        );
       

        let firstEventOrganizer = await eventInstance.getEventOrganizer(0)
        console.log(firstEventOrganizer)
    })

    it('Create Tickets in Bulk for a particular Type', async () => {
        let numberOfTicketsTobeCreated = 5
        let ticketsForEvent1 = await ticketInstance.createTicketInBulk(
            "typeA", 100000000000000, numberOfTicketsTobeCreated, 0, {from: accounts[1]}
        )

       let ticketIDsForEvent1 = await ticketInstance.getTicketsForEventId(0);
       assert.strictEqual(
            numberOfTicketsTobeCreated,
            ticketIDsForEvent1.length,
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

