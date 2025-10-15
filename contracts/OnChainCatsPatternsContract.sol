// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract OnChainCatsPatternsContract {
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

    function applyPattern(bytes memory o, uint256 patIdx, uint256 bx, uint256 by, uint256 bw, uint256 bh, uint256 s) external pure returns (bytes memory) {
        if (patIdx == 0) return o;
        if (patIdx == 1) {
            // Tabby
            for (uint256 y = 0; y < bh; y += 3) {
                o = abi.encodePacked(o,'<rect x="',bx.toString(),'" y="',(by+y).toString(),'" width="',bw.toString(),'" height="1" fill="#00000022"/>');
            }
        } else if (patIdx == 2) {
            // Tiger
            for (uint256 y2 = 0; y2 < bh; y2 += 2) {
                o = abi.encodePacked(o,'<rect x="',bx.toString(),'" y="',(by+y2).toString(),'" width="',bw.toString(),'" height="1" fill="#00000044"/>');
            }
        } else if (patIdx == 3) {
            // Siamese - dark points that scale with body size
            // Calculate proportional size (roughly 60-70% of body)
            uint256 siameseW = (bw * 65) / 100;
            uint256 siameseH = (bh * 65) / 100;
            if (siameseW < 4) siameseW = bw > 4 ? 4 : bw - 1;
            if (siameseH < 2) siameseH = bh > 2 ? 2 : bh - 1;
            
            // Center the dark patch
            uint256 offsetX = (bw - siameseW) / 2;
            uint256 offsetY = (bh - siameseH) / 2;
            
            o = _rect(o, bx + offsetX, by + offsetY, siameseW, siameseH, "00000033");
        } else if (patIdx == 4) {
            // Spotted - random spots that fit within body
            uint256 spotSize = (bw >= 4 && bh >= 4) ? 2 : 1;
            uint256 numSpots = (bw * bh >= 50) ? 5 : ((bw * bh >= 30) ? 3 : 2);
            
            for (uint256 i = 0; i < numSpots; i++) {
                if (bw > spotSize && bh > spotSize) {
                    uint256 rx = bx + (uint256(keccak256(abi.encodePacked(s, i))) % (bw - spotSize));
                    uint256 ry = by + (uint256(keccak256(abi.encodePacked(s, i, uint256(1)))) % (bh - spotSize));
                    o = _rect(o, rx, ry, spotSize, spotSize, "00000033");
                }
            }
        } else if (patIdx == 5) {
            // Calico - multi-colored patches
            // Make sure patches fit within body
            uint256 patchW = bw / 3;
            uint256 patchH = bh / 3;
            if (patchW > 0 && patchH > 0) {
                // Top left patch (brown)
                o = _rect(o, bx, by, patchW, patchH, "A0522DAA");
                // Bottom right patch (sandy)
                if (bx + (bw * 2) / 3 + patchW <= bx + bw && by + patchH + patchH <= by + bh) {
                    o = _rect(o, bx + (bw * 2) / 3, by + patchH, patchW, patchH, "F4A460AA");
                }
            }
        } else if (patIdx == 6) {
            // Tuxedo (handled in pose rendering) - white belly/chest
            // Make sure it fits within the body height
            uint256 tuxedoHeight = bh > 3 ? 2 : (bh > 1 ? 1 : 0);
            if (tuxedoHeight > 0 && bh >= tuxedoHeight + 1) {
                o = _rect(o, bx, by + bh - tuxedoHeight - 1, bw, tuxedoHeight, "FFFFFF11");
            }
        } else if (patIdx == 7) {
            // Tortie - improved with patches of orange and brown
            // Create natural-looking tortoiseshell patches that scale with body size
            uint256 patchSize = (bw >= 6 && bh >= 6) ? 2 : 1;
            uint256 patchCount = (bw * bh >= 50) ? (4 + (uint256(keccak256(abi.encodePacked(s, uint256(100)))) % 3)) : 3;
            
            for (uint256 i2 = 0; i2 < patchCount; i2++) {
                if (bw > patchSize && bh > patchSize) {
                    uint256 px = bx + (uint256(keccak256(abi.encodePacked(s, i2))) % (bw - patchSize));
                    uint256 py = by + (uint256(keccak256(abi.encodePacked(s, i2, uint256(777)))) % (bh - patchSize));
                    // Alternating orange and dark brown patches
                    string memory color = (i2 % 2 == 0) ? "D2691E" : "8B4513";
                    // Main patch
                    o = _rect(o, px, py, patchSize, patchSize, color);
                    // Add some single pixels for texture if there's room
                    if (patchSize == 2 && px + 2 < bx + bw && py + 1 < by + bh) {
                        o = _rect(o, px + 2, py + 1, 1, 1, color);
                    }
                }
            }
        } else if (patIdx == 8) {
            // Marble
            for (uint256 x = 0; x < bw; x += 3) {
                o = abi.encodePacked(o,'<rect x="',(bx+x).toString(),'" y="',by.toString(),'" width="1" height="',bh.toString(),'" fill="#00000022"/>');
            }
        } else if (patIdx == 9) {
            // Lynx - belly patch that scales with body size
            uint256 bellyWidth = bw > 3 ? bw - 2 : bw;
            uint256 bellyHeight = bh > 3 ? bh - 2 : bh;
            uint256 bellyX = bx + 1;
            uint256 bellyY = by + (bh > 4 ? 2 : 1);
            o = _rect(o, bellyX, bellyY, bellyWidth, bellyHeight, "00000022");
        }
        return o;
    }
}
