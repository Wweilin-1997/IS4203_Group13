pragma solidity ^0.5.0;

contract MarketPlace {
  uint256 commissonFee;
  mapping(uint256 =>Event) events;
  mapping(string => address) events;
  address _owner = msg.sender;

  constructor(uint256 commissonFee) {
    commissonFee = commissonFee;
  }

}