CREATE TABLE Products (
  ProductId INT64       NOT NULL,
  Name      STRING(256) NOT NULL,
  Price     FLOAT64     NOT NULL,
) PRIMARY KEY (ProductId);

CREATE TABLE Customers (
  CustomerId INT64       NOT NULL,
  Name       STRING(256) NOT NULL,
) PRIMARY KEY (CustomerId);

CREATE TABLE Orders (
  OrderId    INT64 NOT NULL,
  ProductId  INT64 NOT NULL,
  CustomerId INT64 NOT NULL,
  Quantity   INT64 NOT NULL,
  FOREIGN KEY (CustomerId) REFERENCES Customers (CustomerId),
  FOREIGN KEY (ProductId)  REFERENCES Products  (ProductId),
) PRIMARY KEY (OrderId);

CREATE TABLE Singers (
  SingerId INT64 NOT NULL,
  Name     STRING(1024)
) PRIMARY KEY (SingerId);

CREATE TABLE Albums (
  SingerId INT64 NOT NULL,
  AlbumId  INT64 NOT NULL,
  Title    STRING(MAX),
) PRIMARY KEY (SingerId, AlbumId), INTERLEAVE IN PARENT Singers;

CREATE TABLE Songs (
  SingerId INT64 NOT NULL,
  AlbumId  INT64 NOT NULL,
  SongId   Int64 NOT NULL,
  Title    STRING(MAX),
) PRIMARY KEY (SingerId, AlbumId, SongId), INTERLEAVE IN PARENT Albums;

CREATE TABLE OnlyTable (
  Id INT64 NOT NULL,
) PRIMARY KEY (Id);

CREATE TABLE ExceptTable (
  Id INT64 NOT NULL,
) PRIMARY KEY (Id);
