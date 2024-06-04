const hre = require("hardhat");
const dotenv = require('dotenv');
const { ethers } = require('hardhat');
const orderList = require("./order_list.json");
const _ = require('lodash');
const { deployNfts } = require('./deployNfts');
// const { craftProducts } = require('./craft_products.js');
const landMaps = require('./land_maps.json');
const welcomeItems = require('./welcome_items.json');
async function setMainConfig(blueprintAcc, diamondAddress) {
  let blueprint = await hre.ethers.getContractAt('BlueprintFacet', diamondAddress);
  tx = await blueprint.connect(blueprintAcc).setSeeds([
    '1', // apple
    '2', // orange
    '3' // pumkin
  ], [
    Number(300).toString(), // 5 minutes
    Number(360).toString(), // 6 minutes
    Number(420).toString() // 7 minutes
  ], [
    ethers.utils.parseEther("10").toString(), // 10 Currency
    ethers.utils.parseEther("20").toString(), // 20 Currency
    ethers.utils.parseEther("30").toString() // 30 Currency
  ], [
    '2', // product quantity
    '2',
    '2'
  ], [
    ethers.utils.parseEther("30").toString(), // reward per product
    ethers.utils.parseEther("45").toString(),
    ethers.utils.parseEther("60").toString()
  ], [
    '1', // exp per product
    '2',
    '3'
  ], [
    '1', // exp after harvest
    '2',
    '3'
  ]);
  await tx.wait();
  console.log('setSeeds done');


  tx = await blueprint.connect(blueprintAcc).setStoreSeedAvailableQuantities(
    [
      '1', // apple
      '2', // orange
      '3' // pumpkin
    ], [
    '1000',
    '1000',
    '1000'
  ]
  );
  await tx.wait();
  console.log('setStoreSeedAvailableQuantities done');

  tx = await blueprint.connect(blueprintAcc).setSeedsBuyable(
    [
      '1', // apple
      '2', // orange
      '3' // pumpkin
    ], [
    true,
    true,
    true
  ]);
  await tx.wait();
  console.log('setSeedsBuyable done');

  // tx = await blueprint.connect(blueprintAcc).setAnimalKinds(
  //   [
  //     '1', // Cow
  //     '2' // Chicken
  //   ], [
  //   Number(850).toString(), // minutes
  //   Number(640).toString(), // 
  // ], [
  //   ethers.utils.parseEther("50000").toString(), // 50000 Currency
  //   ethers.utils.parseEther("25000").toString(), // 25000 Currency
  // ], [
  //   '1', // product quantity
  //   '1',
  // ], [
  //   ethers.utils.parseEther("120").toString(), // reward per product
  //   ethers.utils.parseEther("72").toString(),
  // ], [
  //   '10', // exp per product
  //   '5',
  // ], [
  //   '10', // exp after harvest
  //   '5'
  // ]);
  // await tx.wait();
  // console.log('setAnimalKinds done');

  let category = {
    'None': 0,
    'Decorate': 1,
    'Building': 2,
    'Farmland': 3,
    'Trees': 4,
    'Animals': 5,
    'Items': 6,
  }
  let itemTypes = [
    {
      "id": 2,
      "name": "crop",
      "width": 1,
      "height": 1,
      "category": category['Farmland'],
      "price": ethers.utils.parseEther("50000").toString() // 50000 Currency
    },
    {
      "id": 3,
      "name": "cow_stable",
      "width": 5,
      "height": 5,
      "category": category['Building'],
      "price": ethers.utils.parseEther("200000").toString() // 200000 Currency
    },
    {
      "id": 4,
      "name": "fence_front",
      "width": 1,
      "height": 3,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("2000").toString() // 2000 Currency
    },
    {
      "id": 5,
      "name": "fencer_back",
      "width": 3,
      "height": 1,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("2000").toString() // 2000 Currency
    },
    {
      "id": 6,
      "name": "henhouse",
      "width": 5,
      "height": 5,
      "category": category['Building'],
      "price": ethers.utils.parseEther("100000").toString() // 100000 Currency
    },
    {
      "id": 7,
      "name": "hoe",
      "width": 1,
      "height": 1,
      "category": category['Items'],
      "price": ethers.utils.parseEther("2000").toString() // 2000 Currency
    },
    {
      "id": 8,
      "name": "house",
      "width": 4,
      "height": 4,
      "category": category['Building'],
      "price": "0" // 0 Currency
    },
    {
      "id": 9,
      "name": "Orderboard",
      "width": 1,
      "height": 3,
      "category": category['Building'],
      "price": "0" // 0 Currency
    },
    {
      "id": 10,
      "name": "rocks",
      "width": 3,
      "height": 2,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("200").toString() // 100 Currency
    },
    {
      "id": 11,
      "name": "tree",
      "width": 2,
      "height": 2,
      "category": category['Trees'],
      "price": ethers.utils.parseEther("200").toString() // 100 Currency
    },
    {
      "id": 12,
      "name": "trench",
      "width": 4,
      "height": 2,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("2000").toString() // 2000 Currency
    },
    {
      "id": 13,
      "name": "truck",
      "width": 4,
      "height": 2,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("3000").toString() // 1500 Currency
    },
    {
      "id": 14,
      "name": "watering_bottle",
      "width": 1,
      "height": 1,
      "category": category['Items'],
      "price": ethers.utils.parseEther("500").toString() // 500 Currency
    },
    {
      "id": 15,
      "name": "fountaint",
      "width": 2,
      "height": 2,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("10000").toString() // 5000 Currency
    },
    {
      "id": 16,
      "name": "market",
      "width": 4,
      "height": 4,
      "category": category['Building'],
      "price": "0" // 0 Currency
    },
    {
      "id": 17,
      "name": "tree_stump",
      "width": 1,
      "height": 1,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("1000").toString() // 500 Currency
    },
    {
      "id": 18,
      "name": "woodpile",
      "width": 2,
      "height": 1,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("1000").toString() // 500 Currency
    },
    {
      "id": 19,
      "name": "strawpile",
      "width": 3,
      "height": 2,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("1000").toString() // 500 Currency
    },
    {
      "id": 20,
      "name": "wood_0",
      "width": 1,
      "height": 1,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("200").toString() // 100 Currency
    },
    {
      "id": 21,
      "name": "wood_1",
      "width": 1,
      "height": 1,
      "category": category['Decorate'],
      "price": ethers.utils.parseEther("200").toString() // 100 Currency
    },
    {
      "id": 22,
      "name": "warehouse",
      "width": 3,
      "height": 3,
      "category": category['Building'],
      "price": "0" // 0 Currency
    },
    {
      "id": 23,
      "name": "dairy_craft",
      "width": 3,
      "height": 3,
      "category": category['Building'],
      "price": ethers.utils.parseEther("250000").toString()
    },
    {
      "id": 24,
      "name": "cake_craft",
      "width": 3,
      "height": 3,
      "category": category['Building'],
      "price": ethers.utils.parseEther("250000").toString()
    }, {
      "id": 25,
      "name": "juice_factory",
      "width": 3,
      "height": 3,
      "category": category['Building'],
      "price": ethers.utils.parseEther("250000").toString()
    }
  ];
  tx = await blueprint.connect(blueprintAcc).setItemTypeSize(
    itemTypes.map(item => item.id),
    itemTypes.map(item => item.width),
    itemTypes.map(item => item.height)
  );
  await tx.wait();
  console.log('setItemTypeSize done');

  tx = await blueprint.connect(blueprintAcc).setItemTypesBuyable(
    itemTypes.filter(item => item.price != '0').map(item => item.id),
    itemTypes.filter(item => item.price != '0').map(item => true)
  );
  await tx.wait();
  console.log('setItemTypesBuyable done');

  for(let i =0; i < welcomeItems.length; i++){
    tx = await blueprint.connect(blueprintAcc).setWelcomeItemsConfig(
      i,
      welcomeItems[i].map(item => item.itemType),
      welcomeItems[i].map(item => item.quantity),
      welcomeItems[i].map(item => item.positions.map(pos => pos.x)).flat(),
      welcomeItems[i].map(item => item.positions.map(pos => pos.y)).flat(),
      welcomeItems[i].map(item => item.positions.map(pos => item.isRotated)).flat(),
    );
    await tx.wait();
    console.log(`setWelcomeItemsConfig ${i} done`);

  }

  tx = await blueprint.connect(blueprintAcc).setItemTypeCategory(
    itemTypes.map(item => item.id),
    itemTypes.map(item => item.category)
  );
  await tx.wait();
  console.log('setItemTypeCategory done');

  tx = await blueprint.connect(blueprintAcc).setMaxRefreshOrderDaily(
    '4' // 4 times
  );
  await tx.wait();
  console.log('setMaxRefreshOrderDaily done');
  tx = await blueprint.connect(blueprintAcc).setMaxFulfillOrderDaily(
    '4' // 4 times
  );
  await tx.wait();
  console.log('setMaxFulfillOrderDaily done');
  tx = await blueprint.connect(blueprintAcc).setOrderRefreshFee(
    ethers.utils.parseEther("100").toString() // 100 Currency
  );
  await tx.wait();
  console.log('setMainConfig done')

  tx = await blueprint.connect(blueprintAcc).setOrderDeliveryDuration(600);
  await tx.wait();
  console.log('setOrderDeliveryDuration done')

  tx = await blueprint.connect(blueprintAcc).setFarmSupplyPrices([
    2, // fetilizer
    // 3, // cowFeed
    // 4 // chickenFeed
  ], [
    ethers.utils.parseEther("1").toString(), // 1 Currency
    // ethers.utils.parseEther("45").toString(), // 45 Currency
    // ethers.utils.parseEther("25").toString() // 25 Currency
  ]);
  await tx.wait();
  console.log('setFarmSupplyPrices done');

  tx = await blueprint.connect(blueprintAcc).setStoreFarmSupplyAvailableQuantities([
    2, // fetilizer
    // 3, // cowFeed
    // 4 // chickenFeed
  ], [
    1000,
    // 1000,
    // 1000
  ]);
  await tx.wait();
  console.log('setStoreFarmSupplyAvailableQuantities done');

  tx = await blueprint.connect(blueprintAcc).setFarmSuppliesBuyable([
    2, // fetilizer
    // 3, // cowFeed
    // 4 // chickenFeed
  ], [
    true,
    // true,
    // true
  ]);

  // tx = await blueprint.connect(blueprintAcc).setCowStableSlotUnlockPrice(
  //   ethers.utils.parseEther("50000").toString() // 500 Currency
  // );
  // await tx.wait();
  // console.log('cowStableSlotUnlockPrice done');

  // tx = await blueprint.connect(blueprintAcc).setChickenCoopSlotUnlockPrice(
  //   ethers.utils.parseEther("25000").toString() // 200 Currency
  // );
  // await tx.wait();
  // console.log('chickenCoopSlotUnlockPrice done');

  tx = await blueprint.connect(blueprintAcc).setItemTypePrices(
    itemTypes.map(item => item.id),
    itemTypes.map(item => item.price)
  );
  await tx.wait();
  console.log('setItemTypePrices done');

  tx = await blueprint.connect(blueprintAcc).setStoreItemTypeAvaiableQuantities(
    itemTypes.filter(item => item.price != '0').map(item => item.id),
    itemTypes.filter(item => item.price != '0').map(item => 1000)
  )
  await tx.wait();
  console.log('setStoreItemTypeAvaiableQuantities done');

  tx = await blueprint.connect(blueprintAcc).setMaxCropHarvestableTimes(
    '10000' // 10000 times
  );
  await tx.wait();
  console.log('setMaxCropHarvestableTimes done');

  // tx = await blueprint.connect(blueprintAcc).setInitLandPrice(
  //   ethers.utils.parseEther("0.01").toString() // 0.01 ether
  // );
  // await tx.wait();
  // console.log('setInitLandPrice done');

  tx = await blueprint.connect(blueprintAcc).setTierToCoefRate(
    ['1', '2', '3', '4', '5'],
    ['10000', '14000', '15500', '16000', '17000']
  );
  await tx.wait();
  console.log('setTierToCoefRate done');
  let productMapping = {
    'apple': {
      kind: 'plant',
      id: '1'
    },
    'orange': {
      kind: 'plant',
      id: '2'
    },
    'pumpkin': {
      kind: 'plant',
      id: '3'
    },
    'milk': {
      kind: 'animal',
      id: '1'
    },
    'egg': {
      kind: 'animal',
      id: '2'
    }
  }
  let orderByTier = _.groupBy(orderList.map(order => {
    let requirements = [];
    let keys = Object.keys(order);
    for (let key of keys) {
      if (order[key] > 0 && productMapping[key]) {
        if (productMapping[key].kind == 'plant') {
          requirements.push({
            quantity: order[key].toString(),
            seedId: productMapping[key].id,
            animalKindId: '0',
          })
        } else {
          requirements.push({
            quantity: order[key].toString(),
            seedId: '0',
            animalKindId: productMapping[key].id,
          })
        }
      }
    }
    return {
      tier: order.tier,
      requirements: requirements
    };
  }), 'tier');
  for (let tier of Object.keys(orderByTier)) {
    let requirementList = [];
    for (let order of orderByTier[tier]) {
      requirementList.push({
        requirements: order.requirements
      });
    }
    tx = await blueprint.connect(blueprintAcc).setTierToRequirementList(
      tier,
      requirementList
    );
    await tx.wait();
    console.log(`setTierToRequirementList tier #${tier} done`);
  }

  let baseExp = 50;
  let expCoef = 1.15;
  let maxLevel = '100';
  let acc = baseExp;
  let levelToCummulativeExp = [baseExp];
  for (let i = 1; i < maxLevel; i++) {
    levelToCummulativeExp.push(
      acc + Math.floor(Number(baseExp) * (Math.pow(Number(expCoef), i + 1)))
    );
    acc = levelToCummulativeExp[i];
  }
  tx = await blueprint.connect(blueprintAcc).setUserProfileSetting(
    baseExp.toString(),// base exp
    Math.round(expCoef * 10000).toString(), // exp coef
    [
      '1', '21', '41', '61', '81' //level to tier - 1 -2 -3 - 4 - 5
    ],
    levelToCummulativeExp.map(exp => exp.toString())
  );
  await tx.wait();
  console.log('setUserProfileSetting done');

  tx = await blueprint.connect(blueprintAcc).setStoreSellRate(
    "6000" // 60%
  );
  await tx.wait();
  console.log('setStoreSellRate done');

  let rawUserTierToOrderTierRates = [
    [75, 25, 0, 0, 0],
    [55, 30, 15, 0, 0],
    [30, 40, 25, 5, 0],
    [18, 25, 36, 18, 3],
    [5, 10, 20, 40, 25]
  ];
  let userTierToOrderTierRates = []
  for (let orderTierRates of rawUserTierToOrderTierRates) {
    orderTierRates = orderTierRates.map(el => el * 100);
    orderTierRates.forEach((rate, i) => {
      if (orderTierRates[i - 1]) {
        orderTierRates[i] = orderTierRates[i] + orderTierRates[i - 1];
      }
    })
    userTierToOrderTierRates.push(orderTierRates)
  }

  tx = await blueprint.connect(blueprintAcc).setUserTierToOrderTierRates(
    userTierToOrderTierRates.map((rate, index) => index + 1),
    userTierToOrderTierRates
  );
  await tx.wait();
  console.log('setUserTierToOrderTierRates done');
  for(let landMap of landMaps){
    tx = await blueprint.connect(blueprintAcc).setLandMap(
      landMap.id.toString(),
      landMap.indexes.map(index => index.toString()),
      landMap.values.map(value => value.toString())
    );
    await tx.wait();
    console.log(`setLandMap ${landMap.id} done`);
  }

  // tx = await blueprint.connect(blueprintAcc).setCraftProducts(
  //   craftProducts.map(product => product.id),
  //   craftProducts.map(product => product.price),
  //   craftProducts.map(product => product.expReward),
  //   craftProducts.map(product => product.duration),
  //   craftProducts.map(product => product.craftType),
  //   craftProducts.map(product => {
  //     return product.requirements.map(requirement => {
  //       return {
  //         animalKindId: requirement.animalKindId ? requirement.animalKindId : '0',
  //         seedId: requirement.seedId ? requirement.seedId : '0',
  //         quantity: requirement.quantity
  //       }
  //     })
  //   })
  // );
  // await tx.wait();
  // console.log('setCraftProducts done');


  //Deploy nfts
  let {
    TxFarmLand,
    TxFarmCharacter
  } = await deployNfts(diamondAddress);

  tx = await blueprint.connect(blueprintAcc).setTxFarmLandContract(
    TxFarmLand
  );
  await tx.wait();
  console.log('setTxFarmLandContract done');

  tx = await blueprint.connect(blueprintAcc).setTxFarmCharacterContract(
    TxFarmCharacter
  );
  await tx.wait();
  console.log('setTxFarmCharacterContract done');

}
exports.setMainConfig = setMainConfig;