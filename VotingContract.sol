// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingContract {
    address public admin;
    uint256 public totalTopics;

    struct VotingTopic {
        string title;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        mapping(address => bool) hasVoted;
    }

    VotingTopic[] public votingTopics;

    event TopicCreated(uint256 indexed topicId, string title);
    event VoteCasted(uint256 indexed topicId, address indexed voter, bool inSupport);
    event VoteRevoked(uint256 indexed topicId, address indexed voter);
    event TopicFinalized(uint256 indexed topicId, uint256 votesFor, uint256 votesAgainst);

    constructor() {
        admin = msg.sender;
        totalTopics = 0;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this operation.");
        _;
    }

    // 开始一个新的投票主题
    function createTopic(string memory title, string memory description) public onlyAdmin {
        VotingTopic storage newTopic = votingTopics.push();
        newTopic.title = title;
        newTopic.description = description;
        newTopic.votesFor = 0;
        newTopic.votesAgainst = 0;

        totalTopics++;

        emit TopicCreated(totalTopics - 1, title);
}

    // 对当前活跃的主题进行投票
    function vote(uint256 topicId, bool inSupport) public {
        require(topicId < votingTopics.length, "Invalid topic ID.");
        require(!votingTopics[topicId].hasVoted[msg.sender], "You have already voted for this topic.");

        votingTopics[topicId].hasVoted[msg.sender] = true;

        if (inSupport) {
            votingTopics[topicId].votesFor++;
        } else {
            votingTopics[topicId].votesAgainst++;
        }

        emit VoteCasted(topicId, msg.sender, inSupport);
    }

    // 撤销对某个主题的投票
    function revokeVote(uint256 topicId) public {
        require(topicId < votingTopics.length, "Invalid topic ID.");
        require(votingTopics[topicId].hasVoted[msg.sender], "You have not voted for this topic.");

        votingTopics[topicId].hasVoted[msg.sender] = false;

        if (votingTopics[topicId].votesFor > 0) {
            votingTopics[topicId].votesFor--;
        }

        if (votingTopics[topicId].votesAgainst > 0) {
            votingTopics[topicId].votesAgainst--;
        }

        emit VoteRevoked(topicId, msg.sender);
    }

    // 结算某个主题的投票结果
    function finalizeTopic(uint256 topicId) public onlyAdmin {
        require(topicId < votingTopics.length, "Invalid topic ID.");

        VotingTopic storage topic = votingTopics[topicId];

        if (topic.votesFor > topic.votesAgainst) {
            // 胜出方是支持方
            emit TopicFinalized(topicId, topic.votesFor, topic.votesAgainst);
        } else if (topic.votesAgainst > topic.votesFor) {
            // 胜出方是反对方
            emit TopicFinalized(topicId, topic.votesFor, topic.votesAgainst);
        } else {
            // 平局
            emit TopicFinalized(topicId, topic.votesFor, topic.votesAgainst);
        }
    }

    // 查看某个用户是否对某个主题进行过投票
    function hasVoted(uint256 topicId, address user) public view returns (bool) {
        require(topicId < votingTopics.length, "Invalid topic ID.");

        return votingTopics[topicId].hasVoted[user];
    }
}
