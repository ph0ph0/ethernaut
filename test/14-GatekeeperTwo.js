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
    inputs: [{ internalType: "bytes8", name: "_gateKey", type: "bytes8" }],
    name: "enter",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0x3370204e",
  },
  {
    inputs: [],
    name: "entrant",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
    constant: true,
    signature: "0x9db31d77",
  },
];

const contractLevel = "0xF781b45d11A37c51aabBa1197B61e6397aDf1f78";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(
    contractLevel,
    0,
    "GatekeeperTwoFactory"
  );
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {});

// after(async () => {
//   expect(await submitLevel(challenge.address), "level not solved").to.be.true;
// });
