// get fund from users
// withdraw
// set minimum value funding in usd

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";



contract FundMe {

    uint256 minimumUsd = 2 * 1e18;
    address[] funders;
    mapping(address => uint256) public addressToAmountFunded;
    mapping(address => bool) isFund;

    address public owner;
    AggregatorV3Interface internal dataFeed;

    /**
     * Network: Sepolia
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor() {
        owner = msg.sender;
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    

   

    function getFunders() public view returns (address[] memory) {
        return funders;
    }

    function getPrice() public view returns (uint256) {
        (
            ,
            /* uint80 roundID */
            int256 answer, /*uint startedAt*/
            ,
            ,

        ) = /*uint timeStamp*/
            /*uint80 answeredInRound*/
            dataFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() public view returns (uint256) {
        return dataFeed.version();
    }

     function fund() public payable {
        require(
            getConversionRate(msg.value) >= minimumUsd,
            "You need to send more value"
        );
        if (!isFund[msg.sender]) {
            funders.push(msg.sender);
            isFund[msg.sender] = true;
        }
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public {

        require(msg.sender == owner, "You are not the owner!");
        

        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            if(isFund[funder]){
                addressToAmountFunded[funder] = 0;
            }
        }
        // withdraw the fund
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "failed to withdraw your funds!");
    }
}
