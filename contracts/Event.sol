// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MarketPlace.sol";

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
    MarketPlace marketPlace; // hardcoded address of the market place
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

    event ticketCreated(uint256 tokenId);
    event ticketBoughtDuringPostEvent(uint256 tokenId);
    event ticketBoughtDuringSales(uint256 tokenId);
    event ticketListed(uint256 tokenId);
    event ticketUnlisted(uint256 tokenId);
    event ticketCheckedIn(uint256 tokenId);
    event ticketInvalidated(uint256 tokenId);
    event ticketValidated(uint256 tokenId);

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
            msg.sender == address(marketPlace),
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
        uint256 listingPrice;
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
        //uint256 _eventDate,
        MarketPlace _marketPlace
    ) ERC721(_eventName, _symbol) {
        eventName = _eventName;
        eventOrganizer = msg.sender;
        location = _location;
        company = _company;
        numTickets = 0;
        resaleCeiling = _resaleCeiling;
        maxTicketsPerAddress = _maxTicketsPerAddress;
        commissionFee = _commissionFee;
        //eventDate = _eventDate;
        currentStage = eventStage.PRESALES;
        marketPlace = _marketPlace;
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
            _creationPrice, // initial listing price is the creation price
            true,
            false,
            true
        );
        uint256 newTicketId = numTickets++;
        _safeMint(address(marketPlace), newTicketId);
        IDToTicket[newTicketId] = newTicket;
        typeToTicketIds[_type].push(newTicketId);
        emit ticketCreated(newTicketId);
        return newTicketId;
    }

    function buyTicketsDuringPostEvent(uint256 tokenId)
        public
        payable
        requireValidTicket(tokenId)
        requiredEventStage(eventStage.POSTEVENT)
    {
        Ticket memory ticketToBuy = IDToTicket[tokenId];
        require(ticketToBuy.isListed == true, "Cannot buy, Ticket not lised");
        // ticket count does not matter any more after the event
        safeTransferFrom(ticketToBuy._ticketOwner, msg.sender, tokenId);
        ticketToBuy._ticketOwner = msg.sender;
        ticketToBuy.isListed = false;
        emit ticketBoughtDuringPostEvent(tokenId);
    }

    function createTicketInBulk(
        string memory _seat,
        string memory _type,
        uint256 _creationPrice,
        uint256 _numOfTickets
    ) public onlyEventOrganizer requiredEventStage(eventStage.PRESALES) {
        for (uint256 i = 0; i < _numOfTickets; i++) {
            uint256 tokenId = createTicket(_seat, _type, _creationPrice);
            listTicket(tokenId, _creationPrice);
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
        uint256 payableAmount = IDToTicket[tokenId].listingPrice;
        require(
            msg.value >= payableAmount,
            "Insufficient funds to purchase ticket"
        );
        require(IDToTicket[tokenId].isListed == true, "Ticket not listed");

        uint256 amountPaid = msg.value;
        // ticket was resold
        if (IDToTicket[tokenId]._ticketOwner != address(0)) {
            ticketCountPerOwner[IDToTicket[tokenId]._ticketOwner]--;
            address payable reseller = payable(
                address(uint160(IDToTicket[tokenId]._ticketOwner))
            );
            uint256 resaleValAfterCommission = amountPaid - commissionFee;
            reseller.transfer(resaleValAfterCommission);
        }

        // tx.origin is used since the original buyer calls this function via market place contract
        ticketCountPerOwner[tx.origin]++;

        // can implement returning of balance if we want.
        IDToTicket[tokenId]._ticketOwner = tx.origin;
        IDToTicket[tokenId].isListed = false;
        emit ticketBoughtDuringSales(tokenId);
    }

    // only need to list ticket during sales period
    // after sales become post sales the ticket can be sold as an NFT
    function listTicket(uint256 tokenId, uint256 _newListingPrice)
        public
        requireValidTicket(tokenId)
        onlyTicketOwner(tokenId)
        requiredEventStage(eventStage.SALES)
    {
        require(
            IDToTicket[tokenId].isListed == false,
            "Ticket is currently listed"
        );

        require(
            _newListingPrice <= resaleCeiling + commissionFee,
            string(
                abi.encodePacked(
                    "Resale price cannot be greater than ",
                    resaleCeiling
                )
            )
        );

        IDToTicket[tokenId].isListed = true;
        emit ticketListed(tokenId);
    }

    function unlistTicket(uint256 tokenId)
        public
        requireValidTicket(tokenId)
        onlyTicketOwner(tokenId)
        requiredEventStage(eventStage.SALES)
    {
        require(
            IDToTicket[tokenId].isListed == true,
            "Ticket is currently unlisted"
        );
        IDToTicket[tokenId].isListed = false;
        emit ticketUnlisted(tokenId);
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
        emit ticketCheckedIn(tokenId);
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
        emit ticketValidated(tokenId);
    }

    //////////////////////////////////////////////////////
    // state changing functions

    // presalse --> sales
    function changeStateToSales()
        public
        onlyEventOrganizer
        requiredEventStage(eventStage.PRESALES)
    {
        currentStage = eventStage.SALES;
    }

    // sales --> during event
    function changeStateToDuring()
        public
        onlyEventOrganizer
        requiredEventStage(eventStage.SALES)
    {
        currentStage = eventStage.DURINGEVENT;
    }

    // during event --> post event
    // called by the token owner
    function changeStateToPostEvent()
        public
        onlyEventOrganizer
        requiredEventStage(eventStage.DURINGEVENT)
    {
        currentStage = eventStage.POSTEVENT;
    }
}
