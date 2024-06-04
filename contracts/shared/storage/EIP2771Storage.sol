// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct EIP2771Storage {
  mapping(address => bool) trustedForwarders;
}