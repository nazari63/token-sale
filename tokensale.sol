// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSale {
    address public owner;
    IERC20 public token;
    uint256 public tokenPrice; // قیمت هر توکن به واحد اتریوم
    uint256 public tokensSold;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalPrice);

    constructor(address _token, uint256 _tokenPrice) {
        owner = msg.sender;
        token = IERC20(_token);
        tokenPrice = _tokenPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this");
        _;
    }

    // خرید توکن
    function buyTokens(uint256 numberOfTokens) public payable {
        require(numberOfTokens > 0, "Number of tokens must be greater than zero");
        uint256 totalPrice = numberOfTokens * tokenPrice;
        require(msg.value >= totalPrice, "Not enough Ether to purchase tokens");

        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance >= numberOfTokens, "Not enough tokens in the contract");

        // انتقال توکن‌ها به خریدار
        token.transfer(msg.sender, numberOfTokens);

        tokensSold += numberOfTokens;

        // ارسال اتریوم به صاحب قرارداد
        payable(owner).transfer(msg.value);

        emit TokensPurchased(msg.sender, numberOfTokens, totalPrice);
    }

    // تنظیم قیمت هر توکن (فقط برای مالک)
    function setTokenPrice(uint256 newPrice) public onlyOwner {
        tokenPrice = newPrice;
    }

    // مشاهده موجودی توکن‌های قرارداد
    function getContractTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // برداشت اتریوم از قرارداد (فقط برای مالک)
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}