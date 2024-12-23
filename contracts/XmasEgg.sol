// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract XmasEgg is ERC721A, Ownable {

    // config
    constructor(address initialOwner)
        ERC721A("Xmas Egg", "XMASEGG")
        Ownable(initialOwner) {
    }
    uint256 public MAX_SUPPLY = 3_344;
    uint256 public MAX_MINT_PER_WALLET = 1;
    uint256 public START_ID = 1;

    bool public mintEnabled = false;
    bool public wlRound = true;
    bytes32 public merkleRoot = 0xca8f564b11ab5f80efc9efb85e581ca1e2fe022f4f4a96fb2b9d5db46add70fd;
    string public baseURI = "https://boredtopia.github.io/xmas-eggs/xmas-egg.json";

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

    // toggle sale, round
    function toggleSale() external onlyOwner {
        mintEnabled = !mintEnabled;
    }
    function toggleRound() external onlyOwner {
        wlRound = !wlRound;
    }

    // merkle tree
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }
    function verifyAddress(bytes32[] calldata _merkleProof) private view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }

    // mint
    function mint(uint quantity, bytes32[] calldata _merkleProof) external {
        require(mintEnabled, "Sale is not enabled");
        if (wlRound) require(verifyAddress(_merkleProof), "Invalid Proof");
        require(_numberMinted(msg.sender) + quantity <= MAX_MINT_PER_WALLET, "Over wallet limit");
        
        _checkSupplyAndMint(msg.sender, quantity);
    }
    function adminMint(uint quantity) external onlyOwner {
        _checkSupplyAndMint(msg.sender, quantity);
    }
    function _checkSupplyAndMint(address to, uint256 quantity) private {
        require(_totalMinted() + quantity <= MAX_SUPPLY, "Over supply");

        _mint(to, quantity);
    }

    // aliases
    function numberMinted(address owner) external view returns (uint256) {
        return _numberMinted(owner);
    }
    function remainingSupply() external view returns (uint256) {
        return MAX_SUPPLY - _totalMinted();
    }

}
