pragma solidity ^0.8.0;

contract RestaurantMenu {
    struct MenuItem {
        string name;
        uint256 price;
        uint256 inventory;
    }
    
    mapping(uint256 => MenuItem) public menuItems;
    uint256 public numItems;
    
    mapping(address => mapping(uint256 => uint256)) public orders;
    
    constructor() {
        numItems = 0;
    }
    
    function addItem(string memory _name, uint256 _price, uint256 _inventory) public {
        menuItems[numItems] = MenuItem(_name, _price, _inventory);
        numItems++;
    }
    
    function placeOrder(uint256 _itemID, uint256 _quantity) public payable {
        require(_itemID < numItems, "Invalid item ID");
        require(_quantity <= menuItems[_itemID].inventory, "Not enough inventory");
        require(msg.value == menuItems[_itemID].price * _quantity, "Insufficient payment");
        
        orders[msg.sender][_itemID] += _quantity;
        menuItems[_itemID].inventory -= _quantity;
    }
    
    function cancelOrder(uint256 _itemID) public {
        require(orders[msg.sender][_itemID] > 0, "No order to cancel");
        
        uint256 refundAmount = orders[msg.sender][_itemID] * menuItems[_itemID].price;
        orders[msg.sender][_itemID] = 0;
        menuItems[_itemID].inventory += orders[msg.sender][_itemID];
        
        payable(msg.sender).transfer(refundAmount);
    }
    
    function getOrder(uint256 _itemID) public view returns (uint256) {
        require(_itemID < numItems, "Invalid item ID");
        return orders[msg.sender][_itemID];
    }
}