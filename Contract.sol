// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GAME{

    address public deployer;
    constructor(string[] memory items,uint256[] memory price,uint16 len){
        deployer = msg.sender;
        for (uint16 i=0; i<len; i++) {
            ItemPrice[items[i]]=price[i];
        }
    }
    receive() external payable {}
    function withdrawEther(uint256 amount) external {
        require(msg.sender == deployer, "Only the deployer can withdraw ether");
        require(address(this).balance >= amount, "Not enough balance in the contract");
        payable(deployer).transfer(amount);
    }

    struct Details {
        uint256 tokens;
        string[] items;
    }

    mapping(address => Details) internal DetailsMap;
    mapping(string => uint256) internal ItemPrice;

    uint24  buyPrice=100000;
    uint24 sellPrice=85000;

    modifier checkTokens(uint256 _tokens) {
        require(DetailsMap[msg.sender].tokens>=_tokens,"You dont have enough tokens.");
        _;
    }

    function buyTokens() payable external {
        DetailsMap[msg.sender].tokens += (msg.value * buyPrice) / 1 ether;
    }

    function sellTokens(uint256 _tokens) external checkTokens(_tokens) {
        uint256 etherAmount = (_tokens * 1 ether) / sellPrice;
        DetailsMap[msg.sender].tokens -= _tokens;
        payable(msg.sender).transfer(etherAmount);
    }

    function getTokens(address person) external view returns (uint256) {
        return DetailsMap[person].tokens;
    }

    function getItems(address person) external view returns (string[] memory) {
        return DetailsMap[person].items;
    }

    function transferTokens(address receiver, uint256 _tokens) external checkTokens(_tokens) {
        DetailsMap[msg.sender].tokens-=_tokens;
        DetailsMap[receiver].tokens+=_tokens;
    }

    function buyItem(string memory _item) external checkTokens(ItemPrice[_item]){
        require(ItemPrice[_item] > 0, "Item does not exist or has no price");
        DetailsMap[msg.sender].tokens-=ItemPrice[_item];
        DetailsMap[msg.sender].items.push(_item);
    }

    function sellItem(uint16 _i) external {
        require(_i < DetailsMap[msg.sender].items.length, "Invalid item index");
        string memory item = DetailsMap[msg.sender].items[_i];
        require(ItemPrice[item] > 0, "Item not found or has no price");
        DetailsMap[msg.sender].tokens += ItemPrice[item];
        DetailsMap[msg.sender].items[_i] = DetailsMap[msg.sender].items[DetailsMap[msg.sender].items.length - 1];
        DetailsMap[msg.sender].items.pop();
    }

    function transferItem(address receiver, uint16 itemIndex) external {
        require(itemIndex < DetailsMap[msg.sender].items.length, "Invalid item index");
        string memory item = DetailsMap[msg.sender].items[itemIndex];
        require(ItemPrice[item] > 0, "Invalid item");
        DetailsMap[msg.sender].items[itemIndex] = DetailsMap[msg.sender].items[DetailsMap[msg.sender].items.length - 1];
        DetailsMap[msg.sender].items.pop();
        DetailsMap[receiver].items.push(item);
    }
}