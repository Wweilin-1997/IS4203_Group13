// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Event is ERC721 {
    string eventName;
    address eventOrganizer;
    string location;
    string company;
    uint256 numTickets;
    uint256 resaleCeiling;
    uint256 commissionFee;
    uint256 eventDate;
    mapping(uint256 => uint256) listPrice;
    address marketplace; // hardcoded address of the market place
    string ticketImageUrl;
    mapping(uint256 => Ticket) ticketsId;
    // mapping(ticketId => mapping(uint256 => address)) transactions;
    mapping(address => uint256) ticketCountPerOwner;

    struct Ticket {
        uint256 tokenId;
        address _marketPlaceAddress;
        address _ticketOwner;
        string _seat;
        string _type;
    }

    constructor(
        string memory _eventName,
        string memory _symbol,
        address _eventOrganizer,
        string memory _location,
        string memory _company,
        uint256 _numTickets,
        uint256 _resaleCeiling,
        uint256 _commissionFee,
        uint256 _eventDate
    ) ERC721(_eventName, _symbol) {
        eventName = _eventName;
        eventOrganizer = _eventOrganizer;
        location = _location;
        company = _company;
        numTickets = _numTickets;
        resaleCeiling = _resaleCeiling;
        commissionFee = _commissionFee;
        eventDate = _eventDate;
    }
}
