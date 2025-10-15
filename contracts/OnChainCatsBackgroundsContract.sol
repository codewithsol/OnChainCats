// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract OnChainCatsBackgroundsContract {
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

    function renderBackground(uint256 bgType, uint256 seed) external pure returns (bytes memory) {
        bytes memory o = "";

        if (bgType == 0) {
            // Solid: Soft Blue
            o = _rect(o, 0, 0, 32, 32, "a8dadc");
        } else if (bgType == 1) {
            // Solid: Mint Green
            o = _rect(o, 0, 0, 32, 32, "b8f2e6");
        } else if (bgType == 2) {
            // Solid: Lavender
            o = _rect(o, 0, 0, 32, 32, "d4a5a5");
        } else if (bgType == 3) {
            // Solid: Peach
            o = _rect(o, 0, 0, 32, 32, "ffb5a7");
        } else if (bgType == 4) {
            // Solid: Sky Blue
            o = _rect(o, 0, 0, 32, 32, "87ceeb");
        } else if (bgType == 5) {
            // Solid: Coral Pink
            o = _rect(o, 0, 0, 32, 32, "ff8fa3");
        } else if (bgType == 6) {
            // Solid: Light Purple
            o = _rect(o, 0, 0, 32, 32, "c8b6ff");
        } else if (bgType == 7) {
            // Solid: Warm Gray
            o = _rect(o, 0, 0, 32, 32, "b8b8aa");
        } else if (bgType == 8) {
            // Deep Space - dark with stars
            o = _rect(o, 0, 0, 32, 32, "0a0a1a");
            // Random stars
            for (uint256 i = 0; i < 15; i++) {
                uint256 sx = uint256(keccak256(abi.encodePacked(seed, i, uint256(1)))) % 32;
                uint256 sy = uint256(keccak256(abi.encodePacked(seed, i, uint256(2)))) % 32;
                uint256 brightness = uint256(keccak256(abi.encodePacked(seed, i, uint256(3)))) % 3;
                string memory color = brightness == 0 ? "FFFFFF" : (brightness == 1 ? "FFD700" : "87CEEB");
                o = _rect(o, sx, sy, 1, 1, color);
            }
        } else if (bgType == 9) {
            // Sunset Gradient
            o = _rect(o, 0, 0, 32, 8, "FF6B35");   // orange top
            o = _rect(o, 0, 8, 32, 8, "F7931E");   // orange-yellow
            o = _rect(o, 0, 16, 32, 8, "FDC830");  // yellow
            o = _rect(o, 0, 24, 32, 8, "FFE66D");  // light yellow bottom
        } else if (bgType == 10) {
            // Ocean/Beach
            o = _rect(o, 0, 0, 32, 20, "87CEEB");  // sky blue
            o = _rect(o, 0, 20, 32, 8, "1E90FF");  // ocean blue
            o = _rect(o, 0, 28, 32, 4, "4169E1");  // deep ocean
            // Sun
            o = _rect(o, 4, 4, 3, 3, "FFD700");
            // Clouds
            o = _rect(o, 10, 6, 2, 1, "FFFFFF");
            o = _rect(o, 9, 7, 4, 1, "FFFFFF");
            o = _rect(o, 24, 8, 2, 1, "FFFFFF");
            o = _rect(o, 23, 9, 4, 1, "FFFFFF");
        } else if (bgType == 11) {
            // Cyberpunk City (simplified)
            o = _rect(o, 0, 0, 32, 32, "1a0033");  // dark purple base
            // Buildings silhouette
            o = _rect(o, 2, 18, 4, 14, "000000");
            o = _rect(o, 8, 20, 3, 12, "000000");
            o = _rect(o, 13, 16, 5, 16, "000000");
            o = _rect(o, 20, 22, 4, 10, "000000");
            o = _rect(o, 26, 19, 4, 13, "000000");
            // Neon lights
            o = _rect(o, 3, 20, 1, 1, "FF00FF");
            o = _rect(o, 9, 22, 1, 1, "00FFFF");
            o = _rect(o, 15, 18, 1, 1, "FF00FF");
            o = _rect(o, 21, 24, 1, 1, "00FFFF");
        } else if (bgType == 12) {
            // Forest/Nature
            o = _rect(o, 0, 0, 32, 22, "87CEEB");  // sky
            o = _rect(o, 0, 22, 32, 10, "228B22"); // grass
            // Trees
            o = _rect(o, 3, 14, 2, 8, "8B4513");   // trunk
            o = _rect(o, 1, 10, 6, 6, "228B22");   // leaves
            o = _rect(o, 24, 16, 2, 6, "8B4513");  // trunk
            o = _rect(o, 22, 12, 6, 6, "228B22");  // leaves
            // Flowers
            o = _rect(o, 8, 26, 1, 1, "FF69B4");
            o = _rect(o, 12, 27, 1, 1, "FF1493");
            o = _rect(o, 18, 26, 1, 1, "FFD700");
        } else if (bgType == 13) {
            // Rainy Night
            o = _rect(o, 0, 0, 32, 32, "1a1a2e");  // dark blue-gray
            // Rain drops
            for (uint256 i = 0; i < 20; i++) {
                uint256 rx = uint256(keccak256(abi.encodePacked(seed, i, uint256(10)))) % 32;
                uint256 ry = uint256(keccak256(abi.encodePacked(seed, i, uint256(11)))) % 30;
                o = _rect(o, rx, ry, 1, 2, "6B7A8F88");
            }
            // Lightning (rare)
            if (seed % 10 == 0) {
                o = _rect(o, 15, 0, 2, 12, "FFFF00");
                o = _rect(o, 17, 8, 2, 8, "FFFF00");
            }
        } else if (bgType == 14) {
            // Matrix Code
            o = _rect(o, 0, 0, 32, 32, "000000");  // black
            // Green code streams
            for (uint256 i = 0; i < 8; i++) {
                uint256 cx = i * 4;
                uint256 cy = uint256(keccak256(abi.encodePacked(seed, i))) % 24;
                for (uint256 j = 0; j < 6; j++) {
                    string memory green = j == 0 ? "00FF00" : (j < 3 ? "00DD00" : "00AA00");
                    if (cy + j < 32) {
                        o = _rect(o, cx, cy + j, 1, 1, green);
                    }
                }
            }
        } else if (bgType == 15) {
            // Retro Vaporwave (simplified)
            o = _rect(o, 0, 0, 32, 10, "FF71CE");  // pink top
            o = _rect(o, 0, 10, 32, 11, "01CDFE"); // cyan middle
            o = _rect(o, 0, 21, 32, 11, "B967FF"); // purple bottom
            // Grid lines
            for (uint256 i = 21; i < 32; i += 3) {
                o = _rect(o, 0, i, 32, 1, "FF71CE88");
            }
            // Sun
            o = _rect(o, 14, 4, 4, 4, "FFD700");
        } else if (bgType == 16) {
            // Lava/Hell
            o = _rect(o, 0, 0, 32, 32, "1a0000");  // dark red base
            // Lava pools
            o = _rect(o, 2, 26, 8, 6, "FF4500");
            o = _rect(o, 22, 24, 8, 8, "FF4500");
            o = _rect(o, 10, 28, 6, 4, "FF6347");
            // Embers floating up
            for (uint256 i = 0; i < 12; i++) {
                uint256 ex = uint256(keccak256(abi.encodePacked(seed, i, uint256(20)))) % 32;
                uint256 ey = uint256(keccak256(abi.encodePacked(seed, i, uint256(21)))) % 28;
                o = _rect(o, ex, ey, 1, 1, "FFA500");
            }
        } else if (bgType == 17) {
            // Checkerboard Pattern
            for (uint256 y = 0; y < 32; y += 4) {
                for (uint256 x = 0; x < 32; x += 4) {
                    if ((x/4 + y/4) % 2 == 0) {
                        o = _rect(o, x, y, 4, 4, "e0e0e0");
                    } else {
                        o = _rect(o, x, y, 4, 4, "c0c0c0");
                    }
                }
            }
        } else if (bgType == 18) {
            // Bubblegum Pop
            o = _rect(o, 0, 0, 32, 32, "ffb7d5");  // pink base
            // Bubbles
            uint256 bubbles = 8;
            for (uint256 i = 0; i < bubbles; i++) {
                uint256 bx = uint256(keccak256(abi.encodePacked(seed, i, uint256(40)))) % 28;
                uint256 by = uint256(keccak256(abi.encodePacked(seed, i, uint256(41)))) % 28;
                uint256 size = (uint256(keccak256(abi.encodePacked(seed, i, uint256(42)))) % 2) + 2;
                o = _rect(o, bx, by, size, size, "ffffff88");
            }
        } else if (bgType == 19) {
            // Neon Lights
            o = _rect(o, 0, 0, 32, 32, "0d0221");  // dark purple
            // Horizontal neon stripes
            o = _rect(o, 0, 8, 32, 2, "ff006e");
            o = _rect(o, 0, 16, 32, 2, "8338ec");
            o = _rect(o, 0, 24, 32, 2, "3a86ff");
        } else {
            // Cosmic Rainbow (rare!)
            // Rainbow gradient
            o = _rect(o, 0, 0, 32, 5, "FF0000");   // red
            o = _rect(o, 0, 5, 32, 4, "FF7F00");   // orange
            o = _rect(o, 0, 9, 32, 5, "FFFF00");   // yellow
            o = _rect(o, 0, 14, 32, 5, "00FF00");  // green
            o = _rect(o, 0, 19, 32, 4, "0000FF");  // blue
            o = _rect(o, 0, 23, 32, 5, "4B0082");  // indigo
            o = _rect(o, 0, 28, 32, 4, "9400D3");  // violet
            // Sparkles
            for (uint256 i = 0; i < 10; i++) {
                uint256 spx = uint256(keccak256(abi.encodePacked(seed, i, uint256(30)))) % 32;
                uint256 spy = uint256(keccak256(abi.encodePacked(seed, i, uint256(31)))) % 32;
                o = _rect(o, spx, spy, 1, 1, "FFFFFF");
            }
        }

        return o;
    }
    
    function getBackgroundName(uint256 bgType) external pure returns (string memory) {
        string[20] memory names = [
            "Soft Blue",
            "Mint Green",
            "Lavender",
            "Peach",
            "Sky Blue",
            "Coral Pink",
            "Light Purple",
            "Warm Gray",
            "Deep Space",
            "Sunset",
            "Beach",
            "Cyberpunk City",
            "Forest",
            "Rainy Night",
            "Matrix Code",
            "Vaporwave",
            "Lava Hell",
            "Checkerboard",
            "Bubblegum Pop",
            "Neon Lights"
        ];
        return names[bgType];
    }
}
