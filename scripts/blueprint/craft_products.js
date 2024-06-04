const { ethers } = require('hardhat');

const craftProducts = [
  {
    id: 1,
    name: "butter",
    duration: 350,
    price: ethers.utils.parseEther("216").toString(),
    expReward: 18,
    craftType: 1,
    requirements: [
      {
        animalKindId: '1', //Cow
        quantity: '3'
      }
    ]
  },
  {
    id: 2,
    name: "whipped_cream",
    duration: 350,
    price: ethers.utils.parseEther("288").toString(),
    expReward: 24,
    craftType: 1,
    requirements: [
      {
        animalKindId: '1', //Cow
        quantity: '4'
      }
    ]
  },
  {
    id: 3,
    name: "ice_cream",
    duration: 350,
    price: ethers.utils.parseEther("360").toString(),
    expReward: 30,
    craftType: 1,
    requirements: [
      {
        animalKindId: '1', //Cow
        quantity: '5'
      }
    ]
  },
  {
    id: 4,
    name: "bread",
    duration: 300,
    price: ethers.utils.parseEther("129").toString(),
    expReward: 9,
    craftType: 2,
    requirements: [
      {
        animalKindId: '2', //Chicken
        quantity: '3'
      }
    ]
  },
  {
    id: 5,
    name: "croissant",
    duration: 300,
    price: ethers.utils.parseEther("172").toString(),
    expReward: 12,
    craftType: 2,
    requirements: [
      {
        animalKindId: '2', //Chicken
        quantity: '4'
      }
    ]
  },
  {
    id: 6,
    name: "cupcake",
    duration: 300,
    price: ethers.utils.parseEther("216").toString(),
    expReward: 15,
    craftType: 2,
    requirements: [
      {
        animalKindId: '2', //Chicken
        quantity: '5'
      }
    ]
  },
  {
    id: 7,
    name: "apple_juice",
    duration: 300,
    price: ethers.utils.parseEther("72").toString(),
    expReward: 2,
    craftType: 3,
    requirements: [
      {
        seedId: '1', //Apple
        quantity: '4'
      }
    ]
  },
  {
    id: 8,
    name: "orange_juice",
    duration: 250,
    price: ethers.utils.parseEther("108").toString(),
    expReward: 4,
    craftType: 3,
    requirements: [
      {
        seedId: '2', //Orange
        quantity: '4'
      }
    ]
  }, {
    id: 9,
    name: "pumpkin_juice",
    duration: 250,
    price: ethers.utils.parseEther("144").toString(),
    expReward: 7,
    craftType: 3,
    requirements: [
      {
        seedId: '3', //Pumpkin
        quantity: '4'
      }
    ]
  }
]

exports.craftProducts = craftProducts;