// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// Custom Errors for Gas Efficiency
error MaxAttemptsReached();
error AlreadyClaimed();
error NonExistentToken();

contract TreasureBadgeSelfContained_DataURI {
    
    // --- ERC-721 Metadata ---
    string public constant name = "Treasure Hunt 2025 Badge";
    string public constant symbol = "TH25";
    address public immutable owner; // Contract deployer
    uint256 private _nextTokenId;
    
    // Data URI (Base64) for the NFT Metadata. 
    // This removes the need for external hosting.
    // Metadata: {"name": "Treasure Hunt Badge", "description": "2025 is for you", "attributes": [{"trait_type": "Background", "value": "Yellow"}]}
    string private constant WINNER_BADGE_URI = "data:application/json;base64,eyJuYW1lIjogIlRyZWFzdXJlIEh1bnQgQmFkZ2UiLCAiZGVzY3JpcHRpb24iOiAiMjAyNSBpcyBmb3IgeW91IiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIkJhY2tncm91bmQiLCAidmFsdWUiOiAiWWVsbG93In1dfQ==";

    // --- ERC-721 Core Data Structures ---
    mapping(uint256 => address) private _owners;       
    mapping(address => uint256) private _balances;     
    mapping(uint256 => string) private _tokenURIs;     
    
    // --- Treasure Hunt Logic Data ---
    bytes32 private constant TREASURE_HASH = 0x2b3887d19114f85e4277b2184d0b1660d2b78f4a382f7e71936c5617a942b10a;
    
    uint256 private constant MAX_ATTEMPTS = 2;
    mapping(address => uint256) private guessCount;
    
    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event TreasureFound(address indexed winner, string correctGuess, uint256 tokenId);

    constructor() {
        owner = msg.sender;
    }

    // --- Minimal ERC-721 View Functions ---
    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address tokenOwner = _owners[_tokenId];
        if (tokenOwner == address(0)) revert NonExistentToken();
        return tokenOwner;
    }
    
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        if (_owners[_tokenId] == address(0)) revert NonExistentToken();
        return _tokenURIs[_tokenId];
    }
    
    // --- Internal Mint Function (Minimalist) ---
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) revert();
        if (_owners[tokenId] != address(0)) revert();
        
        _balances[to]++;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = WINNER_BADGE_URI;

        emit Transfer(address(0), to, tokenId);
    }

    // --- TREASURE HUNT MAIN FUNCTION ---
    function submitGuess(string memory userGuess) public {
        
        // 1. Check Attempt Limit 
        if (guessCount[msg.sender] >= MAX_ATTEMPTS) {
            revert MaxAttemptsReached();
        }

        // 2. Hashing and Verification
        bytes32 guessHash = keccak256(abi.encodePacked(userGuess));
        
        if (guessHash == TREASURE_HASH) {
            // SUCCESS CASE: Award NFT Badge
            
            if (_balances[msg.sender] > 0) {
                revert AlreadyClaimed();
            }
            
            guessCount[msg.sender] = MAX_ATTEMPTS; 
            
            // Mint the NFT - Metadata is built-in!
            uint256 tokenId = _nextTokenId++;
            _mint(msg.sender, tokenId);

            emit TreasureFound(msg.sender, userGuess, tokenId); 
            return;
        } 
        
        // 3. FAILED GUESS: Record Attempt
        guessCount[msg.sender]++;
    }
    
    function getRemainingAttempts(address user) public view returns (uint256) {
        if (guessCount[user] >= MAX_ATTEMPTS) {
            return 0;
        }
        return MAX_ATTEMPTS - guessCount[user];
    }
}
