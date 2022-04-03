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

    })
    
    it('Create Tickets in Bulk for a particular Type', async () => {
    
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

