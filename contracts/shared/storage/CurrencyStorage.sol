// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct CurrencyStorage {
  mapping(address => uint256) balances;
}