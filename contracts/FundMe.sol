// SPDX-License-Identifier: MIT
// 1. pragma
pragma solidity ^0.8.8;

// 2. Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

// 3. Interfaces, Libraries, Contracts
error FundMe__Notowner();

/**@title A sample Funding Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */


contract FundMe {
    // Type Declarations
     uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
     
    // State variables
     address private /* immutable */ i_owner;
     address[] private s_funders;
     mapping(address => uint256) private s_addressToAmountFunded;
     using PriceConverter for uint256;
     AggregatorV3Interface public getPriceFeed;
    // Events (we have none!)

    // Modifiers
        modifier onlyowner {
        // require(msg.sender == i_owner);
        if (msg.sender != i_owner) revert FundMe__Notowner();
        _;
    }

    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure 

    
        constructor(address getPriceFeedAddress) {
        i_owner = msg.sender;
        getPriceFeed = AggregatorV3Interface(getPriceFeedAddress);
    }
     receive() external payable {
        fund();
    }
     fallback() external payable {
        fund();
    }


    function fund() public payable {
        require(msg.value.getConversionRate( getPriceFeed ) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        // ETH/USD price feed address of Sepolia Network.
        //Aggregato/rV3Interface getPriceFeed = AggregatorV3Interface//(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return getPriceFeed.version();
    }
    
 
    function withdraw() public onlyowner {
        for (uint256 funderIndex=0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw()  public payable onlyowner{
        address[] memory funders = s_funders;
        //Mappings cannot be memory. 
         for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success,) = i_owner.call{value: address(this).balance}("") ;
        require (success);
        }


        function getOwner() public view returns (address) {
            return i_owner;

        } 

        function getFunder(uint256 index) public view returns (address){
            return s_funders[index];
        }
        
        function getAddressToAmountFunded (address funder) public view returns (uint256){
             return s_addressToAmountFunded[funder];
        }

        function getPriceFeedContract() public view returns (AggregatorV3Interface){
            return getPriceFeed;
        }

            }
            
            
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()


   


