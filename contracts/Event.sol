// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Event is ERC721 {
    string eventName;
    address eventOrganizer;
    string location;
    string company;
    uint256 numTickets = 0;
    uint256 resaleCeiling;
    uint256 commissionFee;
    uint256 eventDate;
    // mapping(uint256 => uint256) listPrice;
    address marketplace; // hardcoded address of the market place
    string ticketImageUrl;
    mapping(uint256 => Ticket) IDToTicket;
    // mapping(ticketId => mapping(uint256 => address)) transactions;
    mapping(address => uint256) ticketCountPerOwner;
    eventStage currentStage;

    enum eventStage {
        PRESALES,
        SALES,
        POSTEVENT
    }

    modifier requiredEventStage(eventStage stage) {
        require(
            stage == currentStage,
            "The action is not available at this stage"
        );
        _;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        address tokenOwner = ownerOf(tokenId);
        require(
            tokenOwner == msg.sender,
            "You're not authorized to perform this action"
        );
        _;
    }

    modifier onlyEventOrganizer() {
        require(
            msg.sender == eventOrganizer,
            "Only the event organizer can perform this action"
        );
        _;
    }

    struct Ticket {
        // address _marketPlaceAddress;
        address _ticketOwner;
        string _seat;
        string _type;
        uint256 creationPrice;
        bool isListed;
    }

    constructor(
        string memory _eventName,
        string memory _symbol,
        string memory _location,
        string memory _company,
        uint256 _resaleCeiling,
        uint256 _commissionFee,
        uint256 _eventDate
    ) ERC721(_eventName, _symbol) {
        eventName = _eventName;
        eventOrganizer = msg.sender;
        location = _location;
        company = _company;
        numTickets = 0;
        resaleCeiling = _resaleCeiling;
        commissionFee = _commissionFee;
        eventDate = _eventDate;
        currentStage = eventStage.PRESALES;
    }

    function createTicket(
        string memory _seat,
        string memory _type,
        uint256 _creationPrice
    )
        public
        onlyEventOrganizer
        requiredEventStage(eventStage.PRESALES)
        returns (uint256)
    {
        Ticket memory newTicket = Ticket(
            address(0),
            _seat,
            _type,
            _creationPrice,
            true
        );
        uint256 newTicketId = numTickets++;
        _safeMint(marketplace, newTicketId);
        IDToTicket[newTicketId] = newTicket;
        return newTicketId;
    }

    function buyTickets(uint256 tokenId)
        public
        payable
        requiredEventStage(eventStage.POSTEVENT)
    {}
}
