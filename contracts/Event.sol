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
    uint256 maxTicketsPerAddress;
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
        DURINGEVENT,
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

    modifier addressCanPurchaseMore(address buyer) {
        require(
            ticketCountPerOwner[buyer] < maxTicketsPerAddress,
            "Buyer already reached the max limit"
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
        bool isCheckedIn;
        bool isValid;
    }

    constructor(
        string memory _eventName,
        string memory _symbol,
        string memory _location,
        string memory _company,
        uint256 _resaleCeiling,
        uint256 _maxTicketsPerAddress,
        uint256 _commissionFee,
        uint256 _eventDate
    ) ERC721(_eventName, _symbol) {
        eventName = _eventName;
        eventOrganizer = msg.sender;
        location = _location;
        company = _company;
        numTickets = 0;
        resaleCeiling = _resaleCeiling;
        maxTicketsPerAddress = _maxTicketsPerAddress;
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
            true,
            false,
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
        addressCanPurchaseMore(msg.sender)
    {
        uint256 payableAmount = IDToTicket[tokenId].creationPrice;
        require(
            msg.value >= payableAmount,
            "Insufficient funds to purchase ticket"
        );

        // ticket was resold
        if (IDToTicket[tokenId]._ticketOwner != address(0)) {
            ticketCountPerOwner[IDToTicket[tokenId]._ticketOwner]--;
        }
        ticketCountPerOwner[msg.sender]++;

        // can implement returning of balance if we want.
        IDToTicket[tokenId]._ticketOwner = msg.sender;
        IDToTicket[tokenId].isListed = false;
    }

    function listTicket(uint256 tokenId)
        public
        requireValidTicket(tokenId)
        onlyTicketOwner(tokenId)
        requiredEventStage(eventStage.SALES)
    {
        // require()
        IDToTicket[tokenId].isListed = true;
    }

    //////////////////////////////////////////////////////////
    // Event Day Functions
    function checkInTicket(uint256 tokenId)
        public
        onlyEventOrganizer
        requireValidTicket(tokenId)
        requiredEventStage(eventStage.SALES)
    {
        require(
            IDToTicket[tokenId].isValid == true,
            "The ticket has been invalidated"
        );
        require(
            IDToTicket[tokenId].isCheckedIn == false,
            "Ticket is already checked in"
        );
        IDToTicket[tokenId].isCheckedIn = true;
    }

    //////////////////////////////////////////////////////////
    // Administration Functions
    function invalidateTicket(uint256 tokenId)
        public
        onlyEventOrganizer
        requireValidTicket(tokenId)
    {
        require(
            IDToTicket[tokenId].isValid == true,
            "The ticket has already been invalidated"
        );

        IDToTicket[tokenId].isValid = false;
    }

    function validateTicket(uint256 tokenId)
        public
        onlyEventOrganizer
        requireValidTicket(tokenId)
    {
        require(
            IDToTicket[tokenId].isValid == false,
            "The ticket is already valid"
        );

        IDToTicket[tokenId].isValid = true;
    }
}
