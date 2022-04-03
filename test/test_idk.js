const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require('truffle-assertions');
var assert = require('assert');

var Event = artifacts.require("../contracts/Event.sol");
var MarketPlace = artifacts.require("../contracts/MarketPlace.sol");

contract('Test', function(accounts){


    it('Retrieve ownership of ticket after event', async () =>{

    })

    


})