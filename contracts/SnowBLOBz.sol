// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SnowBLOBz is ERC721A, Ownable {

    IERC20 public token;
    uint256 public START_ID = 1;
    uint256 public MAX_MINT_PER_WALLET = 1;
    uint256 public mintPrice = 50_000 * 10**18; // 50K token
    string public baseURI = "https://boredtopia.github.io/xmas-eggs/snow-blobz.json";
    bool public mintEnabled = false;

    constructor(address initialOwner)
        ERC721A("Snow BLOBZ", "SNOWBLOBZ")
        Ownable(initialOwner) {
        token = IERC20(0x8a526CEa5F2d080D48b88D9e1947FADf16e30494); // BLZ
    }

    // start token id
    function _startTokenId() internal view virtual override returns (uint256) {
        return START_ID;
    }

    // metadata
    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return baseURI;
    }

    // token
    function setToken(address newToken) external onlyOwner {
        token = IERC20(newToken);
    }
    function setMintPrice(uint256 _newMintPrice) external onlyOwner {
        mintPrice = _newMintPrice;
    }
    function withdraw(uint256 amount) external onlyOwner {
        require(token.transfer(msg.sender, amount), "Transfer token failed");
    }

    // toggle sale
    function toggleSale() external onlyOwner {
        mintEnabled = !mintEnabled;
    }

    // mint
    function mint(uint quantity, bytes32[] calldata _merkleProof) external {
        require(mintEnabled, "Sale is not enabled");
        require(_numberMinted(msg.sender) + quantity <= MAX_MINT_PER_WALLET, "Over wallet limit");

        uint256 totalPrice = mintPrice * quantity;
        require(token.balanceOf(msg.sender) >= totalPrice, "Insufficient funds");
        require(token.transferFrom(msg.sender, address(this), totalPrice), "Payment failed");
        
        _mint(msg.sender, quantity);
    }
    function adminMint(uint quantity) external onlyOwner {
        _mint(msg.sender, quantity);
    }

    // aliases
    function numberMinted(address owner) external view returns (uint256) {
        return _numberMinted(owner);
    }
    function remainingSupply() external pure returns (uint256) {
        return 0;
    }

}
