// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/// @notice Optional features are fixed at deployment; disabled features always revert.
contract OrqubeToken is ERC20, Ownable {
    bool public immutable mintable;
    bool public immutable burnable;
    bool public immutable pausable;
    uint256 public immutable cap;
    bool public paused;
    constructor(string memory n,string memory s,uint256 amount,bool m,bool b,bool p,uint256 maximum)
        ERC20(n,s) Ownable(msg.sender) {
        require(amount>0 && maximum>=amount,"Invalid supply");
        mintable=m;burnable=b;pausable=p;cap=maximum;
        _mint(msg.sender,amount);
    }
    function mint(address to,uint256 amount) external onlyOwner {
        require(mintable,"Mint disabled");require(amount<=cap-totalSupply(),"Cap exceeded");_mint(to,amount);
    }
    function burn(uint256 amount) external {require(burnable,"Burn disabled");_burn(msg.sender,amount);}
    function pause() external onlyOwner {require(pausable,"Pause disabled");paused=true;}
    function unpause() external onlyOwner {require(pausable,"Pause disabled");paused=false;}
    function _update(address from,address to,uint256 value) internal override {
        require(!paused,"Paused");super._update(from,to,value);
    }
}
