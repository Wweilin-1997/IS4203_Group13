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
    MarketPlace marketPlace;
    string ticketImageUrl;
    mapping(uint256 => Ticket) IDToTicket;
    mapping(address => uint256) ticketCountPerOwner;
    EventStage currentStage;
    mapping(string => uint256[]) typeToTicketIds;

    enum EventStage {
        PRESALES,
        SALES,
        DURINGEVENT,
        POSTEVENT
    }

    event ticketCreated(uint256 tokenId);
    event ticketBoughtDuringPostEvent(uint256 tokenId);
    event ticketBoughtDuringSales(uint256 tokenId, address newOwner);
    event ticketListed(uint256 tokenId);
    event ticketUnlisted(uint256 tokenId);
    event ticketCheckedIn(uint256 tokenId);
    event ticketInvalidated(uint256 tokenId);
    event ticketValidated(uint256 tokenId);

    modifier requiredEventStage(EventStage stage) {
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
        address _ticketOwner;
        string _seat;
        uint256 _seatID;
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
        currentStage = EventStage.PRESALES;
        marketPlace = _marketPlace;
    }

    function addEventToMarketplace() public {
        marketPlace.addEvent(address(this));
    }

    function createTicket(
        string memory _seat,
        string memory _type,
        uint256 _creationPrice,
        uint256 _seatID
    )
        public
        onlyEventOrganizer
        requiredEventStage(EventStage.PRESALES)
        returns (uint256)
    {
        Ticket memory newTicket = Ticket(
            eventOrganizer,
            _seat,
            _seatID,
            _type,
            _creationPrice,
            _creationPrice, // initial listing price is the creation price
            false, //isListed set to false
            false,
            true
        );
        uint256 newTicketId = numTickets++;
        _safeMint(address(marketPlace), newTicketId);
        IDToTicket[newTicketId] = newTicket;
        typeToTicketIds[_type].push(newTicketId);
        listTicket(newTicketId, _creationPrice);
        emit ticketCreated(newTicketId);
        return newTicketId;
    }

    function buyTicketsDuringPostEvent(uint256 tokenId)
        public
        payable
        requireValidTicket(tokenId)
        requiredEventStage(EventStage.POSTEVENT)
    {
        Ticket memory ticketToBuy = IDToTicket[tokenId];
        require(ticketToBuy.isListed == true, "Cannot buy, Ticket not lised");
        uint256 listedPrice = ticketToBuy.listingPrice;
        require(
            (listedPrice * (100 + commissionFee)) / 100 <= msg.value,
            "Insufficient ETH!"
        );
        // ticket count does not matter any more after the event
        // transfer ticket to buyer
        safeTransferFrom(ticketToBuy._ticketOwner, msg.sender, tokenId);

        // transfer money to seller
        address payable originalOwner = payable(
            address(uint160(ticketToBuy._ticketOwner))
        );
        originalOwner.transfer(listedPrice);

        //transfer comission fee to event organiser
        address payable organiser = payable(address(uint160(eventOrganizer)));

        organiser.transfer((listedPrice * commissionFee) / 100);

        address payable buyer = payable(address(uint160(tx.origin)));

        buyer.transfer(
            msg.value - listedPrice - ((listedPrice * commissionFee) / 100)
        );

        ticketToBuy._ticketOwner = msg.sender;
        ticketToBuy.isListed = false;

        marketPlace.unlistTicket(address(this), tokenId);
        emit ticketBoughtDuringPostEvent(tokenId);
    }

    function createTicketInBulk(
        string memory _seat,
        string memory _type,
        uint256 _creationPrice,
        uint256 _numOfTickets
    ) public onlyEventOrganizer requiredEventStage(EventStage.PRESALES) {
        for (uint256 i = 0; i < _numOfTickets; i++) {
            uint256 currentSeatID = i;

            createTicket(_seat, _type, _creationPrice, currentSeatID);
        }
    }

    function buyTicketsDuringSales(uint256 tokenId)
        public
        payable
        onlyMarketPlace
        requiredEventStage(EventStage.SALES)
        requireValidTicket(tokenId)
        addressCanPurchaseMore(tx.origin)
    {
        Ticket storage ticket = IDToTicket[tokenId];
        uint256 payableAmount = ticket.listingPrice;
        require(
            msg.value >= payableAmount,
            "Insufficient funds to purchase ticket"
        );
        require(IDToTicket[tokenId].isListed == true, "Ticket not listed");

        address payable reseller = payable(
            address(uint160(ticket._ticketOwner))
        );
        address payable buyer = payable(address(uint160(tx.origin)));
        // ticket was resold
        if (ticket._ticketOwner != eventOrganizer) {
            ticketCountPerOwner[ticket._ticketOwner]--;
            address payable eventOrganiser = payable(
                address(uint160(eventOrganizer))
            );
            reseller.transfer(payableAmount);
            eventOrganiser.transfer((payableAmount * commissionFee) / 100);
            buyer.transfer(
                msg.value -
                    payableAmount -
                    ((payableAmount * commissionFee) / 100)
            );
            ticketCountPerOwner[ticket._ticketOwner]--;
        } else {
            // no commission
            reseller.transfer(payableAmount);
            buyer.transfer(msg.value - payableAmount);
        }

        // tx.origin is used since the original buyer calls this function via market place contract
        ticketCountPerOwner[tx.origin]++;

        // can implement returning of balance if we want.
        ticket._ticketOwner = tx.origin;
        ticket.isListed = false;
        emit ticketBoughtDuringSales(tokenId, tx.origin);
    }

    // only need to list ticket during sales period
    // after sales become post sales the ticket can be sold as an NFT
    function listTicket(uint256 tokenId, uint256 _newListingPrice)
        public
        requireValidTicket(tokenId)
    {
        require(
            IDToTicket[tokenId].isListed == false,
            "Ticket is currently listed"
        );

        uint256 creationPrice = IDToTicket[tokenId].creationPrice;

        require(
            _newListingPrice <=
                (creationPrice * (resaleCeiling + 100) / 100) * (commissionFee + 100) / 100,
            "Resale price cannot be greater than ceiling"
        );

        IDToTicket[tokenId].listingPrice = _newListingPrice;
        IDToTicket[tokenId].isListed = true;
        marketPlace.listTicket(address(this), tokenId, _newListingPrice);
        emit ticketListed(tokenId);
    }

    function unlistTicket(uint256 tokenId)
        public
        requireValidTicket(tokenId)
        onlyTicketOwner(tokenId)
        requiredEventStage(EventStage.SALES)
    {
        require(
            IDToTicket[tokenId].isListed == true,
            "Ticket is currently unlisted"
        );
        IDToTicket[tokenId].isListed = false;
        marketPlace.unlistTicket(address(this), tokenId);
        emit ticketUnlisted(tokenId);
    }

    //////////////////////////////////////////////////////////
    // Event Day Functions
    function checkInTicket(uint256 tokenId)
        public
        onlyEventOrganizer
        requireValidTicket(tokenId)
        requiredEventStage(EventStage.SALES)
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
        emit ticketInvalidated(tokenId);
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
        requiredEventStage(EventStage.PRESALES)
    {
        currentStage = EventStage.SALES;
    }

    // sales --> during event
    function changeStateToDuring()
        public
        onlyEventOrganizer
        requiredEventStage(EventStage.SALES)
    {
        currentStage = EventStage.DURINGEVENT;
    }

    // during event --> post event
    // called by the token owner
    function changeStateToPostEvent()
        public
        onlyEventOrganizer
        requiredEventStage(EventStage.DURINGEVENT)
    {
        currentStage = EventStage.POSTEVENT;
    }

    // getters
    function getTicket(uint256 ticketId) public view returns (Ticket memory) {
        return IDToTicket[ticketId];
    }

    function getEventName() public view returns (string memory) {
        return eventName;
    }

    function getEventOrganizer() public view returns (address) {
        return eventOrganizer;
    }

    function getLocation() public view returns (string memory) {
        return location;
    }

    function getCompany() public view returns (string memory) {
        return company;
    }

    function getTotalTickets() public view returns (uint256) {
        return numTickets;
    }

    function getMaxTicksPerAddress() public view returns (uint256) {
        return maxTicketsPerAddress;
    }

    function getComissionFee() public view returns (uint256) {
        return commissionFee;
    }

    function getEventDate() public view returns (uint256) {
        return eventDate;
    }

    function getTicketImageUrl() public view returns (string memory) {
        return ticketImageUrl;
    }

    function getTicketsListForEventType(string memory _type)
        public
        view
        returns (uint256[] memory)
    {
        return typeToTicketIds[_type];
    }

    function getCurrentTicketCount(address countAddress)
        public
        view
        returns (uint256)
    {
        return ticketCountPerOwner[countAddress];
    }

    function getCurrentEventStage() public view returns (uint256) {
        return uint256(currentStage);
    }

    function getEventContractAddress() public view returns (address) {
        return address(this);
    }
}
