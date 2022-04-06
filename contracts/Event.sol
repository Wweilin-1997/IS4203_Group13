// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MarketPlace.sol";

contract Event is Ownable {
    MarketPlace marketplaceContract;
    eventStage currentStage;
    uint256 public numEvents = 0;
    mapping(uint256 => ticketEvent) public ticketEvents;

    enum eventStage {
        PRESALES,
        SALES,
        DURINGEVENT,
        POSTEVENT
    }

    event ticketCreated(uint256 ticketId);
    event ticketUnlisted(uint256 ticketId);

    modifier requiredEventStage(eventStage stage) {
        require(
            stage == currentStage,
            "The action is not available at this stage"
        );
        _;
    }

    // modifier onlyTicketOwner(uint256 tokenId) {
    //     require(_exists(tokenId), "Please enter a valid ticket id");
    //     require(
    //         IDToTicket[tokenId]._ticketOwner == msg.sender,
    //         "You're not authorized to perform this action"
    //     );
    //     _;
    // }

    // modifier onlyEventOrganizer() {
    //     require(
    //         msg.sender == eventOrganizer,
    //         "Only the event organizer can perform this action"
    //     );
    //     _;
    // }

    // modifier onlyMarketPlace() {
    //     require(
    //         msg.sender == marketPlaceAddress,
    //         "You're not authorized to perform this action"
    //     );
    //     _;
    // }

    // modifier requireValidTicket(uint256 tokenId) {
    //     require(_exists(tokenId), "Please enter a valid ticket id");
    //     _;
    // }

    // modifier addressCanPurchaseMore(address buyer) {
    //     require(
    //         ticketCountPerOwner[buyer] < maxTicketsPerAddress,
    //         "Buyer already reached the max limit"
    //     );
    //     _;
    // }

    struct ticketEvent {
        // address _marketPlaceAddress;
        string  _eventName;
        string  _symbol;
        string  _location;
        string  _company;
        uint256 _resaleCeiling;
        uint256 _maxTicketsPerAddress;
        uint256 _commissionFee;
        uint256 _eventDate;
        address _eventOrganizer;
        eventStage stage;
    }

    constructor(MarketPlace marketplaceAddress)  {
        marketplaceContract = marketplaceAddress;
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
    ) public returns(uint256) {
        ticketEvent memory eventInstance = ticketEvent(
            _eventName,
            _symbol,
            _location,
            _company,
            _resaleCeiling,
            _maxTicketsPerAddress,
            _commissionFee,
            _eventDate,
            msg.sender,
            eventStage.PRESALES
        );
        uint256 newEventId = numEvents++;
        ticketEvents[newEventId] = eventInstance;
        return newEventId;
    }


    // function buyTicketsDuringPostEvent(uint256 tokenId)
    //     public
    //     payable
    //     requireValidTicket(tokenId)
    //     requiredEventStage(eventStage.POSTEVENT)
    // {
    //     Ticket memory ticketToBuy = IDToTicket[tokenId];
    //     require(ticketToBuy.isListed == true, "Cannot buy, Ticket not lised");
    //     // ticket count does not matter any more after the event
    //     safeTransferFrom(ticketToBuy._ticketOwner, msg.sender, tokenId);
    //     ticketToBuy._ticketOwner = msg.sender;
    //     ticketToBuy.isListed = false;

    //     // is tokenId == ticketId?
    //     emit ticketBought(tokenId);
    // }

    // function buyTicketsDuringSales(uint256 tokenId)
    //     public
    //     payable
    //     onlyOwner
    //     requiredEventStage(eventStage.SALES)
    //     requireValidTicket(tokenId)
    //     addressCanPurchaseMore(msg.sender)
    // {
    //     uint256 payableAmount = IDToTicket[tokenId].listingPrice;
    //     require(
    //         msg.value >= payableAmount,
    //         "Insufficient funds to purchase ticket"
    //     );
    //     require(IDToTicket[tokenId].isListed == true, "Ticket not listed");

    //     uint256 amountPaid = msg.value;
    //     // ticket was resold
    //     if (IDToTicket[tokenId]._ticketOwner != address(0)) {
    //         ticketCountPerOwner[IDToTicket[tokenId]._ticketOwner]--;
    //         address payable reseller = payable(
    //             address(uint160(IDToTicket[tokenId]._ticketOwner))
    //         );
    //         uint256 resaleValAfterCommission = amountPaid - commissionFee;
    //         reseller.transfer(resaleValAfterCommission);
    //     }

    //     // tx.origin is used since the original buyer calls this function via market place contract
    //     ticketCountPerOwner[tx.origin]++;

    //     // can implement returning of balance if we want.
    //     IDToTicket[tokenId]._ticketOwner = tx.origin;
    //     IDToTicket[tokenId].isListed = false;
    //     emit ticketBought(tokenId);
    // }

    // only need to list ticket during sales period
    // after sales become post sales the ticket can be sold as an NFT
    // function listTicket(uint256 tokenId, uint256 _newListingPrice)
    //     public
    //     requireValidTicket(tokenId)
    //     onlyTicketOwner(tokenId)
    //     requiredEventStage(eventStage.SALES)
    // {
    //     require(
    //         IDToTicket[tokenId].isListed == false,
    //         "Ticket is currently listed"
    //     );

    //     require(
    //         _newListingPrice <= resaleCeiling + commissionFee,
    //         string(
    //             abi.encodePacked(
    //                 "Resale price cannot be greater than ",
    //                 resaleCeiling
    //             )
    //         )
    //     );

    //     IDToTicket[tokenId].isListed = true;
    //     emit ticketListed(tokenId);
    // }

    // function unlistTicket(uint256 tokenId)
    //     public
    //     requireValidTicket(tokenId)
    //     onlyTicketOwner(tokenId)
    //     requiredEventStage(eventStage.SALES)
    // {
    //     require(
    //         IDToTicket[tokenId].isListed == true,
    //         "Ticket is currently unlisted"
    //     );
    //     IDToTicket[tokenId].isListed = false;
    //     emit ticketUnlisted(tokenId);
    // }

    //////////////////////////////////////////////////////////
    // Event Day Functions
    // function checkInTicket(uint256 tokenId)
    //     public
    //     onlyEventOrganizer
    //     requireValidTicket(tokenId)
    //     requiredEventStage(eventStage.SALES)
    // {
    //     require(
    //         IDToTicket[tokenId].isValid == true,
    //         "The ticket has been invalidated"
    //     );
    //     require(
    //         IDToTicket[tokenId].isCheckedIn == false,
    //         "Ticket is already checked in"
    //     );
    //     IDToTicket[tokenId].isCheckedIn = true;
    //     emit ticketCheckedIn(tokenId);
    // }

    //////////////////////////////////////////////////////////
    // Administration Functions
    // function invalidateTicket(uint256 tokenId)
    //     public
    //     onlyEventOrganizer
    //     requireValidTicket(tokenId)
    // {
    //     require(
    //         IDToTicket[tokenId].isValid == true,
    //         "The ticket has already been invalidated"
    //     );

    //     IDToTicket[tokenId].isValid = false;
    //     emit ticketInvalidated(tokenId);
    // }

    // function validateTicket(uint256 tokenId)
    //     public
    //     onlyEventOrganizer
    //     requireValidTicket(tokenId)
    // {
    //     require(
    //         IDToTicket[tokenId].isValid == false,
    //         "The ticket is already valid"
    //     );

    //     IDToTicket[tokenId].isValid = true;

    //     emit ticketValidated(tokenId);
    // }

    //////////////////////////////////////////////////////
    // state changing functions

    // presalse --> sales
    // function changeStateToSales()
    //     public
    //     onlyEventOrganizer
    //     requiredEventStage(eventStage.PRESALES)
    // {
    //     currentStage = eventStage.SALES;
    // }

    // // sales --> during event
    // function changeStateToDuring()
    //     public
    //     onlyEventOrganizer
    //     requiredEventStage(eventStage.SALES)
    // {
    //     currentStage = eventStage.DURINGEVENT;
    // }

    // // during event --> post event
    // // called by the token owner
    // function changeStateToPostEvent()
    //     public
    //     onlyEventOrganizer
    //     requiredEventStage(eventStage.DURINGEVENT)
    // {
    //     currentStage = eventStage.POSTEVENT;
    // }

    ////////////////////////////////////////////////////////////
    //getters

    // function getEventId() public view returns (uint256) {
    //     return eventId;
    // }

    function getEventName(uint256 eventId) public view returns (string memory) {
        return ticketEvents[eventId]._eventName;
    }

    function getEventOrganizer(uint256 eventId) public view returns (address) {
        return ticketEvents[eventId]._eventOrganizer;
    }

    function getCompany(uint256 eventId) public view returns (string memory) {
        return ticketEvents[eventId]._company;
    }

    function getResaleCeiling(uint256 eventId) public view returns (uint256) {
        return ticketEvents[eventId]._resaleCeiling;
    }

    function getEventDate(uint256 eventId) public view returns (uint256) {
        return ticketEvents[eventId]._eventDate;
    }
    



    // function getMarketPlaceInstance() public view returns (MarketPlace) {
    //     return marketPlace;
    // }
}
