// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

library BitwiseUtils {
    function sliceNumber(uint256 _n, uint8 _nbits, uint8 _offset) internal pure returns (uint256) {
        unchecked {
            // mask is made by shifting left an offset number of times
            uint256 mask = uint256((1 << _nbits) - 1) << _offset;
            // AND n with mask, and trim to max of _nbits bits
            return (_n & mask) >> _offset;
        }
    }

    function combieNumber(uint256 _n, uint256 _v, uint256 _offset) internal pure returns (uint256) {
        return _n | (_v << _offset);
    }

    function clearAndCombieNumber(uint256 _n, uint256 _v, uint8 _nbits, uint8 _offset) internal pure returns (uint256) {
        unchecked {
            uint256 mask0 = uint256((1 << _nbits) - 1); 
            uint256 mask1 = mask0 << _offset;
            return _n & ~mask1 | ((_v & mask0) << _offset);
        }
    }
}