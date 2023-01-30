const hre = require("hardhat");
const { expect } = require("chai");

describe("Airbnb", function () {
  let deployContract, owner, customer;
  it("Contract Dployement", async function () {
    [owner, customer] = await ethers.getSigners();
    const mainContract = await ethers.getContractFactory("Airbnb");
    deployContract = await mainContract.deploy();
    await deployContract.deployed();
    console.log("Contract Address :", deployContract.address);

  })

  it("Rent_out_Property", async function () {
    const rentOutTranasaction = await deployContract.rentOutProperty("Flat", "2BHK 2bed 2 bathroom 1 kitchen 1 hall", 20000, owner.address);

    await rentOutTranasaction.wait();
    console.log("Property Details", await deployContract.properties(0));

  })

  it("Rent_Propert", async function () {
    //const rentProperty_tranasaction= await deployContract.rentProperty(0,)
   
  const checkinDate = new Date("2022-08-25");
  console.log(checkinDate.getTime());
  const checkOutDate = new Date("2022-08-30");
  console.log(checkOutDate.getTime());
  const  rentProperty_transaction=await deployContract.rentProperty(1,checkinDate.getTime(),checkOutDate.getTime());
  await rentProperty_transaction.wait();
  })
})

