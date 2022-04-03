const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

var Event = artifacts.require("../contracts/Event.sol");
var MarketPlace = artifacts.require("../contracts/MarketPlace.sol");

contract('MarketPlace', function(accounts){

    it('Listing Ticket', async () => {    

    })

    it('Listing ticket must be lower then the Max Resale Value + Commission Fee', async () => {

    })

    it('Purchase tickets during initial sales', async () =>{

    })

    it('Purchase tickets cannot exceed max number specified by Event Organiser', async () =>{

    })

    it('Purchase tickets post event', async () =>{

    })


})