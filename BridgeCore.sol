// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./WrappedToken.sol";

contract BridgeCore is Ownable {
    using ECDSA for bytes32;

    address public validator;
    mapping(bytes32 => bool) public processedMessages;

    event Locked(address indexed user, uint256 amount, uint256 nonce);
    event Released(address indexed user, uint256 amount, uint256 nonce);

    constructor(address _validator) Ownable(msg.sender) {
        validator = _validator;
    }

    /**
     * @dev Locks tokens on the source chain.
     */
    function lock(address token, uint256 amount, uint256 nonce) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Locked(msg.sender, amount, nonce);
    }

    /**
     * @dev Releases tokens or mints wrapped ones based on a validator signature.
     */
    function claim(
        address user,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature,
        address targetToken,
        bool isMint
    ) external {
        bytes32 messageHash = keccak256(abi.encodePacked(user, amount, nonce));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);

        require(!processedMessages[ethSignedMessageHash], "Transfer already processed");
        require(ethSignedMessageHash.recover(signature) == validator, "Invalid signature");

        processedMessages[ethSignedMessageHash] = true;

        if (isMint) {
            WrappedToken(targetToken).mint(user, amount);
        } else {
            IERC20(targetToken).transfer(user, amount);
        }

        emit Released(user, amount, nonce);
    }

    function updateValidator(address _newValidator) external onlyOwner {
        validator = _newValidator;
    }
}
