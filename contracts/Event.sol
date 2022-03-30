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
    address marketPlaceAddress; // hardcoded address of the market place
    string ticketImageUrl;
    mapping(uint256 => Ticket) IDToTicket;
    // mapping(ticketId => mapping(uint256 => address)) transactions;
    mapping(address => uint256) ticketCountPerOwner;
    eventStage currentStage;
    mapping(string => uint256[]) typeToTicketIds;

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

    modifier onlyTicketOwner(uint256 tokenId) {
        require(_exists(tokenId), "Please enter a valid ticket id");
        require(
            IDToTicket[tokenId]._ticketOwner == msg.sender,
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

    modifier onlyMarketPlace() {
        require(
            msg.sender == marketPlaceAddress,
            "You're not authorized to perform this action"
        );
        _;
    }

    modifier requireValidTicket(uint256 tokenId) {
        require(_exists(tokenId), "Please enter a valid ticket id");
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
        _safeMint(marketPlaceAddress, newTicketId);
        IDToTicket[newTicketId] = newTicket;
        typeToTicketIds[_type].push(newTicketId);
        return newTicketId;
    }

    function buyTicketsDuringPostEvent(uint256 tokenId)
        public
        payable
        requiredEventStage(eventStage.POSTEVENT)
    {
        Ticket memory ticketToBuy = IDToTicket[tokenId];
        require(ticketToBuy.isListed == true, "Cannot buy, Ticket not lised");
        safeTransferFrom(ticketToBuy._ticketOwner, msg.sender, tokenId);
        ticketToBuy._ticketOwner = msg.sender;
        ticketToBuy.isListed = false;
    }

    function createTicketInBulk(
        string memory _seat,
        string memory _type,
        uint256 _creationPrice,
        uint256 _numOfTickets
    ) public onlyEventOrganizer requiredEventStage(eventStage.PRESALES) {
        for (uint256 i = 0; i < _numOfTickets; i++) {
            createTicket(_seat, _type, _creationPrice);
        }
    }

    function buyTicketsDuringSales(uint256 tokenId)
        public
        payable
        onlyMarketPlace
        requiredEventStage(eventStage.SALES)
        requireValidTicket(tokenId)
    {
        uint256 payableAmount = IDToTicket[tokenId].creationPrice;
        require(
            msg.value >= payableAmount,
            "Insufficient funds to purchase ticket"
        );

        // can implement returning of balance if we want.
        IDToTicket[tokenId]._ticketOwner = msg.sender;
        IDToTicket[tokenId].isListed = false;
    }

    function resellTicket(uint256 tokenId)
        public
        requireValidTicket(tokenId)
        onlyTicketOwner(tokenId)
    {
        IDToTicket[tokenId].isListed = true;
    }
}
