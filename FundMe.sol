// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256; //This will prevent overflow issues with uint256 data type value storage
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    constructor() public{
        owner = msg.sender;
    }
    //address[] public funders;
  //  address public owner;
    
    
    function fund() public payable {
        //With minimumUSD we are putting a restriction on the minimum transaction value of 
        // $50
        uint256 minimumUSD = 50 * 10 ** 18; 
        //1gwei < $50
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        //What the ETH -> USD conversion rete
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender); //Push the current funder to the funder array.
    }
    
    function getVersion() public view returns (uint256){
        //Return the version of the pricefeed for given address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD0AAAb485DbEc71BaE70c4c5Ac7Ea18F5B0d00C2);
        return priceFeed.version();
    }
    
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD0AAAb485DbEc71BaE70c4c5Ac7Ea18F5B0d00C2);
        (,int256 answer,,,) = priceFeed.latestRoundData(); //Tuple definition
         return uint256(answer * 10000000000);
    }
    
    // 1000000000
    //Convert XX eth into USD
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice(); //Current value of  eth --> USD conversion
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000; //multiply value of 1 USD with the required ethAmount to get
        return ethAmountInUsd;
    }
    
    modifier onlyOwner {  //modifier is a keyword
        require (msg.sender == owner);
        _; //_; -> Before you run the function run this require statement first.
    }
    function withdraw() payable public onlyOwner {
        //payable function as it is going to return the ETH 
        ///require (msg.sender == owner); used in modifier
        msg.sender.transfer(address(this).balance);
        //this is a keyword --> contract you are currently in.
        //balance in contract in ETH 
        
        //Resetting is needed to reset all funders
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        
        funders = new address[](0);
    }
}
