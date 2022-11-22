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
      { internalType: "address", name: "_delegateAddress", type: "address" },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  { stateMutability: "nonpayable", type: "fallback" },
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

const delegateAbi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "_owner",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "pwn",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const contractLevel = "0x80934BE6B8B872B364b470Ca30EaAd8AEAC4f63F";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(contractLevel, 0, "ForceFactory");
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  // Send tx with value to contract
  let balance = await ethers.provider.getBalance(challenge.address);
  console.log(`balance: ${JSON.stringify(balance)}`);
  let tx = await eoa.sendTransaction({
    to: challenge.address,
    value: ethers.utils.parseUnits("0.0000000000001", "ether"),
    gasLimit: 30000000,
  });
  tx.wait(1);
  balance = await ethers.provider.getBalance(challenge.address);
  console.log(`balance: ${JSON.stringify(balance)}`);
});

// after(async () => {
//   expect(await submitLevel(challenge.address), "level not solved").to.be.true;
// });
