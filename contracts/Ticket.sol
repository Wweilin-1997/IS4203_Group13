// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MarketPlace.sol";
import "./Event.sol";

contract Ticket is ERC721, Ownable {

    struct ticket {
        // address _marketPlaceAddress;
        address _ticketOwner;
        uint256 _seatID;
        string _type;
        uint256 creationPrice;
        uint256 listingPrice;
        bool isListed;
        bool isCheckedIn;
        bool isValid;
        //newly added
        uint256 eventId;
    }

    mapping(uint256 => ticket) IDToTicket;
    mapping(uint256 => uint256[]) eventIdToTicketIds;
    mapping(string => uint256[]) typeToTicketIds;
    mapping(address => uint256) ticketCountPerOwner;

    MarketPlace marketplaceContract;
    Event eventContract;
    uint256 public numTickets = 0;

    event ticketCreated(uint256 ticketId);
    event ticketBought(uint256 ticketId);
    event ticketListed(uint256 ticketId);
    event ticketUnlisted(uint256 ticketId);
    event ticketCheckedIn(uint256 ticketId);
    event ticketInvalidated(uint256 ticketId);
    event ticketValidated(uint256 ticketId);


    modifier requireValidTicket(uint256 tokenId) {
        require(_exists(tokenId), "Please enter a valid ticket id");
        _;
    }


    modifier onlyEventOrganizer(uint256 eventId) {
        require(
            msg.sender == eventContract.getEventOrganizer(eventId),
            "Only the event organizer can perform this action"
        );
        _;
    }

    constructor(string memory name, string memory symbol, MarketPlace marketplaceAddress, Event eventAddress) ERC721(name, symbol){
        name = name;
        symbol = symbol;
        marketplaceContract = marketplaceAddress;
        eventContract = eventAddress;
    }

    function createTicket(
        uint256 _seatID,
        string memory _type,
        uint256 _creationPrice,
        uint256 _eventId
    )
        public
        onlyEventOrganizer(_eventId)
        returns (uint256)
    {
        ticket memory newTicket = ticket(
            address(0),
            _seatID,
            _type,
            _creationPrice,
            _creationPrice, // initial listing price is the creation price
            true,
            false,
            true,
            _eventId
        );
        uint256 newTicketId = numTickets++;
        _safeMint(marketplaceContract.getMarketPlaceAddress(), newTicketId);
        IDToTicket[newTicketId] = newTicket;
        typeToTicketIds[_type].push(newTicketId);
        eventIdToTicketIds[_eventId].push(newTicketId);
        emit ticketCreated(newTicketId);
        return newTicketId;
    }
 
     function createTicketInBulk(
        string memory _type,
        uint256 _creationPrice,
        uint256 _numOfTickets,
        uint256 _eventId
    ) public {
        for (uint256 i = 0; i < _numOfTickets; i++) {
            uint256 currentSeatID = i;
            createTicket(currentSeatID, _type, _creationPrice, _eventId);
        }
    }

     function validateTicket(uint256 tokenId, uint256 eventId)
        public
        onlyEventOrganizer(eventId)
        requireValidTicket(tokenId)
    {
        require(
            IDToTicket[tokenId].isValid == false,
            "The ticket is already valid"
        );

        IDToTicket[tokenId].isValid = true;

        emit ticketValidated(tokenId);
    }



    function getTicket(uint256 id)
        public
        view
        requireValidTicket(id)
        returns (ticket memory)
    {
        return IDToTicket[id];
    }

     function getCurrentTicketCount() public view returns (uint256) {
        return ticketCountPerOwner[msg.sender];
    }

    function getTicketsForEventId(uint256 eventId) public view returns (uint256[] memory) {
        return eventIdToTicketIds[eventId];
    }
  
}
