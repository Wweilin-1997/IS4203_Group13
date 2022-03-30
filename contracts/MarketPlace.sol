// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Event.sol";

contract MarketPlace {
    //uint256 commissonFee;
    //Event eventContract;
    mapping(string => Event) events;
    mapping(string => mapping(uint256 => uint256)) prices;
    address _owner = msg.sender;

    /*
  constructor(uint256 _commissonFee, Event _eventContract) {
    commissonFee = _commissonFee;
    eventContract = _eventContract;
  }
  */

    //mapping method
    constructor() {}

    function addEvent(string memory _eventName) public {
        require(
            address(events[_eventName]) == address(0),
            "There is an existing event with the same name"
        );
        events[_eventName] = Event(msg.sender);
    }

    // // list and unlist functions
    // function list(
    //     string memory eventName,
    //     uint256 tokenId,
    //     uint256 price
    // ) public {
    //     Event listedEvent = events[eventName];
    //     /*
    // require(
    //   events[eventName] != null,
    //   "event does not exits"
    // );
    // */
    //     prices[eventName][tokenId] = price;
    //     listedEvent.listTicket(tokenId);
    // }

    // function unlist(string memory eventName, uint256 tokenId) public {
    //     Event listedEvent = events[eventName];
    //     /*
    // require(
    //   events[eventName] != null,
    //   "event does not exits"
    // );
    // */
    //     prices[eventName][tokenId] = 0;
    //     listedEvent.unlistTicket(tokenId);
    // }

    // // check price
    // function checkPrice(string memory eventName, uint256 tokenId)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     // same require event exists
    //     return prices[eventName][tokenId];
    // }

    function buy(string memory eventName, uint256 tokenId) public {
        // same require event exists
        Event listedEvent = events[eventName];
        listedEvent.buyTicketsDuringSales(tokenId);
    }
}
