/**
 *Submitted for verification at Etherscan.io on 2019-11-20
*/

pragma solidity ^0.4.26;

contract UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}





/// @title Kyber Network interface
interface KyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes hint) external payable returns(uint);
        
    function swapEtherToToken(ERC20 token, uint minRate) external payable returns (uint);
    
    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) external returns (uint);
    
  
}

interface OrFeedInterface {
  function getExchangeRate ( string fromSymbol, string toSymbol, string venue, uint256 amount ) external view returns ( uint256 );
  function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 );
  function getTokenAddress ( string symbol ) external view returns ( address );
  function getSynthBytes32 ( string symbol ) external view returns ( bytes32 );
  function getForexAddress ( string symbol ) external view returns ( address );
}





contract Trader{
    
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    KyberNetworkProxyInterface public proxy = KyberNetworkProxyInterface(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    OrFeedInterface orfeed= OrFeedInterface(0x3c1935Ebe06Ca18964A5B49B8Cd55A4A71081DE2);
    address daiAddress = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    bytes  PERM_HINT = "PERM";
    address owner;
    
      
      
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }
    
    
    constructor() public{
     owner = msg.sender;   
    }
    
   function swapEtherToToken (KyberNetworkProxyInterface _kyberNetworkProxy, ERC20 token, address destAddress) internal{

    uint minRate;
    (, minRate) = _kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, msg.value);

    //will send back tokens to this contract's address
    uint destAmount = _kyberNetworkProxy.swapEtherToToken.value(msg.value)(token, minRate);

    //send received tokens to destination address
   require(token.transfer(destAddress, destAmount));
   
   
   
    }
    
    function swapTokenToEther1 (KyberNetworkProxyInterface _kyberNetworkProxy, ERC20 token, uint tokenQty, address destAddress) internal returns (uint) {

        uint minRate =1;
        //(, minRate) = _kyberNetworkProxy.getExpectedRate(token, ETH_TOKEN_ADDRESS, tokenQty);

        // Check that the token transferFrom has succeeded
      

        // Approve tokens so network can take them during the swap
       token.approve(address(proxy), tokenQty);
      

       uint destAmount = proxy.tradeWithHint(ERC20(daiAddress), tokenQty, ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee), this, 8000000000000000000000000000000000000000000000000000000000000000, 0, 0x0000000000000000000000000000000000000004, PERM_HINT);

    return destAmount;
      //uint destAmount = proxy.swapTokenToEther(token, tokenQty, minRate);

        // Send received ethers to destination address
     //  destAddress.transfer(destAmount);
    }

     function kyberToUniSwapArb(address fromAddress, address uniSwapContract, uint theAmount) public payable onlyOwner returns (bool){

        address theAddress = uniSwapContract;
        UniswapExchangeInterface usi = UniswapExchangeInterface(theAddress);
        
        ERC20 address1 = ERC20(fromAddress);

       uint ethBack = swapTokenToEther1(proxy, address1 , theAmount, msg.sender);
       
       usi.ethToTokenSwapInput.value(ethBack)(1, block.timestamp);
     
        return true;
    }


    function () external payable  {
     
    }
    
    
    
    function withdrawETHAndTokens() public onlyOwner{
        
        msg.sender.transfer(address(this).balance);
         ERC20 daiToken = ERC20(daiAddress);
        uint256 currentTokenBalance = daiToken.balanceOf(this);
        daiToken.transfer(msg.sender, currentTokenBalance);
        
    }
    
    
    
    function getKyberSellPrice() public constant returns (uint256){
       uint256 currentPrice =  orfeed.getExchangeRate("ETH", "SAI", "SELL-KYBER-EXCHANGE", 1000000000000000000);
        return currentPrice;
    }
    
    
     function getUniswapBuyPrice() public constant returns (uint256){
       uint256 currentPrice =  orfeed.getExchangeRate("ETH", "SAI", "BUY-UNISWAP-EXCHANGE", 1000000000000000000);
        return currentPrice;
    }
    
    
    
    
    
}
