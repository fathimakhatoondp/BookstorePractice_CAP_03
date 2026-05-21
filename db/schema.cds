using {
    cuid,
    managed,
    sap.common.Currencies
} from '@sap/cds/common';
using {Attachments} from '@cap-js/attachments';
namespace tutorial.db;

entity Books : cuid, managed {
    title       : String;
    author      : Association to Authors;
    genre       : Association to Genres;
    publishedAt : Date;
    pages       : Integer;
    price       : Decimal(9, 2);
    currency    : Association to Currencies;
    Chapters    : Composition of many Chapters
                      on Chapters.book = $self;
    stock       : Integer;
    status      : Association to BookStatus;
    attachments : Composition of  many Attachments;
}

entity Genres {
    key code        : Genre;
        description : String;
        
}

type Genre : String enum {
    Fiction = 'Fiction';
    Science = 'Science';
    Cooking = 'Cooking';
    Fantasy = 'Fantasy';
    Hobby = 'Hobby';
    Adventure = 'Adventure';
    SelfHelp = 'SelfHelp';
    NonFiction = 'NonFiction';
    Art = 'Art';
    Children = 'Children';
}

entity BookStatus {
    key code        : String(1) enum {
            Available = 'A';
            Low_Stock = 'L';
            Unavailable = 'U';
        }
        criticality : Integer;
        displayText : String;
}

entity Authors : cuid, managed {
    name  : String;
    fileName : String;
    fileType : String @Core.IsMediaType;
    content : LargeBinary @Core.MediaType: fileType
                            @Core.AcceptableMediaTypes: ['image/jpeg', 'image/png', 'application/pdf']
                            @Core.ContentDisposition.Filename: fileName;
    virtual bookCount : Integer;
    books : Association to many Books
                on books.author = $self;
    attachments : Composition of many Attachments;
}

entity Chapters : cuid, managed {
    key book   : Association to Books;
        number : Integer;
        title  : String;
        pages  : Integer;
}
