// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFTMarketplace is ERC721URIStorage {

    constructor() ERC721("Metaverse Token", "METT") {
        owner = payable(msg.sender);
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.25 ether;
    address payable owner;

    mapping(uint256 => MarketItem) idToMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint128 price;
        bool sold;
    }

    event MarketItemCreated(
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint128 price,
        bool sold
    );

    function updateListingPrice(uint _listingPrice) public payable {
        require(msg.sender == owner, "Only owner can do this");
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createToken(string memory tokenURI, uint128 price) public payable returns (uint) {
        _tokenId.increment();
        uint256 newTokenId = _tokenId.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint128 price) private {
        require(price == listingPrice, "pay listing price");
        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            false
        );
        emit MarketItemCreated(tokenId, address(this), msg.sender, price, false);

        _transfer(msg.sender, address(this), tokenId);

        payable(owner).transfer(listingPrice);
    }

    function makeSale(uint256 tokenId) public payable{
        require(msg.value == idToMarketItem[tokenId].price , "pay price");
        address seller = idToMarketItem[tokenId].seller;
        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            idToMarketItem[tokenId].price,
            true
        );

        _transfer(address(this), msg.sender, tokenId);
        
        payable(seller).transfer(msg.value);
        _itemsSold.increment();
    }

    function resellMarketItem(uint256 tokenId,uint128 price) public payable {
        require(msg.sender == idToMarketItem[tokenId].owner, "you can't");
        require(msg.value == listingPrice);

        _transfer(msg.sender, address(this), tokenId);

        idToMarketItem[tokenId].owner = payable(address(this));
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].sold = false;

        _itemsSold.decrement();
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint unsoldItems = _tokenId.current() - _itemsSold.current();
        uint counter = 0;
        MarketItem[] memory  unsoldMarketItem = new MarketItem[](unsoldItems);
        for(uint i = 1 ; i <= _tokenId.current() ; i++){
            if(idToMarketItem[i].sold == false){
                MarketItem storage currentItem = idToMarketItem[i];
                unsoldMarketItem[counter] = currentItem;
                counter++;
            }
        }
        return unsoldMarketItem;
    }

    function fetchMyNFT() public view returns (MarketItem[] memory) {
        uint counter =0;
        MarketItem[] memory inventory;
        for(uint i=1; i<=_tokenId.current(); i++){
            if(idToMarketItem[i].owner == msg.sender){
                inventory[counter] = idToMarketItem[i];
                counter++;
            }
        }
        return inventory;
    }
    // function fetchMyListings{}

}