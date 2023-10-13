### Create Table

- AutoIncrement is very computationally expensive, so we should avoid it if possible. RowIDs are used instead.
    - ROWIDs are used instead
    - https://sqlite.org/autoinc.html

- Maximum Number Of Rows In A Table
    - The theoretical maximum number of rows in a table is 264 (18446744073709551616 or about 1.8e+19). This limit is
      unreachable since the maximum database size of 281 terabytes will be reached first. A 281 terabytes database can
      hold no more than approximately 2e+13 rows, and then only if there are no indices and if each row contains very
      little data.
    - https://sqlite.org/limits.html

- SQL:
  - Differencies:
    - https://sqlite.org/omitted.html
  - SELECT statement syntax:
    - https://sqlite.org/lang_select.html

- Interesting stuff:
  - https://www.sqlite.org/quirks.html

- UUID as a standalone script:
  - https://sqlite.org/src/file/ext/misc/uuid.c