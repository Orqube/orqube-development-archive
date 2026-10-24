// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOrbsToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @notice Fixed APR, prefunded ORBS staking. Draft: not audited or deployed.
/// @dev Only conventional non-rebasing, no-transfer-fee ERC20/KIP7 tokens are supported.
contract OrqubeStaking {
    IOrbsToken public immutable token;
    address public owner;
    address public pendingOwner;
    bool public depositsPaused;
    uint256 public totalPrincipal;
    uint256 public reservedRewards;
    uint256 private entered;
    struct Deposit {
        uint256 amount;
        uint256 reward;
        uint256 startedAt;
        uint256 unlockAt;
        uint16 aprBps;
        uint8 months;
        bool withdrawn;
    }
    mapping(address => Deposit[]) private deposits;
    event Staked(address indexed user, uint256 indexed id, uint256 amount, uint256 reward, uint256 unlockAt, uint8 months);
    event Withdrawn(address indexed user, uint256 indexed id, uint256 principal, uint256 reward);
    event RewardsFunded(address indexed funder, uint256 amount);
    event PauseChanged(bool paused);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() { require(msg.sender == owner, "OWNER_ONLY"); _; }
    modifier nonReentrant() { require(entered == 0, "REENTRANCY"); entered = 1; _; entered = 0; }

    constructor(address tokenAddress, address initialOwner) {
        require(tokenAddress.code.length > 0, "TOKEN_REQUIRED");
        require(initialOwner != address(0), "OWNER_REQUIRED");
        token = IOrbsToken(tokenAddress);
        owner = initialOwner;
    }

    function aprBps(uint8 months) public pure returns (uint16) {
        if (months == 3) return 400;
        if (months == 6) return 600;
        if (months == 9) return 700;
        if (months == 12) return 800;
        revert("INVALID_TERM");
    }
    function availableRewards() public view returns (uint256) {
        uint256 balance = token.balanceOf(address(this));
        uint256 liabilities = totalPrincipal + reservedRewards;
        return balance > liabilities ? balance - liabilities : 0;
    }
    function fundRewards(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "ZERO_AMOUNT");
        _receiveExact(msg.sender, amount);
        emit RewardsFunded(msg.sender, amount);
    }
    function quote(uint256 amount, uint8 months, uint256 start)
        public pure returns (uint256 reward, uint256 unlockAt, uint16 rate)
    {
        require(amount > 0, "ZERO_AMOUNT");
        rate = aprBps(months);
        unlockAt = addCalendarMonths(start, months);
        reward = amount * uint256(rate) * (unlockAt - start) / (10000 * 365 days);
    }
    function stake(uint256 amount, uint8 months) external nonReentrant {
        require(!depositsPaused, "DEPOSITS_PAUSED");
        (uint256 reward, uint256 unlockAt, uint16 rate) = quote(amount, months, block.timestamp);
        require(reward > 0, "AMOUNT_TOO_SMALL");
        require(availableRewards() >= reward, "REWARDS_NOT_FUNDED");
        _receiveExact(msg.sender, amount);
        uint256 id = deposits[msg.sender].length;
        totalPrincipal += amount;
        reservedRewards += reward;
        deposits[msg.sender].push(Deposit(amount, reward, block.timestamp, unlockAt, rate, months, false));
        emit Staked(msg.sender, id, amount, reward, unlockAt, months);
    }
    function withdraw(uint256 id) external nonReentrant {
        Deposit storage d = deposits[msg.sender][id];
        require(!d.withdrawn, "ALREADY_WITHDRAWN");
        require(block.timestamp >= d.unlockAt, "LOCKED");
        d.withdrawn = true;
        totalPrincipal -= d.amount;
        reservedRewards -= d.reward;
        uint256 payout = d.amount + d.reward;
        uint256 beforeUser = token.balanceOf(msg.sender);
        uint256 beforePool = token.balanceOf(address(this));
        _callToken(abi.encodeWithSelector(token.transfer.selector, msg.sender, payout));
        require(token.balanceOf(msg.sender) == beforeUser + payout, "UNSUPPORTED_TOKEN");
        require(token.balanceOf(address(this)) + payout == beforePool, "UNSUPPORTED_TOKEN");
        emit Withdrawn(msg.sender, id, d.amount, d.reward);
    }
    function depositCount(address user) external view returns (uint256) { return deposits[user].length; }
    function getDeposit(address user, uint256 id) external view returns (Deposit memory) { return deposits[user][id]; }
    function setDepositsPaused(bool value) external onlyOwner { depositsPaused = value; emit PauseChanged(value); }
    function proposeOwner(address next) external onlyOwner {
        require(next != address(0), "OWNER_REQUIRED"); pendingOwner = next;
    }
    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "PENDING_OWNER_ONLY");
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender; pendingOwner = address(0);
    }
    // No administrator withdrawal of principal or reward reserve, and no rate changes.
    function _receiveExact(address from, uint256 amount) private {
        uint256 beforeBalance = token.balanceOf(address(this));
        _callToken(abi.encodeWithSelector(token.transferFrom.selector, from, address(this), amount));
        require(token.balanceOf(address(this)) == beforeBalance + amount, "UNSUPPORTED_TOKEN");
    }
    function _callToken(bytes memory data) private {
        (bool ok, bytes memory result) = address(token).call(data);
        require(ok && (result.length == 0 || (result.length == 32 && abi.decode(result, (bool)))), "TOKEN_TRANSFER_FAILED");
    }
    function _leap(uint256 y) private pure returns (bool) { return y % 4 == 0 && (y % 100 != 0 || y % 400 == 0); }
    function _monthDays(uint256 y, uint256 m) private pure returns (uint256) {
        if (m == 2) return _leap(y) ? 29 : 28;
        if (m == 4 || m == 6 || m == 9 || m == 11) return 30;
        return 31;
    }
    /// @notice UTC calendar months, clamped to final day, preserving time of day.
    function addCalendarMonths(uint256 start, uint8 months) public pure returns (uint256) {
        aprBps(months);
        require(start <= 4102444800, "DATE_OUT_OF_RANGE"); // Through 2100-01-01.
        uint256 remaining = start / 1 days;
        uint256 y = 1970;
        while (remaining >= (_leap(y) ? 366 : 365)) { remaining -= _leap(y) ? 366 : 365; y++; }
        uint256 m = 1;
        while (remaining >= _monthDays(y, m)) { remaining -= _monthDays(y, m); m++; }
        uint256 day = remaining + 1;
        uint256 index = m - 1 + months;
        y += index / 12;
        m = index % 12 + 1;
        if (day > _monthDays(y, m)) day = _monthDays(y, m);
        uint256 daysSinceEpoch;
        for (uint256 year = 1970; year < y; year++) daysSinceEpoch += _leap(year) ? 366 : 365;
        for (uint256 month = 1; month < m; month++) daysSinceEpoch += _monthDays(y, month);
        return (daysSinceEpoch + day - 1) * 1 days + start % 1 days;
    }
}
