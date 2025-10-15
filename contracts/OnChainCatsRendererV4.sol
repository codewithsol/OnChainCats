// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64}  from "@openzeppelin/contracts/utils/Base64.sol";
import {IOnChainCatsRenderer} from "./IOnChainCatsRenderer.sol";

interface IOnChainCatsPoses {
    struct PoseData {
        bytes svgData;
        uint256 hx;
        uint256 hy;
    }
    function renderPose(uint256 poseIdx, string memory fur, string memory eyes, uint256 patIdx, uint256 expression, uint256 eyeType) external pure returns (PoseData memory);
    function addLynxEars(bytes memory o, uint256 hx, uint256 hy) external pure returns (bytes memory);
    function drawEyes(bytes memory o, uint256 hx, uint256 hy, string memory eyes, uint256 eyeType) external pure returns (bytes memory);
}

interface IOnChainCatsPatterns {
    function applyPattern(bytes memory o, uint256 patIdx, uint256 bx, uint256 by, uint256 bw, uint256 bh, uint256 s) external pure returns (bytes memory);
}

interface IOnChainCatsAccessories {
    function applyAccessories(bytes memory o, uint256 accIdx, uint256 hx, uint256 hy) external pure returns (bytes memory);
}

interface IOnChainCatsBackgrounds {
    function renderBackground(uint256 bgType, uint256 seed) external pure returns (bytes memory);
    function getBackgroundName(uint256 bgType) external pure returns (string memory);
}

