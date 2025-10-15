// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract OnChainCatsAccessoriesContract {
    using Strings for uint256;

    function _rect(bytes memory o, uint256 x, uint256 y, uint256 w, uint256 h, string memory fill) private pure returns (bytes memory) {
        return abi.encodePacked(
            o,
            '<rect x="', x.toString(),
            '" y="', y.toString(),
            '" width="', w.toString(),
            '" height="', h.toString(),
            '" fill="#', fill, '"/>'
        );
    }

    function _strokeRect(bytes memory o, uint256 x, uint256 y, uint256 w, uint256 h, string memory color, string memory sw) private pure returns (bytes memory) {
        return abi.encodePacked(
            o,
            '<rect x="', x.toString(),
            '" y="', y.toString(),
            '" width="', w.toString(),
            '" height="', h.toString(),
            '" fill="none" stroke="#', color, '" stroke-width="', sw, '"/>'
        );
    }

    function applyAccessories(bytes memory o, uint256 accIdx, uint256 hx, uint256 hy) external pure returns (bytes memory) {
        if (accIdx == 0) return o; // None
        
        if (accIdx == 1) {
            // Collar - red collar around neck
            o = _rect(o, hx,   hy+10, 12, 1, "E74C3C");
        } else if (accIdx == 2) {
            // Bow - cute purple bow tie
            o = _rect(o, hx+1, hy+10, 2, 2, "9B59B6");
            o = _rect(o, hx+9, hy+10, 2, 2, "9B59B6");
            o = _rect(o, hx+5, hy+10, 2, 2, "8E44AD");
        } else if (accIdx == 3) {
            // Earring - golden earring
            o = _rect(o, hx+1, hy-1, 1, 1, "F1C40F");
        } else if (accIdx == 4) {
            // Monocle - fancy golden monocle
            o = _strokeRect(o, hx+7, hy+4, 3, 2, "F1C40F", "0.5");
        } else if (accIdx == 5) {
            // Cigar - brown cigar with orange ember
            o = _rect(o, hx+8,  hy+8, 3, 1, "5C4033");
            o = _rect(o, hx+11, hy+8, 1, 1, "E67E22");
        } else if (accIdx == 6) {
            // Cap - dark blue baseball cap
            o = _rect(o, hx+1, hy-1, 10, 2, "2C3E50");
        } else if (accIdx == 7) {
            // Laser eyes - RED LASER BEAMS
            o = _rect(o, hx+5, hy+5, 14, 1, "FF0000");
            o = _rect(o, hx+2, hy+5, 14, 1, "FF0000");
        } else if (accIdx == 8) {
            // Sunglasses - cool dark shades
            o = _rect(o, hx+1, hy+4, 10, 2, "000000");
            o = _rect(o, hx+5, hy+4, 2, 1, "333333");
        } else if (accIdx == 9) {
            // Scarf - pink winter scarf
            o = _rect(o, hx-1, hy+10, 14, 2, "E91E63");
            o = _rect(o, hx+1, hy+12, 2, 3, "E91E63");
        } else if (accIdx == 10) {
            // Bell - golden bell on collar
            o = _rect(o, hx+5, hy+11, 2, 2, "F1C40F");
        } else if (accIdx == 11) {
            // Cigarette - white cigarette with smoke
            o = _rect(o, hx+9,  hy+8, 3, 1, "DDDDDD");
            o = _rect(o, hx+12, hy+8, 1, 1, "FF6F00");
            o = _rect(o, hx+13, hy+6, 1, 2, "FFFFFF80");
        } else if (accIdx == 12) {
            // Crown - golden royal crown
            o = _rect(o, hx+2, hy-2, 8, 2, "F1C40F");
            o = _rect(o, hx+3, hy-3, 1, 1, "FFD700");
            o = _rect(o, hx+5, hy-4, 2, 1, "FFD700");
            o = _rect(o, hx+8, hy-3, 1, 1, "FFD700");
        } else if (accIdx == 13) {
            // Top Hat - fancy black top hat
            o = _rect(o, hx+3, hy-5, 6, 1, "000000");
            o = _rect(o, hx+4, hy-4, 4, 3, "1A1A1A");
            o = _rect(o, hx+2, hy-1, 8, 1, "000000");
        } else if (accIdx == 14) {
            // Bandana - red pirate bandana
            o = _rect(o, hx+2, hy-1, 8, 2, "C0392B");
            o = _rect(o, hx+1, hy, 1, 1, "E74C3C");
        } else if (accIdx == 15) {
            // Chain - gold chain necklace
            o = _rect(o, hx+3, hy+10, 1, 1, "FFD700");
            o = _rect(o, hx+5, hy+11, 2, 1, "FFD700");
            o = _rect(o, hx+8, hy+10, 1, 1, "FFD700");
        } else if (accIdx == 16) {
            // Headphones - blue over-ear headphones
            o = _rect(o, hx, hy+2, 1, 4, "3498DB");
            o = _rect(o, hx+11, hy+2, 1, 4, "3498DB");
            o = _rect(o, hx+1, hy+1, 2, 1, "2E86C1");
            o = _rect(o, hx+9, hy+1, 2, 1, "2E86C1");
        } else if (accIdx == 17) {
            // Eye Patch - black pirate eye patch
            o = _rect(o, hx+1, hy+4, 4, 2, "000000");
            o = _rect(o, hx, hy+5, 1, 1, "333333");
            o = _rect(o, hx+5, hy+5, 7, 1, "333333");
        } else if (accIdx == 18) {
            // Halo - glowing golden halo
            o = _strokeRect(o, hx+3, hy-4, 6, 2, "FFD700", "0.8");
            o = _rect(o, hx+4, hy-4, 1, 1, "FFED4E");
            o = _rect(o, hx+7, hy-4, 1, 1, "FFED4E");
        } else if (accIdx == 19) {
            // Party Hat - colorful party hat
            o = _rect(o, hx+5, hy-4, 2, 1, "E74C3C");
            o = _rect(o, hx+4, hy-3, 4, 1, "F39C12");
            o = _rect(o, hx+3, hy-2, 6, 1, "3498DB");
            o = _rect(o, hx+2, hy-1, 8, 1, "9B59B6");
        } else if (accIdx == 20) {
            // Flowers - pink flower crown
            o = _rect(o, hx+2, hy-1, 2, 2, "FF69B4");
            o = _rect(o, hx+5, hy-2, 2, 2, "FF1493");
            o = _rect(o, hx+8, hy-1, 2, 2, "FF69B4");
        }
        return o;
    }
}
