const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');
const { it } = require("ethers/wordlists");

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
    
    it('Create Ticket Type', async () => {
    
    })
    
    it('Create Tickets in Bulk for a particular Type', async () => {
    
    })
    
    it('Purchase tickets during initial sales', async () =>{

    })

    it('Validate ticket', async () => {

    })

    it('Invalidate ticket', async () => {

    })

    it('Check in ticket', async () => {
        
    })

});

