const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

var Event = artifacts.require("../contracts/Event.sol");
var MarketPlace = artifacts.require("../contracts/MarketPlace.sol");

/*Testing Event Related Use Cases*/

contract("Event", function (accounts) {
  before(async () => {
    eventInstance = await Event.deployed();
    marketplaceInstance = await MarketPlace.deployed();
  });

  /**Testing Event */

  console.log("Testing Event Contract");

  it("Create Event - Event contract deployed and Event Organizer attribute is set to deployer address", async () => {
    let eventOrganizer = await eventInstance.getEventOrganizer();
    assert.strictEqual(
      eventOrganizer,
      accounts[0],
      "Event was not created by the right address"
    );
  });

  it("Add Event to Marketplace", async () => {
    //let eventAddress0 = await eventInstance.getEventContractAddress();
    //console.log(eventAddress0);
    await eventInstance.addEventToMarketplace();

    let event = await marketplaceInstance.getEvent(eventInstance.address);
    // console.log("event instance: " + eventInstance.address);
    // console.log("event: " + event);
    assert.strictEqual(
      event,
      eventInstance.address,
      "address are not the same"
    );
  });

  it("Create Tickets in Bulk for a particular Type by wrong Non Event Organizer", async () => {
    let numberOfTicketsTobeCreated = 5;
    let eventType = "A";

    await truffleAssert.reverts(
      eventInstance.createTicketInBulk(
        "A",
        eventType,
        50000000000000000n,
        numberOfTicketsTobeCreated,
        {
          from: accounts[1],
        }
      ),
      "Only the event organizer can perform this action"
    );
  });

  it("Create Tickets in Bulk for a particular Type by correct EventOrganizer", async () => {
    let numberOfTicketsTobeCreated = 5;
    let eventType = "A";

    let ticketsForEvent0 = await eventInstance.createTicketInBulk(
      "A",
      eventType,
      50000000000000000n,
      numberOfTicketsTobeCreated,
      { from: accounts[0] }
    );

    // let listedPrice = await marketplaceInstance.getTicketPrice(eventInstance, 2);
    // console.log(listedPrice);

    let typeToTicketIdsForEvent0 =
      await eventInstance.getTicketsListForEventType(eventType);
    // console.log(typeToTicketIdsForEvent0)

    truffleAssert.eventEmitted(ticketsForEvent0, "ticketCreated");

    assert.strictEqual(
      numberOfTicketsTobeCreated,
      typeToTicketIdsForEvent0.length,
      "Failed to create correct number of tickets"
    );
  });

  it("Transferring tickets from one user to another", async () => {
    // let transferTicket = await eventInstance.tra
  });

  it("Invalidate ticket", async () => {
    let invalidateTicket = await eventInstance.invalidateTicket(0, {
      from: accounts[0],
    });
    let ticketAfterUpdate = await eventInstance.getTicket(0);
    let newValidity = ticketAfterUpdate.isValid;

    truffleAssert.eventEmitted(invalidateTicket, "ticketInvalidated");
    assert.strictEqual(newValidity, false, "Failed Invalidate ticket");
  });

  it("Validate ticket", async () => {
    let validateTicket = await eventInstance.validateTicket(0, {
      from: accounts[0],
    });
    let ticketAfterUpdate = await eventInstance.getTicket(0);
    let newValidity = ticketAfterUpdate.isValid;

    truffleAssert.eventEmitted(validateTicket, "ticketValidated");
    assert.strictEqual(newValidity, true, "Failed Invalidate ticket");
  });

  it("Change State to SALES", async () => {
    //check for error message if change of state performed by non event organizers
    await truffleAssert.reverts(
      eventInstance.changeStateToSales({ from: accounts[1] }),
      "Only the event organizer can perform this action"
    );

    await eventInstance.changeStateToSales({ from: accounts[0] });
  });

  it("Create new Tickets during Non-PRESALES stage", async () => {
    let numberOfTicketsTobeCreated = 5;
    let eventType = "B";
    await truffleAssert.reverts(
      eventInstance.createTicketInBulk(
        "B",
        eventType,
        50000000000000000n,
        numberOfTicketsTobeCreated,
        {
          from: accounts[0],
        }
      ),
      "The action is not available at this stage"
    );
  });

  it("Check in ticket by Event Organizer", async () => {
    let checkInTicket0 = await eventInstance.checkInTicket(0, {
      from: accounts[0],
    });
    truffleAssert.eventEmitted(checkInTicket0, "ticketCheckedIn");

    let ticketAfterCheckIn = await eventInstance.getTicket(0);
    let checkInBool = ticketAfterCheckIn.isCheckedIn;
    assert.strictEqual(checkInBool, true, "Failed Check In ticket");
  });

  it("Checked in ticket cannot be checked in again", async () => {
    await truffleAssert.reverts(
      eventInstance.checkInTicket(0, { from: accounts[0] }),
      "Ticket is already checked in"
    );
  });

  it("Check in ticket by Non - Event Organizer", async () => {
    await truffleAssert.reverts(
      eventInstance.checkInTicket(0, { from: accounts[1] }),
      "Only the event organizer can perform this action"
    );
  });

  it("Invalidated tickets cannot be checked in", async () => {
    await eventInstance.invalidateTicket(1, { from: accounts[0] });
    let ticketAfterUpdate = await eventInstance.getTicket(1);
    await truffleAssert.reverts(
      eventInstance.checkInTicket(1, { from: accounts[0] }),
      "The ticket has been invalidated"
    );
  });

  /**Marketplace Event */
  it("Purchase tickets during initial sales", async () => {
    let eventAddress0 = await eventInstance.getEventContractAddress();

    //console.log(eventAddress0);
    let purcahse = await marketplaceInstance.buy(eventAddress0, 2, {
      from: accounts[2],
      value: Number(BigInt(5250000000000000000)),
    });
    let ticket = await eventInstance.getTicket(2);
    let ticketOwner = ticket._ticketOwner;
    let ticketCount = await eventInstance.getCurrentTicketCount(ticketOwner);
    //truffleAssert.eventEmitted(purcahse, "ticketBoughtDuringSales");
    assert.strictEqual(
      ticketOwner,
      accounts[2],
      "Failed purchase initial ticket sale"
    );
  });

  it("Purchase tickets cannot exceed max number specified by Event Organiser", async () => {
    let eventAddress0 = await eventInstance.getEventContractAddress();
    let purcahseOne = await marketplaceInstance.buy(eventAddress0, 3, {
      from: accounts[2],
      value: Number(BigInt(5250000000000000000)),
    });
    await truffleAssert.reverts(
      marketplaceInstance.buy(eventAddress0, 4, {
        from: accounts[2],
        value: Number(BigInt(5250000000000000000)),
      }),
      "Buyer already reached the max limit"
    );
  });

  it("Listing ticket must be lower then the Max Resale Value + Commission Fee", async () => {
    let eventAddress0 = await eventInstance.getEventContractAddress();
    let resaleCeiling = await eventInstance.resaleCeiling;

    await truffleAssert.reverts(
      eventInstance.listTicket(2, 7000000000000000000n),
      "Resale price cannot be greater than ceiling"
    );
  });

  it("Listing Ticket", async () => {
    let eventAddress0 = await eventInstance.getEventContractAddress();
    let listEvent = await eventInstance.listTicket(2, 50000000000000000n);

    let ticketAfterListing = await eventInstance.getTicket(2);
    let TicketisListed = ticketAfterListing.isListed;

    assert.strictEqual(TicketisListed, true, "Failed to list ticket for sale");
  });

  it("upgrade account", async () => {
    let upgrade = await marketplaceInstance.upgradeAccountToGold(accounts[3]);
    let points = await marketplaceInstance.getAccountPoints(accounts[3]);
    //console.log(points.toNumber());
    assert.strictEqual(points.toNumber(), 1501, "Failed to upgrade account");
  });

  it("Purchase tickets with gold account", async () => {
    let eventAddress0 = await eventInstance.getEventContractAddress();
    //console.log(eventAddress0);
    let purcahse = await marketplaceInstance.buy(eventAddress0, 4, {
      from: accounts[3],
      value: Number(BigInt(5050000000000000000)),
    });
    let ticket = await eventInstance.getTicket(4);
    let ticketOwner = ticket._ticketOwner;
    //truffleAssert.eventEmitted(purcahse, "ticketBoughtDuringSales");
    assert.strictEqual(ticketOwner, accounts[3], "Failed purchase ticket");
  });

  /*
    it('Change State to DURING', async () => {
        await eventInstance.changeStateToDuring({ from: accounts[0] });
    });

    it('Change State to POSTEVENt', async () => {
        await eventInstance.changeStateToPostEvent({ from: accounts[0] });
    });
    */
});
