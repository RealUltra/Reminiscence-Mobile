# Reminiscence File (.rem) Format Specification

Version: 1.0
Page Size: 4096 bytes
Author: Rameez Baig
Date: 4th July 2025
Byte Order: Little-endian
Magic Number: 0x52454D30 (REM0)


# Note: The magic number is stored before the first page and is not part of any page.


# Page Header Layout - First 12 bytes of each page.

| Offset | Field        | Size (bytes) | Description                                                      |
|--------|--------------|--------------|------------------------------------------------------------------|
| 0      | Page Type    | 1            | Identifies page purpose (metadata, db, media index table, media) |
| 1      | Page Flags   | 1            | Allocated for bit flags: Currently unused                        |
| 2      | Page ID      | 4            | ID of the current page (Incremental starting from 1)             |
| 6      | Next Page ID | 4            | ID of the next page (0 if none)                                  |
| 10     | Payload Size | 2            | How many bytes on this page are used for the payload             |


# Page Types

0x01: Metadata
0x02: SQLite Database
0x03: Media Index table
0x04: Media
0x05: Free Page
0x06: Footer


# Metadata Page Layout - 66 bytes

| Offset | Field            | Size (bytes) | Description                                                      |
|--------|------------------|--------------|------------------------------------------------------------------|
| 0      | Page Header      | 12           | The page header as defined above                                 |
| 12     | Metadata Version | 1            | The version of the meta page format                              |
| 13     | Metadata Flags   | 1            | Allocated for bit flags (encrypted)                              |
| 14     | Nonce            | 16           | The nonce required to derive the encryption key with kdf         |
| 30     | Encrypted Nonce  | 32           | Used to test if the decryption key is correct                    |
| 62     | Footer Page ID   | 4            | The page ID of the footer                                        |
| 66     | Reserved         | 4030         | Padding                                                          |


# Metadata Flags

0x01: Is encrypted


# Footer Page Layout - 30 bytes

| Offset | Field                       | Size (bytes) | Description                                                      |
|--------|-----------------------------|--------------|------------------------------------------------------------------|
| 0      | Page Header                 | 12           | The page header                                                  |
| 12     | Footer Version              | 1            | The version of the footer page format                            |
| 13     | Footer Flags                | 1            | Allocated but unused                                             |
| 14     | DB Root Page ID             | 4            | The id of the first database page                                |
| 18     | Media Index Root Page ID    | 4            | The id of the first media index page                             |
| 22     | Free List Root Page ID      | 4            | The id of the first free page                                    |
| 66     | Page Count                  | 4            | The number of pages currently in the file                        |
| 70     | Reserved                    | 4066         |                                                                  |


# Media Index Layout - Size depends on number of entries

| Offset | Field                 | Size (bytes) | Description                                                      |
|--------|-----------------------|--------------|------------------------------------------------------------------|
| 0      | Page Header           | 12           | The page header                                                  |
| 12     | Media Index Entry 1   | 8            | The first media index entry                                      |
| 20     | Media Index Entry ... | 8            | The second media index entry, and so on.                         |


# Media Index Entry Layout - 8 bytes

| Offset | Field              | Size (bytes) | Description                                                      |
|--------|--------------------|--------------|------------------------------------------------------------------|
| 0      | Attachment ID      | 4            | The id of the attachment that this media is for (in the db)      |
| 4      | Media Root Page ID | 4            | The id of this media's first page                                |


# Initial Layout - 8196 bytes (8 kb)

| Offset | Field                 | Size (bytes) | Description                                                      |
|--------|-----------------------|--------------|------------------------------------------------------------------|
| 0      | Magic Number          | 4            | The magic number (Constant as defined above)                     |
| 4      | Metadata Page         | 4096         | The metadata page as defined above                               |
| 4100   | Footer Page           | 4096         | The footer page as defined above                                 |
