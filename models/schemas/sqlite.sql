CREATE TABLE books (
  isbn BIGINT PRIMARY KEY,
  dewey TEXT NOT NULL,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  publisher TEXT,
  edition INTEGER,
  copyright CHAR(4),
  cover BLOB,
  reserved_by TEXT
);

CREATE TABLE status (
  status TEXT PRIMARY KEY
);

INSERT INTO status (status) VALUES ("IN_STOCK"), ("CHECKED_OUT"), ("RESERVED");

CREATE TABLE stock (
  ROWID INTEGER PRIMARY KEY,
  isbn BIGINT NOT NULL,
  status TEXT NOT NULL,
  since TEXT,
  due TEXT,
  user TEXT,

  FOREIGN KEY (isbn) REFERENCES books (isbn),
  FOREIGN KEY (status) REFERENCES status (status)
);

CREATE TABLE reports (
  ROWID INTEGER PRIMARY KEY,
  user TEXT NOT NULL,
  message TEXT NOT NULL
);
