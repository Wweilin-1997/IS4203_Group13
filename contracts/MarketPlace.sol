// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Event.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract MarketPlace is IERC721Receiver {
    //uint256 commissonFee;
    //Event eventContract;
    mapping(address => Event) events;
    mapping(address => mapping(uint256 => uint256)) private prices;

    // there will be 3 tiers, average 3 dollars per point
    // every 1 eth spend = 1000 points , 1 point = 1000000000000000 wei
    // bronze tier = 0 - 600 points => normal commission
    // silver >600-1500 =>  3%
    //gold 1500 > 1%
    mapping(address => uint256) points;

    // solidity doesnt store keys of a mapping hence need to store all the event addresses here
    address[] eventAddresses;

    address _owner = msg.sender;

    //mapping method
    constructor() {}

    event eventAdded(address eventContractAddress);
    event newTicketListed(uint256 tokenId, uint256 price);

    function addEvent(address eventContractAddress) public {
        events[eventContractAddress] = Event(msg.sender);
        eventAddresses.push(msg.sender);
        emit eventAdded(eventContractAddress);
    }

    function buy(address eventAddress, uint256 tokenId) public payable {
        // same require event exists
        uint256 userPoints = points[msg.sender];
        uint256 listedPrice = prices[eventAddress][tokenId];

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

        Event listedEvent = events[eventAddress];
        if (listedEvent.getCurrentEventStage() == uint256(Event.EventStage.SALES)) {
            listedEvent.buyTicketsDuringSales{value: msg.value}(tokenId);
        } else if (
            listedEvent.getCurrentEventStage() == uint256(Event.EventStage.POSTEVENT)
        ) {
            listedEvent.buyTicketsDuringPostEvent{value: msg.value}(tokenId);
        }

        points[msg.sender] += (listedPrice / 1000000000000000);
        unlistTicket(eventAddress, tokenId);
    }

    function listTicket(
        address eventAddress,
        uint256 tokenId,
        uint256 listedPrice
    ) public {
        prices[eventAddress][tokenId] = listedPrice;
        emit newTicketListed(tokenId, listedPrice);
    }

    function unlistTicket(address eventAddress, uint256 tokenId) public {
        prices[eventAddress][tokenId] = 0;
    }

    ///getters
    function getEvent(address eventAddress) public view returns (Event) {
        return events[eventAddress];
    }

    function getTicketPrice(address eventAddress, uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return prices[eventAddress][tokenId];
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // for demo purpose
    function upgradeAccountToGold(address account) public {
        points[account] = 1501;
    }

    function getAccountPoints(address accountAddress)
        public
        view
        returns (uint256)
    {
        return points[accountAddress];
    }

    function retrieveTicket(address eventAddress, uint256 tokenId) public {
        Event listedEvent = events[eventAddress];

        require(
            msg.sender == listedEvent.getTicket(tokenId)._ticketOwner,
            "You're not the owner"
        );
        require(
            listedEvent.getCurrentEventStage() == 2 ||
                listedEvent.getCurrentEventStage() == 3,
            "You're not allowed to perform this action at this point"
        );

        listedEvent.safeTransferFrom(
            address(this),
            listedEvent.getTicket(tokenId)._ticketOwner,
            tokenId
        );
    }
}
