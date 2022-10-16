// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter {
    // ----- START OF DO-NOT-EDIT ----- //
    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
    }

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
        address[] following;
        address[] followers;
        mapping(address => Message[]) conversations;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;

    uint256 public nextTweetId;
    uint256 public nextMessageId;
    // ----- END OF DO-NOT-EDIT ----- //

    // ----- START OF QUEST 1 ----- //
    function registerAccount(string memory _name) external {
        require(bytes(_name).length != 0, "Name cannot be an empty string");
        User storage theNewUser = users[msg.sender];
        theNewUser.wallet = msg.sender;
        theNewUser.name = _name;
        //users[msg.sender] = theNewUser;
    }

    function postTweet(string calldata _content) external accountExists(msg.sender) {     
        Tweet memory theNewTweet = Tweet(
            nextTweetId,
            msg.sender,
            _content,
            block.timestamp
        );
        tweets[nextTweetId] = theNewTweet;
        users[msg.sender].userTweets.push(nextTweetId);
        nextTweetId += 1;
    }

    function readTweets(address _user) view external returns(Tweet[] memory) {
        uint[] memory userTweetsIds = users[_user].userTweets;
        Tweet[] memory userTweets = new Tweet[](userTweetsIds.length);
        for(uint256 i = 0; i < userTweetsIds.length; i++) {
            userTweets[i] = tweets[userTweetsIds[i]];
        }
        return userTweets;

    }

    modifier accountExists(address _user) {
        _;
         string memory account = users[_user].name;
        require(bytes(account).length != 0, "This wallet does not belong to any account.");
    }

    // ----- END OF QUEST 1 ----- //

    // ----- START OF QUEST 2 ----- //
    function followUser(address _user) external {
        users[msg.sender].following.push(_user);
        users[_user].followers.push(msg.sender);
        
    }

    function getFollowing() external view returns(address[] memory)  {
        return users[msg.sender].following;
    }

    function getFollowers() external view returns(address[] memory) {
        return users[msg.sender].followers;
    }

    function getTweetFeed() view external returns(Tweet[] memory) {
        Tweet[] memory allTweets = new Tweet[](nextTweetId);
        for (uint i = 0; i < nextTweetId; i++) {
            allTweets[i] = tweets[i];
        }
        return allTweets;
    }

    function sendMessage(address _recipient, string calldata _content) external {
        Message memory theMmessage;
        theMmessage.messageId = nextMessageId;
        theMmessage.content = _content;
        theMmessage.from = msg.sender;
        theMmessage.to = _recipient;
        users[msg.sender].conversations[_recipient].push(theMmessage);
        users[_recipient].conversations[msg.sender].push(theMmessage);
        nextMessageId++;
    }

    function getConversationWithUser(address _user) external view returns(Message[] memory) {
        return users[msg.sender].conversations[_user];
    }
    // ----- END OF QUEST 2 ----- //
}