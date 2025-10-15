// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract OnChainCatsPosesContract {
    using Strings for uint256;

    struct PoseData {
        bytes svgData;
        uint256 hx;
        uint256 hy;
    }

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

    function _drawEyes(bytes memory o, uint256 hx, uint256 hy, string memory eyes, uint256 eyeType) private pure returns (bytes memory) {
        // Eye types with pupils and highlights for cuteness!
        if (eyeType == 0) {
            // Normal cute eyes with big pupils
            o = _rect(o, hx+2, hy+4, 3, 2, eyes);
            o = _rect(o, hx+7, hy+4, 3, 2, eyes);
            // Big round pupils
            o = _rect(o, hx+3, hy+4, 1, 2, "000000");
            o = _rect(o, hx+8, hy+4, 1, 2, "000000");
            // Tiny white highlights for sparkle
            o = _rect(o, hx+3, hy+4, 1, 1, "FFFFFF");
            o = _rect(o, hx+8, hy+4, 1, 1, "FFFFFF");
        } else if (eyeType == 1) {
            // Wide kawaii eyes
            o = _rect(o, hx+2, hy+4, 3, 3, eyes);
            o = _rect(o, hx+7, hy+4, 3, 3, eyes);
            // Large pupils
            o = _rect(o, hx+3, hy+5, 2, 1, "000000");
            o = _rect(o, hx+8, hy+5, 2, 1, "000000");
            // Sparkle highlights
            o = _rect(o, hx+2, hy+4, 1, 1, "FFFFFF");
            o = _rect(o, hx+7, hy+4, 1, 1, "FFFFFF");
        } else if (eyeType == 2) {
            // Sleepy/half-closed
            o = _rect(o, hx+2, hy+5, 3, 1, eyes);
            o = _rect(o, hx+7, hy+5, 3, 1, eyes);
            o = _rect(o, hx+3, hy+5, 1, 1, "000000");
            o = _rect(o, hx+8, hy+5, 1, 1, "000000");
        } else if (eyeType == 3) {
            // Wink (left eye closed, right eye open)
            o = _rect(o, hx+2, hy+5, 3, 1, "000000"); // closed eye line
            o = _rect(o, hx+7, hy+4, 3, 2, eyes); // open eye
            o = _rect(o, hx+8, hy+4, 1, 2, "000000"); // pupil
            o = _rect(o, hx+8, hy+4, 1, 1, "FFFFFF"); // highlight
        } else if (eyeType == 4) {
            // Happy closed eyes ^^
            o = _rect(o, hx+2, hy+5, 3, 1, "000000");
            o = _rect(o, hx+7, hy+5, 3, 1, "000000");
            o = _rect(o, hx+2, hy+4, 1, 1, "000000");
            o = _rect(o, hx+4, hy+4, 1, 1, "000000");
            o = _rect(o, hx+7, hy+4, 1, 1, "000000");
            o = _rect(o, hx+9, hy+4, 1, 1, "000000");
        } else if (eyeType == 5) {
            // Heterochromia (different colored eyes - RARE!)
            // Left eye - original color
            o = _rect(o, hx+2, hy+4, 3, 2, eyes);
            o = _rect(o, hx+3, hy+4, 1, 2, "000000"); // pupil
            o = _rect(o, hx+3, hy+4, 1, 1, "FFFFFF"); // highlight
            // Right eye - different color based on expression
            string memory altColor = uint256(keccak256(abi.encodePacked(eyeType))) % 2 == 0 ? "F1C40F" : "16A085";
            o = _rect(o, hx+7, hy+4, 3, 2, altColor);
            o = _rect(o, hx+8, hy+4, 1, 2, "000000"); // pupil
            o = _rect(o, hx+8, hy+4, 1, 1, "FFFFFF"); // highlight
        } else if (eyeType == 6) {
            // Narrow/sus eyes
            o = _rect(o, hx+2, hy+4, 3, 2, eyes);
            o = _rect(o, hx+7, hy+4, 3, 2, eyes);
            o = _rect(o, hx+2, hy+4, 3, 1, "000000");
            o = _rect(o, hx+7, hy+4, 3, 1, "000000");
        } else {
            // Heart eyes (rare and cute!)
            o = _rect(o, hx+2, hy+4, 3, 2, "FF69B4");
            o = _rect(o, hx+7, hy+4, 3, 2, "FF69B4");
            o = _rect(o, hx+3, hy+4, 1, 1, "FF1493");
            o = _rect(o, hx+4, hy+5, 1, 1, "FF1493");
            o = _rect(o, hx+8, hy+4, 1, 1, "FF1493");
            o = _rect(o, hx+9, hy+5, 1, 1, "FF1493");
        }
        return o;
    }

    function _drawHead(bytes memory o, uint256 hx, uint256 hy, string memory fur, string memory eyes, uint256 expression, uint256 eyeType) private pure returns (bytes memory) {
        // Main head rectangle
        o = _rect(o, hx, hy, 12, 10, fur);
        // Ears
        o = _rect(o, hx+1, hy-2, 2, 1, fur);
        o = _rect(o, hx+9, hy-2, 2, 1, fur);
        o = _rect(o, hx+1, hy-1, 3, 1, fur);
        o = _rect(o, hx+8, hy-1, 3, 1, fur);
        
        // Eyes are now drawn separately after patterns
        
        // Nose
        o = _rect(o, hx+5, hy+7, 2, 1, "000000");
        
        // Facial expressions (8 types for variety!)
        if (expression == 0) {
            // Frown (default)
            o = _rect(o, hx+4, hy+8, 1, 1, "000000");
            o = _rect(o, hx+7, hy+8, 1, 1, "000000");
        } else if (expression == 1) {
            // Smile :)
            o = _rect(o, hx+3, hy+8, 1, 1, "000000");
            o = _rect(o, hx+4, hy+9, 2, 1, "000000");
            o = _rect(o, hx+6, hy+9, 2, 1, "000000");
            o = _rect(o, hx+8, hy+8, 1, 1, "000000");
        } else if (expression == 2) {
            // Neutral :|
            o = _rect(o, hx+4, hy+8, 4, 1, "000000");
        } else if (expression == 3) {
            // Tongue out :P
            o = _rect(o, hx+4, hy+8, 1, 1, "000000");
            o = _rect(o, hx+7, hy+8, 1, 1, "000000");
            o = _rect(o, hx+5, hy+9, 2, 1, "FF69B4"); // Pink tongue
        } else if (expression == 4) {
            // Big smile :D
            o = _rect(o, hx+3, hy+8, 1, 1, "000000");
            o = _rect(o, hx+4, hy+9, 1, 1, "000000");
            o = _rect(o, hx+5, hy+9, 2, 1, "FF69B4");
            o = _rect(o, hx+7, hy+9, 1, 1, "000000");
            o = _rect(o, hx+8, hy+8, 1, 1, "000000");
        } else if (expression == 5) {
            // Smirk
            o = _rect(o, hx+4, hy+8, 1, 1, "000000");
            o = _rect(o, hx+5, hy+8, 2, 1, "000000");
            o = _rect(o, hx+7, hy+9, 1, 1, "000000");
        } else if (expression == 6) {
            // "O" face (surprised)
            o = _rect(o, hx+5, hy+8, 2, 1, "000000");
            o = _rect(o, hx+4, hy+9, 1, 1, "000000");
            o = _rect(o, hx+7, hy+9, 1, 1, "000000");
        } else {
            // Fangs (rare)
            o = _rect(o, hx+4, hy+8, 1, 1, "000000");
            o = _rect(o, hx+7, hy+8, 1, 1, "000000");
            o = _rect(o, hx+4, hy+9, 1, 1, "FFFFFF");
            o = _rect(o, hx+7, hy+9, 1, 1, "FFFFFF");
        }
        
        // Whiskers
        o = _rect(o, hx-2, hy+7, 3, 1, "AAAAAA");
        o = _rect(o, hx+11, hy+7, 3, 1, "AAAAAA");
        return o;
    }

    function renderPose(uint256 poseIdx, string memory fur, string memory eyes, uint256 patIdx, uint256 expression, uint256 eyeType) external pure returns (PoseData memory) {
        bytes memory o = "";
        uint256 hx;
        uint256 hy;

        if (poseIdx == 0) {
            // Sit - sitting upright with tail curled
            hx = 10; hy = 6;
            o = _drawHead(o, hx, hy, fur, eyes, expression, eyeType);
            // Body
            o = _rect(o, 11, 16, 10, 7, fur);
            // Front legs
            o = _rect(o, 11, 23, 3, 2, fur);
            o = _rect(o, 18, 23, 3, 2, fur);
            // Tail
            o = _rect(o, 22, 17, 2, 6, fur);
            o = _rect(o, 22, 16, 3, 1, fur);
            // Tuxedo pattern white chest
            if (patIdx == 6) { o = _rect(o, 13, 18, 6, 5, "FFFFFF"); }
        } else if (poseIdx == 1) {
            // Loaf - cat loafing with paws tucked
            hx = 10; hy = 7;
            o = _drawHead(o, hx, hy, fur, eyes, expression, eyeType);
            // Body (loaf shape)
            o = _rect(o, 10, 17, 12, 5, fur);
            // Tail
            o = _rect(o, 20, 22, 4, 1, fur);
            // Tuxedo pattern white chest
            if (patIdx == 6) { o = _rect(o, 12, 18, 8, 3, "FFFFFF"); }
        } else if (poseIdx == 2) {
            // Walk - walking with legs extended
            hx = 9; hy = 6;
            o = _drawHead(o, hx, hy, fur, eyes, expression, eyeType);
            // Body
            o = _rect(o, 10, 16, 12, 5, fur);
            // Walking legs (alternating positions)
            o = _rect(o, 12, 21, 2, 3, fur);
            o = _rect(o, 18, 21, 2, 3, fur);
            // Tail (raised while walking)
            o = _rect(o, 22, 15, 2, 5, fur);
            o = _rect(o, 23, 14, 2, 1, fur);
            // Tuxedo pattern white chest
            if (patIdx == 6) { o = _rect(o, 12, 17, 8, 3, "FFFFFF"); }
        } else if (poseIdx == 3) {
            // Stretch - stretching forward with front paws extended
            // Body (stretched horizontal)
            o = _rect(o, 7, 18, 14, 4, fur);
            // Front paws stretched forward
            o = _rect(o, 5, 20, 2, 2, fur);
            o = _rect(o, 3, 20, 2, 1, fur);
            // Head at the back
            hx = 21; hy = 13;
            o = _drawHead(o, hx, hy, fur, eyes, expression, eyeType);
            // Tuxedo pattern white chest
            if (patIdx == 6) { o = _rect(o, 9, 19, 8, 2, "FFFFFF"); }
        } else {
            // Pounce - improved ready-to-pounce position with lowered front
            hx = 8; hy = 8;
            o = _drawHead(o, hx, hy, fur, eyes, expression, eyeType);
            // Body (lower and more horizontal for pouncing)
            o = _rect(o, 9, 18, 11, 4, fur);
            // Front legs (crouched low)
            o = _rect(o, 10, 22, 2, 3, fur);
            o = _rect(o, 16, 22, 2, 3, fur);
            // Back legs (ready to spring)
            o = _rect(o, 19, 20, 2, 2, fur);
            // Tail (raised high and alert)
            o = _rect(o, 20, 14, 2, 6, fur);
            o = _rect(o, 21, 13, 2, 1, fur);
            // Tuxedo pattern white chest
            if (patIdx == 6) { o = _rect(o, 11, 19, 7, 3, "FFFFFF"); }
        }

        return PoseData(o, hx, hy);
    }

    function addLynxEars(bytes memory o, uint256 hx, uint256 hy) external pure returns (bytes memory) {
        // Add black ear tufts for lynx pattern
        o = _rect(o, hx+1,  hy-3, 1, 1, "000000");
        o = _rect(o, hx+10, hy-3, 1, 1, "000000");
        return o;
    }

    function drawEyes(bytes memory o, uint256 hx, uint256 hy, string memory eyes, uint256 eyeType) external pure returns (bytes memory) {
        return _drawEyes(o, hx, hy, eyes, eyeType);
    }
}