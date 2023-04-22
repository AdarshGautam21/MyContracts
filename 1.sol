pragma solidity ^0.8.0;

contract RestaurantMenu {
    struct MenuItem {
        string name;
        uint256 price;
    }
    
    mapping(uint256 => MenuItem) public menuItems;
    uint256 public numItems;
    
    constructor() {
        numItems = 0;
    }
    
    function addItem(string memory _name, uint256 _price) public {
        menuItems[numItems] = MenuItem(_name, _price);
        numItems++;
    }
    
    function getPrice(uint256 _itemID) public view returns (uint256) {
        require(_itemID < numItems, "Invalid item ID");
        return menuItems[_itemID].price;
    }
}