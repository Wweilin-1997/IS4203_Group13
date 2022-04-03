// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Event.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MarketPlace is ReentrancyGuard {
    uint256 commissonFee;
    //Event eventContract;
    mapping(uint256 => Event) events;
    mapping(string => mapping(uint256 => uint256)) prices;
    address _owner = msg.sender;
    uint256 totalEvents = 0;

    /*
  constructor(uint256 _commissonFee, Event _eventContract) {
    commissonFee = _commissonFee;
    eventContract = _eventContract;
  }
  */

    //mapping method
    constructor(uint256 _commissonFee) {
        commissonFee = _commissonFee;
    }

    modifier validEvent(uint256 eventId) {
        require(eventId < totalEvents);
        _;
    }

    function addEvent(Event _event) public {
        require(
            address(events[_event.getEventId()]) == address(0),
            "There is an existing event with the same name"
        );
        events[_event.getEventId()] = _event;
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

    function buy(uint256 eventId, uint256 tokenId) public nonReentrant {
        // same require event exists
        Event listedEvent = events[eventId];
        listedEvent.buyTicketsDuringSales(tokenId);
    }

    function createEvent(
        string memory _eventName,
        string memory _symbol,
        string memory _location,
        string memory _company,
        uint256 _resaleCeiling,
        uint256 _maxTicketsPerAddress,
        uint256 _commissionFee,
        uint256 _eventDate
    ) public {
        totalEvents++;
        Event eventInstance = new Event(
            totalEvents,
            _eventName,
            _symbol,
            _location,
            _company,
            _resaleCeiling,
            _maxTicketsPerAddress,
            _commissionFee,
            _eventDate,
            this
        );

        addEvent(eventInstance);
    }

    ///////////////////////////////////////////////////////
    //getters
    function getMarketPlaceAddress() public view returns (address) {
        return address(this);
    }

    function getEvent(uint256 eventId)
        public
        view
        validEvent(eventId)
        returns (Event)
    {
        return events[eventId];
    }
}
