// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../src/OrqubeStaking.sol";
interface Vm {
    function warp(uint256 time) external;
    function prank(address user) external;
    function expectRevert(bytes calldata message) external;
}
contract MockToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    function mint(address to, uint256 amount) external { balanceOf[to] += amount; }
    function approve(address to, uint256 amount) external returns (bool) { allowance[msg.sender][to] = amount; return true; }
    function transfer(address to, uint256 amount) external returns (bool) { _move(msg.sender, to, amount); return true; }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "ALLOWANCE");
        allowance[from][msg.sender] -= amount; _move(from, to, amount); return true;
    }
    function _move(address from, address to, uint256 amount) private {
        require(balanceOf[from] >= amount, "BALANCE"); balanceOf[from] -= amount; balanceOf[to] += amount;
    }
}
contract OrqubeStakingTest {
    Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    MockToken token;
    OrqubeStaking pool;
    address constant user = address(0x1234);
    function setUp() public {
        vm.warp(1791590400); // 2026-10-10 UTC
        token = new MockToken(); pool = new OrqubeStaking(address(token), address(this));
        token.mint(address(this), 1000000 ether); token.mint(user, 10000 ether);
        token.approve(address(pool), 1000000 ether);
        vm.prank(user); token.approve(address(pool), 10000 ether);
    }
    function testAllRatesAndReserve() public {
        pool.fundRewards(1000 ether);
        uint8[4] memory terms = [uint8(3),6,9,12];
        uint16[4] memory rates = [uint16(400),600,700,800];
        uint256 rewards;
        for (uint256 i; i < 4; i++) {
            vm.prank(user); pool.stake(1000 ether, terms[i]);
            OrqubeStaking.Deposit memory d = pool.getDeposit(user, i);
            require(d.aprBps == rates[i], "RATE");
            require(d.reward == 1000 ether * rates[i] * (d.unlockAt-d.startedAt) / (10000*365 days), "FORMULA");
            rewards += d.reward;
        }
        require(pool.totalPrincipal() == 4000 ether, "PRINCIPAL");
        require(pool.reservedRewards() == rewards, "RESERVE");
        require(pool.availableRewards() == 1000 ether-rewards, "FREE_REWARDS");
    }
    function testRejectUnfundedAndInvalidTerm() public {
        vm.expectRevert(bytes("REWARDS_NOT_FUNDED")); vm.prank(user); pool.stake(1000 ether,3);
        vm.expectRevert(bytes("INVALID_TERM")); vm.prank(user); pool.stake(1000 ether,4);
    }
    function testLockedMaturityAndDoubleWithdraw() public {
        pool.fundRewards(1000 ether);
        vm.prank(user); pool.stake(1000 ether,12);
        OrqubeStaking.Deposit memory d = pool.getDeposit(user,0);
        vm.warp(d.unlockAt-1);
        vm.expectRevert(bytes("LOCKED")); vm.prank(user); pool.withdraw(0);
        vm.warp(d.unlockAt); vm.prank(user); pool.withdraw(0);
        require(token.balanceOf(user) == 10000 ether+d.reward, "PAYOUT");
        require(pool.totalPrincipal()==0 && pool.reservedRewards()==0, "LIABILITIES");
        vm.expectRevert(bytes("ALREADY_WITHDRAWN")); vm.prank(user); pool.withdraw(0);
    }
    function testPauseDoesNotBlockMatureWithdrawal() public {
        pool.fundRewards(1000 ether); vm.prank(user); pool.stake(1000 ether,3);
        pool.setDepositsPaused(true);
        vm.expectRevert(bytes("DEPOSITS_PAUSED")); vm.prank(user); pool.stake(1000 ether,3);
        vm.warp(pool.getDeposit(user,0).unlockAt); vm.prank(user); pool.withdraw(0);
    }
    function testOwnerPermissions() public {
        vm.expectRevert(bytes("OWNER_ONLY")); vm.prank(user); pool.setDepositsPaused(true);
        vm.expectRevert(bytes("OWNER_ONLY")); vm.prank(user); pool.fundRewards(1 ether);
    }
    function testCalendarMonthEndAndLeapYear() public view {
        require(pool.addCalendarMonths(1795996800,3)==1803772800, "NOV30_TO_FEB28");
        require(pool.addCalendarMonths(1827532800,3)==1835395200, "NOV30_TO_FEB29");
    }
}
