const { Contract, Signer, getDefaultProvider } = require("ethers");
const { LogDescription } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

// manually copied from the website while inspect the web console's `ethernaut.abi`
ETHERNAUT_ABI = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "player",
        type: "address",
      },
      {
        indexed: false,
        internalType: "contract Level",
        name: "level",
        type: "address",
      },
    ],
    name: "LevelCompletedLog",
    type: "event",
    signature:
      "0x9dfdf7e3e630f506a3dfe38cdbe34e196353364235df33e5a3b588488d9a1e78",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "player",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "instance",
        type: "address",
      },
    ],
    name: "LevelInstanceCreatedLog",
    type: "event",
    signature:
      "0x7bf7f1ed7f75e83b76de0ff139966989aff81cb85aac26469c18978d86aac1c2",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
    signature:
      "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
  },
  {
    inputs: [
      {
        internalType: "contract Level",
        name: "_level",
        type: "address",
      },
    ],
    name: "createLevelInstance",
    outputs: [],
    stateMutability: "payable",
    type: "function",
    payable: true,
    signature: "0xdfc86b17",
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
    constant: true,
    signature: "0x8da5cb5b",
  },
  {
    inputs: [
      {
        internalType: "contract Level",
        name: "_level",
        type: "address",
      },
    ],
    name: "registerLevel",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0x202023d4",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0x715018a6",
  },
  {
    inputs: [
      {
        internalType: "address payable",
        name: "_instance",
        type: "address",
      },
    ],
    name: "submitLevelInstance",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0xc882d7c2",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
    signature: "0xf2fde38b",
  },
];

ETHERNAUT_ADDRESS = `0xe04f955e4Cf9858F8f8d60C09aBf16DF23D4672b`;

module.exports.submitLevel = async (address) => {
  try {
    const ethernaut = await ethers.getContractAt(
      ETHERNAUT_ABI,
      ETHERNAUT_ADDRESS
    );
    let tx = await ethernaut.submitLevelInstance(address);
    await tx.wait();

    const txReceipt = await ethernaut.provider.getTransactionReceipt(tx.hash);
    if (txReceipt.logs.length === 0) return false;

    const event = ethernaut.interface.parseLog(txReceipt.logs[0]);
    return event.name === `LevelCompletedLog`;
  } catch (error) {
    console.error(`submitLevel: ${error.message}`);
    return false;
  }
};

module.exports.createChallenge = async (
  contractLevel,
  value = `0`,
  levelNameFactory = ""
) => {
  const provider = await ethers.provider;
  console.log(`ad: ${JSON.stringify(ETHERNAUT_ADDRESS)}`);
  const contractCode = await provider.getCode(ETHERNAUT_ADDRESS);

  // If no code is deployed to the ethernaut mumbai address, then we are
  // not on a fork and must deploy our own code.
  // Create our own boolean on the hardhat runtime environment called localNetwork,
  // which we can check across our codebase.
  hre.localNetwork = false;
  if (contractCode == "0x") {
    hre.localNetwork = true;
    // Deploy Ethernaut contract
    const ethernautFactory = await ethers.getContractFactory("Ethernaut");
    console.log("!!!Deploying ethernaut contract");
    const ethernaut = await ethernautFactory.deploy();
    await ethernaut.deployed();
    console.log(`deployed ethernaut to: ${JSON.stringify(ethernaut.address)}`);

    // Update the ethernaut address to the deployed address
    ETHERNAUT_ADDRESS = ethernaut.address;

    // Now we need to register the level with the ethernaut contract. We do
    // that by passing in ContractFactory contract for the level.
    if (levelNameFactory == "") {
      throw Error("You must provide a level name if on local hh network");
    }
    const contractFactory = await ethers.getContractFactory(levelNameFactory);
    const coinFlipContractFactory = await contractFactory.deploy();
    await coinFlipContractFactory.deployed();
    console.log(
      `coinflipFactory address: ${JSON.stringify(
        coinFlipContractFactory.address
      )}`
    );

    // Next, register the contract factory address with Ethernaut contract
    const registerTx = await ethernaut.registerLevel(
      coinFlipContractFactory.address
    );
    const registerTxRt = await registerTx.wait(1);
    // console.log(`registerTxRt: ${JSON.stringify(registerTxRt)}`);
    // Finally, overwrite the contractLevel param with the coin flip factory
    // address.
    contractLevel = coinFlipContractFactory.address;
  }
  console.log(`ethernaut address is: ${JSON.stringify(ETHERNAUT_ADDRESS)}`);
  try {
    console.log(`creating challenge: ${JSON.stringify(contractLevel)}`);
    const ethernaut = await ethers.getContractAt(
      ETHERNAUT_ABI,
      ETHERNAUT_ADDRESS
    );
    let tx = await ethernaut.createLevelInstance(contractLevel, {
      value,
    });
    await tx.wait();
    const txReceipt = await ethernaut.provider.getTransactionReceipt(tx.hash);
    if (txReceipt.logs.length === 0) throw new Error(`No event found`);
    const events = txReceipt.logs
      .map((log) => {
        try {
          return ethernaut.interface.parseLog(log);
        } catch {
          return undefined;
        }
      })
      .filter(Boolean);

    const event = events.find(
      (event) => event.name === `LevelInstanceCreatedLog` && event.args.instance
    );
    if (!event) throw new Error(`Invalid Event ${JSON.stringify(event)}`);

    return event.args.instance;
  } catch (error) {
    console.error(`createChallenge Error: ${error.message}`);
    throw new Error(`createChallenge failed: ${error.message}`);
  }
};
