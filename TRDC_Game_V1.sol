// SPDX-License-Identifier: MIT


// TRDC Game

pragma solidity ^0.8.10;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface iBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface iBEP20Metadata is iBEP20 {
   
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract BEP20 is iBEP20, iBEP20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address"); 
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }
    
    
    
}

contract TRDCvalut is BEP20 {
    using SafeMath for uint256;
    address private _owner;

    event GetThief(string ThiefName, uint ThiefPower);
    event GetCop(string CopName, uint CopPower);
    event GetWeapon(string WeaponName, uint WeaponPower);
    event BuyWeapon(string WeaponName, uint WeaponPower);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WithdrawalBNB(uint256 _amount, address to);
    event WithdrawalToken(address _tokenAddr, uint256 _amount, address to);
    event bigHeist(string Bank, uint BankPower, string Thief, string Result, uint Amount);
    event totalThiefs (string _nameOfThief, uint _powerOfThief);
    event totalCops (string _nameOfCop, uint _powerOfCop);

    BEP20 public currency; //0x7e8DB69dcff9209E486a100e611B0af300c3374e; TRDC
    address public dEaD= 0x000000000000000000000000000000000000dEaD;
    uint256 fractions = 10** 18;
    uint256 public cardPrice = 10 * fractions;
    uint256 cardPower;
    uint256 bankPower;
    string  bThief;
    uint randomThief;
    uint randomCop;
    string  private bName;
    uint number = 4;
    uint numberBank = 30;
    uint constant MAX_UINT = 2**256 - 1;
    uint public vVault = 500;
    uint public percentageCut = 15;
    uint public _rate = 15;
    uint public _rate1 = 5;
    uint public _rate2 = 0;
    uint _give;
    
    uint rewardsToGive;
    uint groupRewards1;
    uint groupRewards2;
    
    struct CardThief{
        string tName;
        uint tPower;
    }
    struct CardCop{
        string cName;
        uint cPower;
    }
    struct Weapons{
        string wName;
        uint wPower;
    }
    struct Banks{
        string bankName;
    }
    struct addBigBank{
        string bigBankName;
        uint bigBankPower;
        uint valutAmount;
    }
    struct PlayerRewards{
        address TRDCplayer;
        uint rewardsAmount;
    }
    struct Round {
      uint roundTime;
   }

    
  mapping(address => bool) public player;
  mapping (address => uint[]) public thief;
  mapping(address => CardThief[]) public thiefCardsOwned;
  mapping(address => CardCop[]) public copCardOwned;
  mapping(address => Weapons[]) public weaponsOwned;
  mapping(uint => mapping(address => bool)) public groupMembers;

    CardThief[] public cardThief;
    CardCop[] public cardCop;
    Weapons[] public weapons;
    Banks[] public banks;
    PlayerRewards[] internal playerRewards;

  modifier isPlayer(address _player) {
    require(player[_player]);
    _;
  }
  modifier setPower(address _Player){
      givePower();
      //thief[_Player].push(cardPower);
     _; 
  }
  modifier isgroup(uint _group, address _player) {
    require(groupMembers[_group][_player]);
    _;
  }
  
    constructor () BEP20("testgame", "TeG") payable{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        currency = BEP20(0x80A535c0Bd75B190AADE698e5D9291ea2DCEc1C4);//should change to TRDC address used for testing
    }
  
    function owner() public view virtual returns (address) {
        return _owner;
    }
  
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function setPercentageCut(uint _percentageCut) internal onlyOwner{
        percentageCut = _percentageCut;
    }
    function vaultMinAmount(uint _vVault) external onlyOwner{
        vVault = _vVault;
    }
    function setCurrency (address Cryptocurrency, uint decimal) external onlyOwner {
        currency = BEP20(Cryptocurrency);
        fractions = 10** decimal;
    }
    function addBank (string memory _bankName) public onlyOwner{
        Banks memory newBanks = Banks({
            bankName: _bankName
        });
        banks.push(newBanks);
    }
    function editBank(uint bankIndex, string memory _bankName) public onlyOwner{
        banks[bankIndex].bankName = _bankName;
    }
    function deleteBank(uint bankIndex) public onlyOwner{
        banks[bankIndex] = banks[banks.length -1];
        banks.pop();
    }
    function addThief (string memory _tName, uint _tPower) public onlyOwner{
        CardThief memory newCardThief = CardThief({
            tName: _tName,
            tPower: _tPower
        });
        cardThief.push(newCardThief);
    }
    function editThief(uint thiefIndex, string memory _tName, uint _tPower) public onlyOwner{
        cardThief[thiefIndex].tName = _tName;
        cardThief[thiefIndex].tPower = _tPower;
    }
    function deleteThief(uint thiefIndex) public onlyOwner{
        cardThief[thiefIndex] = cardThief[cardThief.length -1];
        cardThief.pop();
    }
    function getThiefs() public returns (string memory nameOfThief, uint powerOfThief){
        require(cardThief.length !=0, "Thiefs are not yet created");
        for (uint i=0; i<cardThief.length; i++ ){
            nameOfThief = cardThief[i].tName;
            powerOfThief = cardThief[i].tPower;
            emit totalThiefs (nameOfThief, powerOfThief);
        }   
    }
    function addCop (string memory _cName, uint _cPower) public onlyOwner{
        CardCop memory newCardCop = CardCop({
            cName: _cName,
            cPower: _cPower
        });
        cardCop.push(newCardCop);
    }
    function editCop(uint copIndex, string memory _cName, uint _cPower) external onlyOwner{
        cardCop[copIndex].cName = _cName;
        cardCop[copIndex].cPower = _cPower;
    }
    function deleteCop(uint copIndex) public onlyOwner{
        cardCop[copIndex] = cardCop[cardCop.length -1];
        cardCop.pop();
    }
    function getCops() external returns (string memory nameOfCop, uint powerOfCop){
        require(cardCop.length !=0, "Cops are not yet created");
        for (uint i=0; i<cardCop.length; i++ ){
            nameOfCop = cardCop[i].cName;
            powerOfCop = cardCop[i].cPower;
            emit totalCops (nameOfCop, powerOfCop);
        }   
    }
    function addWeapon (string memory _wName, uint _wPower) external onlyOwner{
        Weapons memory newWeapons = Weapons({
            wName: _wName,
            wPower: _wPower
        });
        weapons.push(newWeapons);
    }
    function editWeapon(uint weaponIndex, string memory _wName, uint _wPower) external onlyOwner{
        weapons[weaponIndex].wName = _wName;
        weapons[weaponIndex].wPower = _wPower;
    }
    function deleteWeapon(uint weaponIndex) external onlyOwner{
        weapons[weaponIndex] = weapons[weapons.length -1];
        weapons.pop();
    }
    function buyThiefCard() internal returns (string memory nameOfThief, uint powerOfThief){
        require(cardThief.length !=0, "Thiefs are not yet created");
        randomThief = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % cardThief.length;
        emit GetThief(nameOfThief = cardThief[randomThief].tName, powerOfThief = cardThief[randomThief].tPower);
        thiefCardsOwned[msg.sender].push(CardThief(nameOfThief, powerOfThief));  
    }
    function buyCopCard() internal returns (string memory nameOfCop, uint powerOfCop){
        require(cardCop.length !=0, "Cops are not yet created");
        randomCop = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % cardCop.length;
        emit GetCop(nameOfCop = cardCop[randomCop].cName, powerOfCop = cardCop[randomCop].cPower); 
        copCardOwned[msg.sender].push(CardCop(nameOfCop, powerOfCop));   
    }
    function buyWeapon(uint weaponToBuy) external returns (string memory nameOfWeapon, uint powerOfWeapon){
        require(weapons.length !=0, "There are no Weapons yet");
        emit GetWeapon(nameOfWeapon = weapons[weaponToBuy].wName, powerOfWeapon = weapons[weaponToBuy].wPower); 
        weaponsOwned[msg.sender].push(Weapons(nameOfWeapon, powerOfWeapon));   
    }
    function deletePlayerThiefCard(uint cardsIndex) internal{
       thiefCardsOwned[msg.sender][cardsIndex] = thiefCardsOwned[msg.sender][thiefCardsOwned[msg.sender].length -1];
       thiefCardsOwned[msg.sender].pop();
    }
    function deletePlayerCopCard(uint cardsIndex) internal{
        copCardOwned[msg.sender][cardsIndex] = copCardOwned[msg.sender][copCardOwned[msg.sender].length -1];
        copCardOwned[msg.sender].pop();
    }
    function addReward (address _TRDCplayer, uint _rewardsAmount) internal{
        PlayerRewards memory newPlayerRewards = PlayerRewards({
            TRDCplayer: _TRDCplayer,
            rewardsAmount: _rewardsAmount
        });
        playerRewards.push(newPlayerRewards);
    }
    function updateReward(uint _updateAmount) internal{
        uint oldAmount;
        uint newAmount;
        for (uint i=0; i<playerRewards.length; i++){
            if (playerRewards[i].TRDCplayer == msg.sender){
                newAmount = _updateAmount;
                oldAmount = playerRewards[i].rewardsAmount;
                playerRewards[i].rewardsAmount = oldAmount + newAmount;
            } 
        }
    }
  function addToPlayersList(address _player) internal {
      require(player[_player] != true, "Address already exist");
    player[_player] = true;
  }

  function removeFromPlayersList(address _player) internal {
    player[_player] = false;
  }

  function setRwardRate(uint rate, uint rate1, uint rate2) external onlyOwner {
      _rate = rate;
      _rate1 = rate1;
      _rate2 = rate2;
  }
  function givePower() internal {
        cardPower = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
        if (cardPower == 0){
            cardPower = 1;
        }
    }
    function giveBankPower(uint bankIndex) internal {
        bankPower = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % numberBank;
        if (bankPower == 0){
            bankPower == 1;
        }
        bName = banks[bankIndex].bankName;

    }
    function changePrice(uint256 _cardPrice) external onlyOwner {
        cardPrice = _cardPrice * fractions;
    }
  function buyManyCards(uint amountOfCards) external {
      if (player[msg.sender] != true){
          addToPlayersList(msg.sender);
      }
      uint priceOfCards;
      priceOfCards = cardPrice.mul(amountOfCards);
      //currency.transferFrom(msg.sender, address(this), priceOfCards);//Trasfer from User to this contract TRDC token (price of game card)
      for (uint i=0; i<amountOfCards; i++){
          buyCard();
      }
  }  
  function buyCard() public setPower(msg.sender) returns (uint _cardPower){
      _mint(msg.sender, 1);
      if (cardPower == 1) {
         buyThiefCard();
      }
      if (cardPower == 2) {
         buyCopCard();
      }
      if (cardPower == 3) {
         _mint(msg.sender, 1);
         buyThiefCard();
         buyCopCard();
      }
      return (_cardPower = cardPower);
  }
  function resetBankPower(uint bankIndex) internal returns (string memory BankName, uint BankPower){
      giveBankPower(bankIndex);
      BankName = banks[bankIndex].bankName;
      BankPower = bankPower;
  }

  function approveOnBothSides()public {
      //first get approval from currency contract
      approve(msg.sender, MAX_UINT);//approval should be called at wallet connect
  }
  
  function startHeistThief (uint cardType, uint cardToUse, uint bankToHeist) public  returns (string memory heistResult){
      require(player[msg.sender], "Sorry you are not a player");
      uint _tPower;
      
      string memory _tName = thiefCardsOwned[msg.sender][cardToUse].tName;
      
      resetBankPower(bankToHeist);
      if (cardType== 1){
          _tPower = thiefCardsOwned[msg.sender][cardToUse].tPower;
          if (_tPower > bankPower){
              
              addReward(msg.sender, _rate);
              heistResult = "You Win, Please wait till the Heist end";
          }
          if (_tPower == bankPower){
                addReward(msg.sender, _rate1); 
                heistResult = "You Draw, Please wait till the Heist end"; 
              }
              if (_tPower < bankPower){
                  deletePlayerThiefCard(cardToUse);
                return("You Lost, try again");
              }
      }
      deletePlayerThiefCard(cardToUse);
      endHeist();
      emit bigHeist(bName, bankPower, _tName, heistResult, _give );
      return(heistResult);
  }
  function runCop(uint cardToUse) external returns(uint amountCollected, uint amountBurned, uint amountbackToRewards){
      require(player[msg.sender], "Sorry you are not a player");
      uint _cPower;
      uint _pVault;
      uint _toBurn;
      uint _toRewards;
      uint _toCop;
      uint moneyToSteal = playerRewards.length.sub(5);
      _cPower = copCardOwned[msg.sender][cardToUse].cPower;
          if (_cPower > moneyToSteal){
              for (uint i=0; i<playerRewards.length; i++){
                  _pVault = playerRewards[i].rewardsAmount;
                  if (_pVault > vVault ){
                      _toBurn = _pVault.sub(_pVault.mul(percentageCut).div(100));
                      _toRewards = _pVault.sub(_pVault.mul(percentageCut).div(100));
                      _toCop = _pVault.sub(_pVault.mul(percentageCut).div(100));
                      _pVault = _pVault.sub(_toBurn.add(_toRewards).add(_toCop));
                      playerRewards[i].rewardsAmount = _pVault;
                  }
              }
          }

  }
  function endHeist () internal {
      transferFrom(msg.sender, dEaD, 1);
      
      if  (balanceOf(msg.sender) == 0){
          removeFromPlayersList(msg.sender);
      } 
      //claimRewards(); 
  }
  function checkRewards() public {
      require(currency.balanceOf(address(this)) !=0 , "No rewards yet");
      rewardsToGive = currency.balanceOf(address(this));
      groupRewards1 = rewardsToGive.mul(60).div(100) * fractions;
      groupRewards2 = rewardsToGive.mul(30).div(100) * fractions;
  }
  function claimRewards () internal {
   
  }


  function withdrawalToken(address _tokenAddr, uint256 _amount, address to) external onlyOwner() {
        iBEP20 token = iBEP20(_tokenAddr);
        emit WithdrawalToken(_tokenAddr, _amount, to);
        token.transfer(to, _amount);
    }
    
    function withdrawalBNB(uint256 _amount, address to) external onlyOwner() {
        require(address(this).balance >= _amount);
        emit WithdrawalBNB(_amount, to);
        payable(to).transfer(_amount);
    }

    receive() external payable {}
}

//********************************************************
// Proudly Developed by MetaIdentity ltd. Copyright 2022
//********************************************************
