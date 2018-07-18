var _0xBitcoinToken = artifacts.require("./_0xBitcoinToken.sol");

var ethUtil =  require('ethereumjs-util');
var web3utils =  require('web3-utils');
var solidityHelper =  require('./solidity-helper');

var miningHelper =  require('./mining-helper');
var networkInterfaceHelper =  require('./network-interface-helper');


const Web3 = require('web3')
// Instantiate new web3 object pointing toward an Ethereum node.
let web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))

//https://web3js.readthedocs.io/en/1.0/web3-utils.html
//https://medium.com/@valkn0t/3-things-i-learned-this-week-using-solidity-truffle-and-web3-a911c3adc730


 

contract('EtherGoodsToken', function(accounts) {


    it("can deploy ", async function () {

      console.log( 'deploying token' )
      var tokenContract = await _0xBitcoinToken.deployed();



  }),


});
