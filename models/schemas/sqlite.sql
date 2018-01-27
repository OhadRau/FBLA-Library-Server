CREATE TABLE books (
  isbn INTEGER PRIMARY KEY,
  dewey TEXT NOT NULL,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  publisher TEXT,
  edition INTEGER,
  copyright CHAR(4),
  cover BLOB
);

CREATE TABLE status (
  status TEXT PRIMARY KEY
);

INSERT INTO status (status) VALUES ("IN_STOCK"), ("CHECKED_OUT"), ("RESERVED");

CREATE TABLE stock (
  isbn INTEGER NOT NULL,
  status TEXT NOT NULL,
  since TEXT,
  due TEXT,
  user TEXT,

  FOREIGN KEY (isbn) REFERENCES book (isbn),
  FOREIGN KEY (status) REFERENCES status (status)
);
