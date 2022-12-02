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

const contractLevel = "0xB4802b28895ec64406e45dB504149bfE79A38A57";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(contractLevel, 0, "ElevatorFactory");
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  let attackFactory = await ethers.getContractFactory(
    "contracts/11-Building.sol:Building"
  );
  let attackContract = await attackFactory.deploy(challenge.address);
  await attackContract.deployed();

  let tx = await attackContract.attack();
  await tx.wait(1);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
