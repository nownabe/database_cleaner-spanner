CREATE TABLE Users (
  UserId STRING(36) NOT NULL,
) PRIMARY KEY (UserId);

CREATE TABLE Followings (
  FolloweeId STRING(36) NOT NULL,
  FollowerId STRING(36) NOT NULL,

  FOREIGN KEY (FolloweeId) REFERENCES Users (UserId),
  FOREIGN KEY (FollowerId) REFERENCES Users (UserId),
) PRIMARY KEY (FolloweeId, FollowerId);

CREATE TABLE Posts (
  PostId STRING(36)  NOT NULL,
  UserId STRING(36)  NOT NULL,
  Text   STRING(MAX) NOT NULL,

  FOREIGN KEY (UserId) REFERENCES Users (UserId),
) PRIMARY KEY (PostId);

CREATE TABLE Bookmarks (
  UserId STRING(36) NOT NULL,
  PostId STRING(36) NOT NULL,

  FOREIGN KEY (PostId) REFERENCES Posts (PostId),
) PRIMARY KEY (UserId, PostId), INTERLEAVE IN PARENT Users;

CREATE TABLE Images (
  PostId  STRING(36)  NOT NULL,
  ImageId STRING(36)  NOT NULL,
  Image   BYTES(1024) NOT NULL,
) PRIMARY KEY (PostId, ImageId), INTERLEAVE IN PARENT Posts;

CREATE TABLE Replies (
  PostId  STRING(36)  NOT NULL,
  ReplyId STRING(36)  NOT NULL,
  UserId  STRING(36)  NOT NULL,
  Text    STRING(MAX) NOT NULL,

  FOREIGN KEY (UserId) REFERENCES Users (UserId),
) PRIMARY KEY (PostId, ReplyId), INTERLEAVE IN PARENT Posts;

CREATE TABLE Likes (
  PostId  STRING(36) NOT NULL,
  LikerId STRING(36) NOT NULL,

  FOREIGN KEY (LikerId) REFERENCES Users (UserId),
) PRIMARY KEY (PostId, LikerId), INTERLEAVE IN PARENT Posts;

CREATE TABLE ChatRooms (
  ChatRoomId   STRING(36)  NOT NULL,
  ChatRoomName STRING(128) NOT NULL,
) PRIMARY KEY (ChatRoomId);

CREATE TABLE ChatRoomMembers (
  ChatRoomId STRING(36) NOT NULL,
  UserId     STRING(36) NOT NULL,

  FOREIGN KEY (ChatRoomId) REFERENCES ChatRooms (ChatRoomId),
  FOREIGN KEY (UserId) REFERENCES Users (UserId),
) PRIMARY KEY (ChatRoomId, UserId);

CREATE TABLE ChatRoomMessages (
  ChatRoomId        STRING(36)  NOT NULL,
  ChatRoomMessageId STRING(36)  NOT NULL,
  UserId            STRING(36)  NOT NULL,
  Text              STRING(MAX) NOT NULL,

  FOREIGN KEY (ChatRoomId, UserId) REFERENCES ChatRoomMembers (ChatRoomId, UserId),
) PRIMARY KEY (ChatRoomId, ChatRoomMessageId), INTERLEAVE IN PARENT ChatRooms;

CREATE TABLE Communities (
  CommunityId   STRING(36)  NOT NULL,
  CommunityName STRING(128) NOT NULL,
  OwnerId       STRING(36)  NOT NULL,

  FOREIGN KEY (OwnerId) REFERENCES Users (UserId),
) PRIMARY KEY (CommunityId);

CREATE TABLE CommunityBelongings (
  UserId      STRING(36) NOT NULL,
  CommunityId STRING(36) NOT NULL,

  FOREIGN KEY (CommunityId) REFERENCES Communities (CommunityId),
) PRIMARY KEY (UserId, CommunityId), INTERLEAVE IN PARENT Users;

CREATE TABLE CommunityPosts (
  CommunityId STRING(36) NOT NULL,
  PostId      STRING(36) NOT NULL,

  FOREIGN KEY (PostId) REFERENCES Posts (PostId),
) PRIMARY KEY (CommunityId, PostId), INTERLEAVE IN PARENT Communities;

