// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Event.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MarketPlace is IERC721Receiver{
    //uint256 commissonFee;
    //Event eventContract;
    mapping(address => Event) events;
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

    event eventAdded(address eventContractAddress);

    function addEvent(address eventContractAddress) public {
        // require(
        //     address(events[eventContractAddress]) == address(0),
        //     "There is an existing event with the same name"
        // );
        events[eventContractAddress] = Event(msg.sender);
        emit eventAdded(eventContractAddress);
    }

  function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public override returns (bytes4) {
            return this.onERC721Received.selector;
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

    function buy(address eventContractAddress, uint256 tokenId) public {
        // same require event exists
        Event listedEvent = events[eventContractAddress];
        listedEvent.buyTicketsDuringSales(tokenId);
    }
}
