const { expect } = require("chai");
const { Contract, Signer } = require("ethers");
const { keccak256 } = require("ethers/lib/utils");
const { ethers, waffle } = require("hardhat");
const {
  createChallenge,
  submitLevel,
  ETHERNAUT_ABI,
  ETHERNAUT_ADDRESS,
} = require("./utils");

const abi = [
  {
    inputs: [],
    name: "floor",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x40695363",
  },
  {
    inputs: [{ internalType: "uint256", name: "_floor", type: "uint256" }],
    name: "goTo",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0xed9a7134",
  },
  {
    inputs: [],
    name: "top",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0xfe6dcdba",
  },
];

const contractLevel = "0x1ca9f1c518ec5681C2B7F97c7385C0164c3A22Fe";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(contractLevel, 0, "PrivacyFactory");
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  let data = await ethers.provider.getStorageAt(challenge.address, 5);
  console.log(`data: ${JSON.stringify(data)}`);
});

// after(async () => {
//   expect(await submitLevel(challenge.address), "level not solved").to.be.true;
// });
