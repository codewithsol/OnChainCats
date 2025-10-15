// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/**
 *  ██████╗ ███╗   ██╗     ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗     ██████╗ █████╗ ████████╗███████╗
 * ██╔═══██╗████╗  ██║    ██╔════╝██║  ██║██╔══██╗██║████╗  ██║    ██╔════╝██╔══██╗╚══██╔══╝██╔════╝
 * ██║   ██║██╔██╗ ██║    ██║     ███████║███████║██║██╔██╗ ██║    ██║     ███████║   ██║   ███████╗
 * ██║   ██║██║╚██╗██║    ██║     ██╔══██║██╔══██║██║██║╚██╗██║    ██║     ██╔══██║   ██║   ╚════██║
 * ╚██████╔╝██║ ╚████║    ╚██████╗██║  ██║██║  ██║██║██║ ╚████║    ╚██████╗██║  ██║   ██║   ███████║
 *  ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝     ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
 *
 *  fully on‑chain, generative cats for HyperEVM 
 *
 *              CODE IS LAW, I AM CODE
 */
import {ERC721}  from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IOnChainCatsRenderer} from "./IOnChainCatsRenderer.sol";

contract OnChainCats is ERC721Enumerable, ERC2981, Ownable {
    using Strings for uint256;

    uint256 public immutable maxSupply;
    uint256 public immutable mintPrice; // in HYPE wei
    uint256 public totalMinted;
    address public payout;

    // Stored seed per tokenId
    mapping(uint256 => uint256) private _seeds;

    // Mint limit per wallet (0 = unlimited)
    uint256 public maxMintsPerWallet;
    mapping(address => uint256) public mintedByWallet;

    // Renderer
    IOnChainCatsRenderer public renderer;
    bool public rendererLocked;

    // --- Errors ---
    error SoldOut();
    error InsufficientPayment();
    error WithdrawFailed();
    error NotMinted();
    error BadRoyalty();
    error RendererNotSet();
    error RendererLocked();
    error MintLimitExceeded();

    // --- Events ---
    event Mint(address indexed minter, uint256 indexed tokenId, uint256 seed);
    event RendererUpdated(address indexed newRenderer);
    event RendererLockedEvent();
    event MaxMintsPerWalletUpdated(uint256 newLimit);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        uint256 mintPriceWei_,
        address initialOwner_,
        address payout_,
        uint96 royaltyBps, // e.g., 500 = 5%
        uint256 maxMintsPerWallet_
    ) ERC721(name_, symbol_) Ownable(initialOwner_) {
        require(maxSupply_ > 0, "maxSupply=0");
        require(royaltyBps <= 1000, "royalty too high"); // cap 10%

        maxSupply = maxSupply_;
        mintPrice = mintPriceWei_;
        payout = payout_;
        _setDefaultRoyalty(payout_, royaltyBps);
        maxMintsPerWallet = maxMintsPerWallet_;
    }

    // --- Admin ---
    function setRenderer(address r) external onlyOwner {
        if (rendererLocked) revert RendererLocked();
        renderer = IOnChainCatsRenderer(r);
        emit RendererUpdated(r);
    }

    function lockRenderer() external onlyOwner {
        rendererLocked = true;
        emit RendererLockedEvent();
    }

    function setPayout(address p) external onlyOwner {
        payout = p;
        (, uint256 currentBps) = royaltyInfo(1, 10_000);
        _setDefaultRoyalty(p, uint96(currentBps));
    }

    function setRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        if (feeNumerator > 1000) revert BadRoyalty();
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setMaxMintsPerWallet(uint256 limit) external onlyOwner {
        maxMintsPerWallet = limit;
        emit MaxMintsPerWalletUpdated(limit);
    }

    function withdraw() external {
        address to = payout == address(0) ? owner() : payout;
        (bool ok, ) = to.call{value: address(this).balance}("");
        if (!ok) revert WithdrawFailed();
    }

    // --- Mint ---
    function batchMint(address[] calldata recipients) external onlyOwner {
        uint256 length = recipients.length;
        unchecked {
            if (totalMinted + length > maxSupply) revert SoldOut();
        }
        
        for (uint256 i = 0; i < length; i++) {
            address recipient = recipients[i];
            uint256 tokenId = ++totalMinted;
            _safeMint(recipient, tokenId);

            // deterministic after mint
            uint256 seed = uint256(keccak256(abi.encodePacked(
                recipient,
                blockhash(block.number - 1),
                block.prevrandao,
                address(this),
                tokenId
            )));
            _seeds[tokenId] = seed;
            emit Mint(recipient, tokenId, seed);
        }
    }

    function mint(uint256 amount) external payable {
        unchecked {
            if (totalMinted + amount > maxSupply) revert SoldOut();
        }
        
        // Check per-wallet mint limit (0 = unlimited, owner bypasses limit)
        if (maxMintsPerWallet > 0 && msg.sender != owner()) {
            if (mintedByWallet[msg.sender] + amount > maxMintsPerWallet) {
                revert MintLimitExceeded();
            }
        }
        
        uint256 cost = mintPrice * amount;
        if (msg.value < cost) revert InsufficientPayment();
        
        // Track mints per wallet
        mintedByWallet[msg.sender] += amount;

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = ++totalMinted;
            _safeMint(msg.sender, tokenId);

            // deterministic after mint
            uint256 seed = uint256(keccak256(abi.encodePacked(
                msg.sender,
                blockhash(block.number - 1),
                block.prevrandao,
                address(this),
                tokenId
            )));
            _seeds[tokenId] = seed;
            emit Mint(msg.sender, tokenId, seed);
        }

        if (msg.value > cost) {
            (bool ok, ) = msg.sender.call{value: msg.value - cost}("");
            if (!ok) revert WithdrawFailed();
        }
    }

    // --- Views ---
    function seedOf(uint256 tokenId) public view returns (uint256) {
        if (_ownerOf(tokenId) == address(0)) revert NotMinted();
        return _seeds[tokenId];
    }

    function remainingMintsForWallet(address wallet) public view returns (uint256) {
        if (maxMintsPerWallet == 0) {
            return type(uint256).max; // unlimited
        }
        uint256 minted = mintedByWallet[wallet];
        if (minted >= maxMintsPerWallet) {
            return 0;
        }
        return maxMintsPerWallet - minted;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) revert NotMinted();
        if (address(renderer) == address(0)) revert RendererNotSet();
        return renderer.tokenURI(tokenId, _seeds[tokenId]);
    }

    // Optional passthrough for convenience/compat
    function attributesJSON(uint256 tokenId) external view returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) revert NotMinted();
        if (address(renderer) == address(0)) revert RendererNotSet();
        return renderer.attributesJSON(tokenId, _seeds[tokenId]);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