contract OnChainCatsRendererV4 is IOnChainCatsRenderer {
    using Strings for uint256;

    IOnChainCatsPoses public posesContract;
    IOnChainCatsPatterns public patternsContract;
    IOnChainCatsAccessories public accessoriesContract;
    IOnChainCatsBackgrounds public backgroundsContract;

    constructor(address _poses, address _patterns, address _accessories, address _backgrounds) {
        posesContract = IOnChainCatsPoses(_poses);
        patternsContract = IOnChainCatsPatterns(_patterns);
        accessoriesContract = IOnChainCatsAccessories(_accessories);
        backgroundsContract = IOnChainCatsBackgrounds(_backgrounds);
    }

    // --- RNG helpers ---
    function _rand(uint256 s, uint256 salt) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(s, salt)));
    }
    
    function _traitIndex(uint256 seed, uint256 salt, uint256 mod_) internal pure returns (uint256) {
        return _rand(seed, salt) % mod_;
    }

    // --- Palettes / dictionaries ---
    function _fur(uint256 idx) internal pure returns (string memory) {
        string[16] memory fur = [
            "222222","5C4033","A0522D","C19A6B","F4A460","EEDFCC","BFB8AA","888888",
            "F0EAD6","1F3A93","F7D358","8C5A2B","4A2C2A","7F8C8D","2E4053","D4AF37"
        ];
        return fur[idx];
    }
    
    function _eyes(uint256 idx) internal pure returns (string memory) {
        string[10] memory eyes = [
            "2C3E50","2980B9","16A085","8E44AD","E67E22",
            "27AE60","E74C3C","95A5A6","00BCD4","F1C40F"
        ];
        return eyes[idx];
    }
    
    function _patternName(uint256 idx) internal pure returns (string memory) {
        string[10] memory pattern = [
            "none","tabby","tiger","siamese","spotted",
            "calico","tuxedo","tortie","marble","lynx"
        ];
        return pattern[idx];
    }
    
    function _accName(uint256 idx) internal pure returns (string memory) {
        string[21] memory acc = [
            "none","collar","bow","earring","monocle","cigar","cap",
            "laser","sunglasses","scarf","bell","cigarette","crown",
            "top hat","bandana","chain","headphones","eye patch",
            "halo","party hat","flowers"
        ];
        return acc[idx];
    }
    
    function _poseName(uint256 idx) internal pure returns (string memory) {
        string[5] memory pose = ["sit","loaf","walk","stretch","pounce"];
        return pose[idx];
    }
    
    function _expressionName(uint256 idx) internal pure returns (string memory) {
        string[8] memory expr = ["frown","smile","neutral","tongue","big smile","smirk","surprised","fangs"];
        return expr[idx];
    }
    
    function _eyeTypeName(uint256 idx) internal pure returns (string memory) {
        string[8] memory eyeTypes = ["cute","wide kawaii","sleepy","wink","happy closed","heterochromia","narrow","heart"];
        return eyeTypes[idx];
    }

    // --- Attributes JSON ---
    function attributesJSON(uint256 tokenId, uint256 s) public view override returns (string memory) {
        uint256 furIdx  = _traitIndex(s, 1, 16);
        uint256 eyesIdx = _traitIndex(s, 2, 10);
        uint256 patIdx  = _traitIndex(s, 3, 10);
        uint256 accIdx  = _traitIndex(s, 4, 21);
        uint256 poseIdx = _traitIndex(s, 5, 5);
        uint256 faceIdx = _traitIndex(s, 6, 2);
        uint256 bgIdx   = _traitIndex(s, 7, 20);
        uint256 exprIdx = _traitIndex(s, 8, 8);
        
        // Eye type with weighted rarity (heterochromia and heart eyes are rarer)
        uint256 eyeTypeRaw = _traitIndex(s, 9, 100);
        uint256 eyeTypeIdx;
        if (eyeTypeRaw < 20) {
            eyeTypeIdx = 0; // cute - 20%
        } else if (eyeTypeRaw < 38) {
            eyeTypeIdx = 1; // wide kawaii - 18%
        } else if (eyeTypeRaw < 55) {
            eyeTypeIdx = 2; // sleepy - 17%
        } else if (eyeTypeRaw < 70) {
            eyeTypeIdx = 3; // wink - 15%
        } else if (eyeTypeRaw < 84) {
            eyeTypeIdx = 4; // happy closed - 14%
        } else if (eyeTypeRaw < 92) {
            eyeTypeIdx = 5; // heterochromia - 8% (RARE!)
        } else if (eyeTypeRaw < 97) {
            eyeTypeIdx = 6; // narrow - 5%
        } else {
            eyeTypeIdx = 7; // heart eyes - 3% (SUPER RARE!)
        }

        return string(
            abi.encodePacked(
                '[',
                    '{"trait_type":"Fur","value":"#', _fur(furIdx), '"},',
                    '{"trait_type":"Eye Color","value":"#', _eyes(eyesIdx), '"},',
                    '{"trait_type":"Eye Type","value":"', _eyeTypeName(eyeTypeIdx), '"},',
                    '{"trait_type":"Pattern","value":"', _patternName(patIdx), '"},',
                    '{"trait_type":"Accessory","value":"', _accName(accIdx), '"},',
                    '{"trait_type":"Pose","value":"', _poseName(poseIdx), '"},',
                    '{"trait_type":"Expression","value":"', _expressionName(exprIdx), '"},',
                    '{"trait_type":"Facing","value":"', (faceIdx==0 ? "Right" : "Left"), '"},',
                    '{"trait_type":"Background","value":"', backgroundsContract.getBackgroundName(bgIdx), '"}',
                ']'
            )
        );
    }

    // Get pattern regions based on pose
    function _getPatternRegions(uint256 poseIdx) internal pure returns (uint256[2][2] memory) {
        uint256[2][2] memory regions;
        if (poseIdx == 0) {
            // Sit: head and body
            regions[0] = [uint256(10), uint256(6)]; // hx, hy for head
            regions[1] = [uint256(11), uint256(16)]; // body
        } else if (poseIdx == 1) {
            // Loaf
            regions[0] = [uint256(10), uint256(7)];
            regions[1] = [uint256(10), uint256(17)];
        } else if (poseIdx == 2) {
            // Walk
            regions[0] = [uint256(9), uint256(6)];
            regions[1] = [uint256(10), uint256(16)];
        } else if (poseIdx == 3) {
            // Stretch
            regions[0] = [uint256(21), uint256(13)];
            regions[1] = [uint256(7), uint256(18)];
        } else {
            // Pounce - 
            regions[0] = [uint256(8), uint256(8)];
            regions[1] = [uint256(9), uint256(18)];
        }
        return regions;
    }

    // --- SVG ---
    function image(uint256 /*tokenId*/, uint256 s) public view override returns (string memory) {
        uint256 furIdx  = _traitIndex(s, 1, 16);
        uint256 eyesIdx = _traitIndex(s, 2, 10);
        uint256 patIdx  = _traitIndex(s, 3, 10);
        uint256 accIdx  = _traitIndex(s, 4, 21);
        uint256 poseIdx = _traitIndex(s, 5, 5);
        uint256 faceIdx = _traitIndex(s, 6, 2);
        uint256 bgIdx   = _traitIndex(s, 7, 20);
        uint256 exprIdx = _traitIndex(s, 8, 8);
        
        // Eye type with weighted rarity (heterochromia and heart eyes are rarer)
        uint256 eyeTypeRaw = _traitIndex(s, 9, 100);
        uint256 eyeTypeIdx;
        if (eyeTypeRaw < 20) {
            eyeTypeIdx = 0; // cute - 20%
        } else if (eyeTypeRaw < 38) {
            eyeTypeIdx = 1; // wide kawaii - 18%
        } else if (eyeTypeRaw < 55) {
            eyeTypeIdx = 2; // sleepy - 17%
        } else if (eyeTypeRaw < 70) {
            eyeTypeIdx = 3; // wink - 15%
        } else if (eyeTypeRaw < 84) {
            eyeTypeIdx = 4; // happy closed - 14%
        } else if (eyeTypeRaw < 92) {
            eyeTypeIdx = 5; // heterochromia - 8% (RARE!)
        } else if (eyeTypeRaw < 97) {
            eyeTypeIdx = 6; // narrow - 5%
        } else {
            eyeTypeIdx = 7; // heart eyes - 3% (SUPER RARE!)
        }

        string memory fur  = _fur(furIdx);
        string memory eyes = _eyes(eyesIdx);

        bytes memory o = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" shape-rendering="crispEdges">'
        );
        
        // Render dynamic background
        o = abi.encodePacked(o, backgroundsContract.renderBackground(bgIdx, s));

        // facing group
        o = (faceIdx == 1)
            ? abi.encodePacked(o, '<g transform="scale(-1,1) translate(-32,0)">')
            : abi.encodePacked(o, '<g>');

        // Render pose with expression and eye type
        IOnChainCatsPoses.PoseData memory poseData = posesContract.renderPose(poseIdx, fur, eyes, patIdx, exprIdx, eyeTypeIdx);
        o = abi.encodePacked(o, poseData.svgData);

        // Apply patterns
        uint256[2][2] memory regions = _getPatternRegions(poseIdx);
        o = patternsContract.applyPattern(o, patIdx, regions[0][0], regions[0][1], 12, 10, s); // head region
        if (poseIdx == 0) {
            o = patternsContract.applyPattern(o, patIdx, 11, 16, 10, 7, s); // body for sit
        } else if (poseIdx == 1) {
            o = patternsContract.applyPattern(o, patIdx, 10, 17, 12, 5, s); // body for loaf
        } else if (poseIdx == 2) {
            o = patternsContract.applyPattern(o, patIdx, 10, 16, 12, 5, s); // body for walk
        } else if (poseIdx == 3) {
            o = patternsContract.applyPattern(o, patIdx, 7, 18, 14, 4, s); // body for stretch
        } else {
            o = patternsContract.applyPattern(o, patIdx, 9, 18, 11, 4, s); // body for pounce 
        }

        // Draw eyes AFTER patterns so they appear on top
        o = posesContract.drawEyes(o, poseData.hx, poseData.hy, eyes, eyeTypeIdx);

        // lynx ear tips
        if (patIdx == 9) {
            o = posesContract.addLynxEars(o, poseData.hx, poseData.hy);
        }

        // Apply accessories
        o = accessoriesContract.applyAccessories(o, accIdx, poseData.hx, poseData.hy);
        
        o = abi.encodePacked(o, "</g></svg>");
        return string(o);
    }

    // --- tokenURI ---
    function tokenURI(uint256 tokenId, uint256 s) external view override returns (string memory) {
        string memory name_ = string(abi.encodePacked("On Chain Cat #", tokenId.toString()));
        string memory desc  = "On Chain Cats (OCC): fully on-chain, generative cats for HyperEVM. Traits, image, and metadata are generated entirely on-chain.";
        string memory svg   = image(tokenId, s);
        string memory json  = string(
            abi.encodePacked(
                '{"name":"', name_,
                '","description":"', desc,
                '","attributes":', attributesJSON(tokenId, s),
                ',"image":"data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }
}
