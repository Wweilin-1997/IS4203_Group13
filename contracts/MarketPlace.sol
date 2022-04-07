// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Event.sol";

contract MarketPlace {
    mapping(string => Event) events;
    mapping(string => mapping(uint256 => uint256)) prices;
    // there will be 3 tiers, average 3 dollars per point
    // every 1 eth spend = 1000 points , 1 point = 3000000000000000 wei
    // 
    // bronze tier = 0 - 200 points => normal commission
    // silver >200-500 =>  3%
    //gold 500 > 1%
    mapping(address => uint256) points;

    address _owner = msg.sender;

    /*
  constructor(uint256 _commissonFee, Event _eventContract) {
    commissonFee = _commissonFee;
    eventContract = _eventContract;
  }
  */
    event eventAdded(string eventName);

    function addEvent(string memory _eventName) public {
        require(
            address(events[_eventName]) == address(0),
            "There is an existing event with the same name"
        );
        events[_eventName] = Event(msg.sender);
        emit eventAdded(_eventName);
    }

    function buy(string memory eventName, uint256 tokenId) public payable {
        // same require event exists
        uint256 userPoints = points[msg.sender];
        uint256 listedPrice = prices[eventName][tokenId];
        uint256 commissionFee = 5;
        if (userPoints > 500) {
            commissionFee = 1;
        } else if (userPoints > 200) {
            commissionFee = 3;
        }

        require(
            msg.value >= listedPrice * (commissionFee + 100 / 100),
            "Insufficient funds to purchase ticket"
        );
        Event listedEvent = events[eventName];
        listedEvent.buyTicketsDuringSales(tokenId);
        address payable owner = payable(address(uint160(_owner)));
        owner.transfer(listedPrice * commissionFee);
        points[msg.sender] += (listedPrice / 3000000000000000);
        unlistTicket(eventName, tokenId);
    }

    function listTicket(
        string memory eventName,
        uint256 tokenId,
        uint256 listedPrice
    ) public {
        prices[eventName][tokenId] = listedPrice;
    }

    function unlistTicket(string memory eventName, uint256 tokenId) public {
        prices[eventName][tokenId] = 0;
    }

    ///getters
    function getEvent(string memory eventName) public view returns (Event) {
        return events[eventName];
    }

    function getTicketPrice(string memory eventName, uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return prices[eventName][tokenId];
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
}
